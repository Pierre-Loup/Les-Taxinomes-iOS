//
//  MediasListViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
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

@implementation MediasListViewController
@synthesize tableView, mediaForIndexPath, spinnerCell, loadingTopVew;
@synthesize mediaTableViewCell = _mediaTableViewCell;
@synthesize retryCell = _retryCell;

- (void)dealloc {
    [spinnerCell dealloc];
    [mediaForIndexPath dealloc];
    [tableView release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [TCImageView resetGlobalCache];
    [mediaForIndexPath removeAllObjects];
    [self.tableView reloadData];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataManager_ = [[LTDataManager sharedDataManager] retain];
    connectionManger_ = [[LTConnectionManager sharedConnectionManager] retain];
    
   reloadBarButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction:)];
    [self.navigationItem setRightBarButtonItem:reloadBarButton_ animated:YES];
    [reloadBarButton_ release];
    
    mediaLoadingStatus = PENDING;
    self.mediaForIndexPath = [NSMutableDictionary dictionary];
    [self reloadDatas];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [dataManager_ release];
    dataManager_ = nil;
    [connectionManger_ release];
    connectionManger_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    //NSLog(@"Rows : %d",[medias count]);
    return ([mediaForIndexPath count]+1);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *medialListCellIdentifier = @"mediasListCell";
    
    if([indexPath row] == ([mediaForIndexPath count])) {        
        if ( mediaLoadingStatus == SUCCEED) {
            [self performSelectorInBackground:@selector(loadSynchMedias:) withObject:nil];
            mediaLoadingStatus = PENDING;
            return spinnerCell;
        } else if (mediaLoadingStatus == PENDING) {
            return spinnerCell;
        } else {
            return self.retryCell;
        }
    }
    
    Media *media = [mediaForIndexPath objectForKey:indexPath];
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
        titleLabel.text = kNoTitle;
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

    Media *media = [[mediaForIndexPath objectForKey:indexPath] retain];
    if(media != nil){
        MediaDetailViewController *mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" bundle:nil mediaId:media.identifier];
        [self.navigationController pushViewController:mediaDetailViewController animated:YES];
        [mediaDetailViewController release];
        [media release];
    }
    
}

- (IBAction)loadSynchMedias:(id)sender {
    [connectionManger_ getShortMediasAsychByDateWithLimit:kNbMediasStep startingAtRecord:dataManager_.synchLimit delegate:self];
}

- (IBAction)refreshButtonAction:(id)sender {
    reloadBarButton_.enabled = NO;
    [self displayLoader];
    dataManager_.synchLimit = 0;
    [mediaForIndexPath removeAllObjects];
    [self performSelectorInBackground:@selector(loadSynchMedias:) withObject:nil];
}

- (void)reloadDatas {
    NSArray *medias =  [Media allSynchMedias];
    NSInteger row = 0;
    for (Media *media in medias) {
       [mediaForIndexPath setObject:media forKey:[NSIndexPath indexPathForRow:row inSection:0]];
        row++;
    }
    [self.tableView reloadData];
    mediaLoadingStatus = SUCCEED;
}

#pragma mark - TCImageViewDelegate

-(void)TCImageView:(TCImageView *)view WillUpdateImage:(UIImage *)image {
    
    [view setHidden:NO];
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedShortMedias:(NSArray *)medias {
    dataManager_.synchLimit += [medias count];
    [self reloadDatas];
    [self hideLoader];
    reloadBarButton_.enabled = YES;
}

- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    [alert show];
    [alert release];
    mediaLoadingStatus = FAILED;
    [self.tableView reloadData];
    [self hideLoader];
    reloadBarButton_.enabled = YES;
}

@end
