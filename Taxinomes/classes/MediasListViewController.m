//
//  MediasListViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "MediasListViewController.h"
#import "MediasListTableViewCell.h"
#import "Author.h"
#import "LTDataManager.h"
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
    // Releases the view if it doesn't have a superview.
    /*
    [super didReceiveMemoryWarning];
    
    NSArray *visibleCells = [[tableView indexPathsForVisibleRows] retain];
    NSMutableArray *visiblemedias = [[NSMutableArray alloc] initWithCapacity:[visibleCells count]];
    for(NSIndexPath *indexPath in visibleCells){
        [visiblemedias addObject:[medias objectAtIndex:[indexPath row]]];
    }
    [medias release];
    self.medias = visiblemedias;
    [visiblemedias release];
    [tableView reloadData];
     */
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    if([[Reachability reachabilityWithHostName:kHost] isReachable]){
        DataManager *dm = [DataManager sharedDataManager];
        NSArray *medias = [dm getShortmediasByDateWithLimit:kNbMediasStep startingAtRecord:0];
        
        if([medias count] != 0){
            mediaLoadingStatus = SUCCEED;
            self.mediaForIndexPath = [NSMutableDictionary dictionaryWithCapacity:[medias count]];
            int i;
            for (i=0; i< [medias count]; i++) {
                [mediaForIndexPath setObject:[medias objectAtIndex:i] forKey:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        } else {
            mediaLoadingStatus = FAILED;
            [self performSelectorOnMainThread:@selector(connectionErrorAlert:) withObject:nil waitUntilDone:NO];
        }
    } else {
        mediaLoadingStatus = FAILED;
        [self performSelectorOnMainThread:@selector(connectionErrorAlert:) withObject:nil waitUntilDone:NO];
    }
     */
    
    mediaLoadingStatus = PENDING;
    self.mediaForIndexPath = [[NSMutableDictionary alloc] init];
    [self performSelectorInBackground:@selector(loadNextMediasInBackground) withObject:nil];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImage.image = [UIImage imageNamed:@"fond.png"];
    CGRect backgroundSubviewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIView *backgroundSubview = [[UIView alloc] initWithFrame:backgroundSubviewFrame];
    backgroundSubview.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.90];
    [backgroundImage addSubview:backgroundSubview];
    if([tableView respondsToSelector:@selector(setBackgroundView:)]){
        self.tableView.backgroundView = backgroundImage;
    }    
    [backgroundImage release];
    /*
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:modalButton animated:YES];
    [modalButton release];
    */
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
            [self performSelectorInBackground:@selector(loadNextMediasInBackground) withObject:nil];
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
    
    
    //[((MediasListTableViewCell *)cell) setImage:[UIImage imageNamed:@"Ixia.gif"]];   
    //[((MediasListTableViewCell *)cell) setmedia:media];
    ((UIImageView *)[cell viewWithTag:1]).image = media.mediaThumbnail;
    ((UILabel *)[cell viewWithTag:2]).text = media.title;
    ((UILabel *)[cell viewWithTag:3]).text = ((Author *)[media.authors objectAtIndex:0]).name;
    cell.opaque = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68.0;
}
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *media = [[mediaForIndexPath objectForKey:indexPath] retain];
    if(media != nil){
        MediaDetailViewController *mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailView" bundle:nil mediaId:media.id_media];
        [self.navigationController pushViewController:mediaDetailViewController animated:YES];
        [mediaDetailViewController release];
        [media release];
    }
    
}



#pragma mark - Scroll view delegate

/*
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //NSLog(@"%f %f",scrollView.contentOffset.y, tableView.rowHeight);
    if((scrollView.contentOffset.y+tableView.rowHeight)<= 0.0){
        isLoadingNewMedias = YES;
        //maxOffset = scrollView.contentOffset.y;
    }
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(isLoadingNewMedias){
        //scrollView.contentOffset = CGPointMake(0.0, scrollView.contentOffset.y);
        [scrollView setContentOffset:CGPointMake(0.0, -tableView.rowHeight) animated:NO];
        isLoadingNewMedias = NO;
    }
    NSLog(@"%f",scrollView.contentOffset.y);
    CGFloat height = (-scrollView.contentOffset.y)<=tableView.rowHeight?(-scrollView.contentOffset.y):tableView.rowHeight;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, height);
    if(loadingTopVew != nil)
        [loadingTopVew release];
    [loadingTopVew removeFromSuperview];
    loadingTopVew = [[UIView alloc ] initWithFrame:frame];
    loadingTopVew.backgroundColor = [UIColor blueColor];
    [self.view addSubview:loadingTopVew];
    
}
*/



-(void)loadNextMediasInBackground {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSArray *nextmedias;
    if([[Reachability reachabilityWithHostName:kHost] isReachable]){
        LTDataManager *dm = [LTDataManager sharedDataManager];
        nextmedias = [dm getShortmediasByDateWithLimit:kNbMediasStep startingAtRecord:[mediaForIndexPath count]];
        if([nextmedias count] != 0) {
            [self performSelectorOnMainThread:@selector(addMediasToBottom:) withObject:nextmedias waitUntilDone:NO];                
        } else {
            [self performSelectorOnMainThread:@selector(connectionErrorAlert:) withObject:nil waitUntilDone:NO];  
        }
    } else {
        [self performSelectorOnMainThread:@selector(connectionErrorAlert:) withObject:nil waitUntilDone:NO];  
    }
    [pool release];
}

/*
-(void)loadNewMediasInBackground {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSArray *nextmedias;
    if([[Reachability reachabilityWithHostName:kHost] isReachable]){
        DataManager *dm = [DataManager sharedDataManager];
        nextmedias = [dm getShortmediasByDateWithLimit:kNbMediasStep startingAtRecord:[mediaForIndexPath count]];
    }
    [self performSelectorOnMainThread:@selector(addMediasToBottom:) withObject:nextmedias waitUntilDone:NO];
    [pool release];
}
 */

- (void) addMediasToBottom:(NSArray *)nextmedias {
    if(nextmedias != nil){
        int i;
        int nbmedias = [mediaForIndexPath count];
        for (i=0; i<[nextmedias count]; i++) {
            [mediaForIndexPath setObject:[nextmedias objectAtIndex:i] forKey:[NSIndexPath indexPathForRow:i+nbmedias inSection:0]];
        }
        [self.tableView reloadData];
    }    
    mediaLoadingStatus = SUCCEED;
}

- (void) connectionErrorAlert:(id)sender {
    mediaLoadingStatus = FAILED;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problème lors de la communication avec le serveur" message:@"Vérifiez que vous avez accès au Wifi ou au réseau internet mobile " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self.tableView reloadData];
}

- (IBAction)reloadButtonAction:(id)sender{
    if (mediaLoadingStatus != PENDING) {
        mediaLoadingStatus = PENDING;
        [self.tableView reloadData];
        [self performSelectorInBackground:@selector(loadNextMediasInBackground) withObject:nil];
    }
}



@end
