//
//  MediasListViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "MediasListViewController.h"
#import "Author.h"
#import "Constants.h"
#import "MediaDetailViewController.h"
#import "Reachability.h"

@interface MediasListViewController ()
@property (nonatomic, retain) IBOutlet UITableViewCell * spinnerCell;
@property (nonatomic, retain) IBOutlet UITableViewCell * mediaTableViewCell;
- (void)loadSynchMedias:(id)sender;
- (void)refreshButtonAction:(id)sender;
@end

@implementation MediasListViewController
@synthesize currentUser = currentUser_;
@synthesize spinnerCell = spinnerCell_;
@synthesize mediaTableViewCell = mediaTableViewCell_;

- (void)dealloc {
    [currentUser_ release];
    [mediaAtIndexPath_ release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [TCImageView resetGlobalCache];
    [mediaAtIndexPath_ removeAllObjects];
    [self.tableView reloadData];
    
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    mediaAtIndexPath_ = [NSMutableDictionary new];
    mediaLoadingStatus_ = PENDING;
    
    reloadBarButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction:)];
    [self.navigationItem setRightBarButtonItem:reloadBarButton_ animated:YES];
    [reloadBarButton_ release];
    
    [self reloadDatas];
}

- (void)viewDidUnload {
    self.tableView = nil;
    [reloadBarButton_ release];
    reloadBarButton_ = nil;
    self.mediaTableViewCell = nil;
    self.spinnerCell = nil;
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //LogDebug(@"Rows : %d",[medias count]);
    switch (mediaLoadingStatus_) {
        case FAILED:
        case NOMORETOLOAD:
            return [mediaAtIndexPath_ count];
            break;
        default:
            return ([mediaAtIndexPath_ count]+1);
            break;
    } 
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *medialListCellIdentifier = @"mediasListCell";
    
    if([indexPath row] == ([mediaAtIndexPath_ count])) {        
        if ( mediaLoadingStatus_ == SUCCEED) {
            [self performSelectorInBackground:@selector(loadSynchMedias:) withObject:nil];
            mediaLoadingStatus_ = PENDING;
            return spinnerCell_;
        } else if (mediaLoadingStatus_ == PENDING) {
            return spinnerCell_;
        }
    }
    
    Media *media = [mediaAtIndexPath_ objectForKey:indexPath];
    UITableViewCell *cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:medialListCellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MediaListCellView" owner:self options:nil];
        cell = self.mediaTableViewCell;
        self.mediaTableViewCell = nil;
        
    }
    
    TCImageView * mediaImageView = (TCImageView *)[cell viewWithTag:1];    
    if (![mediaImageView.url isEqualToString:media.mediaThumbnailUrl]) {
        [mediaImageView setHidden:YES];
        mediaImageView.caching = YES;
        mediaImageView.delegate = self;
        [mediaImageView reloadWithUrl:media.mediaThumbnailUrl];
    }
    
    UILabel * titleLabel = ((UILabel *)[cell viewWithTag:2]);
    if (media.title && ![media.title isEqualToString:@""]) {
        titleLabel.text = media.title;
        
    } else {
        titleLabel.text = TRANSLATE(@"media_upload_no_title");
    }
    
    ((UILabel *)[cell viewWithTag:3]).text = media.author.name;
    
    cell.opaque = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark Table view delegate

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 68.0;
 }
 */


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Media *media = [[mediaAtIndexPath_ objectForKey:indexPath] retain];
    if(media != nil){
        MediaDetailViewController* mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" bundle:nil mediaId:media.identifier];
        mediaDetailViewController.title = TRANSLATE(@"common.media");
        [self.navigationController pushViewController:mediaDetailViewController animated:YES];
        [mediaDetailViewController release];
        [media release];
    }
    
}

- (void)loadSynchMedias:(id)sender {
    [[LTConnectionManager sharedConnectionManager] getShortMediasByDateForAuthor:currentUser_ withLimit:kNbMediasStep startingAtRecord:[LTDataManager sharedDataManager].synchLimit delegate:self];
}

- (void)refreshButtonAction:(id)sender {
    mediaLoadingStatus_ = PENDING;
    reloadBarButton_.enabled = NO;
    [self displayLoader];
    [LTDataManager sharedDataManager].synchLimit = 0;
    [mediaAtIndexPath_ removeAllObjects];
    [self performSelectorInBackground:@selector(loadSynchMedias:) withObject:nil];
}

- (void)reloadDatas {
    NSArray *medias = nil;
    if (currentUser_) {
        medias = [Media allSynchMediasForAuthor:currentUser_];
    } else {
        medias = [Media allSynchMedias];
    }
    NSInteger row = 0;
    for (Media *media in medias) {
        [mediaAtIndexPath_ setObject:media forKey:[NSIndexPath indexPathForRow:row inSection:0]];
        row++;
    }
    [self.tableView reloadData];
    mediaLoadingStatus_ = SUCCEED;
}

#pragma mark - TCImageViewDelegate

-(void)TCImageView:(TCImageView *)view WillUpdateImage:(UIImage *)image {
    [view setHidden:NO];
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedShortMedias:(NSArray *)medias {
    if ([medias count] == 0) {
        mediaLoadingStatus_ = NOMORETOLOAD;
    }
    [LTDataManager sharedDataManager].synchLimit += [medias count];
    [self reloadDatas];
    [self hideLoader];
    reloadBarButton_.enabled = YES;
}

- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
    [alert show];
    [alert release];
    mediaLoadingStatus_ = FAILED;
    [self.tableView reloadData];
    [self hideLoader];
    reloadBarButton_.enabled = YES;
}

@end
