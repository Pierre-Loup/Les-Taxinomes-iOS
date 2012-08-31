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
#import "MediaListCell.h"
#import "Reachability.h"
#import "SpinnerCell.h"
#import "UIImageView+AFNetworking.h"

#define kMediaListCellIdentifier  @"MediasListCell"
#define kSpinnerCellIdentifier  @"SpinnerCell"

@interface MediasListViewController () <LTConnectionManagerDelegate> {
    
    MediaLoadingStatus mediaLoadingStatus_;
    NSMutableDictionary* mediaAtIndexPath_;
    
    // UI
    UIBarButtonItem* reloadBarButton_;
}
@property (nonatomic, retain) IBOutlet MediaDetailViewController *mediaDetailViewController;

- (void)loadSynchMedias;
- (void)refreshButtonAction:(id)sender;
@end

@implementation MediasListViewController
@synthesize currentUser = currentUser_;
@synthesize mediaDetailViewController = mediaDetailViewController_;

- (void)dealloc {
    [currentUser_ release];
    [mediaAtIndexPath_ release];
    [mediaDetailViewController_ release];
    [reloadBarButton_ release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
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
    
    mediaDetailViewController_ = (MediaDetailViewController *)[[[self.splitViewController.viewControllers lastObject] topViewController] retain];
    
    [self reloadDatas];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mediaDetailViewController = nil;
    [reloadBarButton_ release];
    reloadBarButton_ = nil;
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] == ([mediaAtIndexPath_ count])) {
        SpinnerCell* spinnerCell = [self.tableView dequeueReusableCellWithIdentifier:kSpinnerCellIdentifier];
        if (!spinnerCell) {
            spinnerCell =  [SpinnerCell spinnerCell];
        }
        
        if ( mediaLoadingStatus_ == SUCCEED) {
            [self loadSynchMedias];
            mediaLoadingStatus_ = PENDING;
        }
        return spinnerCell;
    }
    
    Media* media = [mediaAtIndexPath_ objectForKey:indexPath];
    MediaListCell* cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:kMediaListCellIdentifier];
    if (!cell) {
        cell = [MediaListCell mediaListCell];
    }
    
    if (media.title && ![media.title isEqualToString:@""]) {
        cell.title.text = media.title;
        
    } else {
        cell.title.text = TRANSLATE(@"media_upload_no_title");
    }
    
    cell.author.text = media.author.name;
    
    [cell.image setImageWithURL:[NSURL URLWithString:media.mediaThumbnailUrl]
               placeholderImage:[UIImage imageNamed:@"thumbnail_placeholder"]];
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *media = [mediaAtIndexPath_ objectForKey:indexPath];
    if (mediaDetailViewController_) {
        [mediaDetailViewController_.navigationController popToRootViewControllerAnimated:YES];
        mediaDetailViewController_.media = media;
        mediaDetailViewController_.title = media.title;
    } else {
        if(media != nil){
            MediaDetailViewController* mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" bundle:nil];
            mediaDetailViewController.media = media;
            mediaDetailViewController.title = media.title;
            [self.navigationController pushViewController:mediaDetailViewController animated:YES];
            [mediaDetailViewController release];
        }
    }
}

#pragma mark - Private methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

- (void)loadSynchMedias {
    NSRange mediasRange;
    mediasRange.location = [LTDataManager sharedDataManager].synchLimit;
    mediasRange.length = kNbMediasStep;
    
    [[LTConnectionManager sharedConnectionManager] getShortMediasByDateForAuthor:currentUser_
                                                                       withRange:mediasRange
    responseBlock:^(Author *author, NSRange range, NSArray *medias, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
            [alert show];
            [alert release];
            mediaLoadingStatus_ = FAILED;
            [self.tableView reloadData];
            [self hideLoader];
            reloadBarButton_.enabled = YES;
        } else if (medias) {
            if ([medias count] == 0) {
                mediaLoadingStatus_ = NOMORETOLOAD;
            }
            [LTDataManager sharedDataManager].synchLimit += [medias count];
            [self reloadDatas];
            [self hideLoader];
            reloadBarButton_.enabled = YES;
        }
    }];
}

- (void)refreshButtonAction:(id)sender {
    mediaLoadingStatus_ = PENDING;
    reloadBarButton_.enabled = NO;
    [self displayLoader];
    [LTDataManager sharedDataManager].synchLimit = 0;
    [mediaAtIndexPath_ removeAllObjects];
    [self.tableView reloadData];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        [Media deleteAllMedias];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadSynchMedias];
        });
    });
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
    mediaLoadingStatus_ = SUCCEED;
    [self.tableView reloadData];
}

@end
