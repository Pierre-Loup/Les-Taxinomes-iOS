//
//  MediasListViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "LTMediasViewController.h"

#import "Author.h"
#import "PSTCollectionView.h"
#import "LTConnectionManager.h"
#import "MediaDetailViewController.h"
#import "MediaListCell.h"
#import "Reachability.h"
#import "SpinnerCell.h"
#import "UIImageView+AFNetworking.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

#define kMediaListCellIdentifier  @"MediasListCell"
#define kSpinnerCellIdentifier  @"SpinnerCell"
#define kCommonRowAnnimation UITableViewRowAnimationNone

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

typedef enum {
    LTMediasDisplayModeList,
    LTMediasDisplayModeGrid
} LTMediasDisplayMode ;

@interface LTMediasViewController () <UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient>

@property (nonatomic, strong) IBOutlet MediaDetailViewController *mediaDetailViewController;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet PSUICollectionView* collectionView;
@property (nonatomic, strong) MNMBottomPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, strong) UIBarButtonItem* displayBarButton;
@property (nonatomic, strong) NSFetchedResultsController* mediasListResultController;
@property (nonatomic) LTMediasDisplayMode displayMode;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediasViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Supermethods overrides

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.displayBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_grid"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(displayBarButton:)];
    [self.navigationItem setRightBarButtonItem:self.displayBarButton animated:YES];
    
    self.mediaDetailViewController = (MediaDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[self.mediasListResultController fetchedObjects] count] == 0) {
        [self showDefaultHud];
        [self loadMoreMedias];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mediasListResultController = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.displayBarButton = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [NSFetchedResultsController deleteCacheWithName:self.mediasListResultController.cacheName];
    self.mediasListResultController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self.pullToRefreshManager relocatePullToRefreshView];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods

- (void)commonInit
{
    _displayMode = LTMediasDisplayModeList;
}

- (void)loadMoreMedias
{
    NSRange mediasRange;
    mediasRange.location = [[self.mediasListResultController fetchedObjects] count];
    mediasRange.length = kNbMediasStep;
    LTConnectionManager* connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager getShortMediasByDateForAuthor:self.currentUser
                                        nearLocation:nil
                                           withRange:mediasRange
                                       responseBlock:^(NSArray *medias, NSError *error) {
                                           if (medias) {
                                               self.mediasListResultController = nil;
                                               [self.hud hide:YES];
                                           } else if ([error shouldBeDisplayed]) {
                                               [UIAlertView showWithError:error];
                                               [self.hud hide:NO];
                                           }
                                           [self.pullToRefreshManager tableViewReloadFinished];
                                           [self.tableView reloadData];
                                           self.displayBarButton.enabled = YES;
                                       }];
}

- (void)refreshButtonAction:(id)sender
{
    self.displayBarButton.enabled = NO;
    [self showDefaultHud];
    self.mediasListResultController = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [Media deleteAllMedias];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self loadMoreMedias];
        });
    });
}

- (void)displayBarButton:(id)sender
{
    if (self.displayMode == LTMediasDisplayModeList) {
        
        self.displayMode = LTMediasDisplayModeGrid;
        
    } else if (self.displayMode == LTMediasDisplayModeGrid) {
        
        self.displayMode = LTMediasDisplayModeList;
    }
}

#pragma mark Properties

- (void)setDisplayMode:(LTMediasDisplayMode)displayMode
{
    if (displayMode == LTMediasDisplayModeList) {
        self.displayBarButton.enabled = NO;
        [UIView transitionFromView:self.collectionView
                            toView:self.tableView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                             self.displayBarButton.enabled = YES;
                         }];
        self.displayBarButton.image = [UIImage imageNamed:@"icon_grid"];
        _displayMode = LTMediasDisplayModeList;
        
    } else if (displayMode == LTMediasDisplayModeGrid) {
        self.displayBarButton.enabled = NO;
        [UIView transitionFromView:self.tableView
                            toView:self.collectionView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                             self.displayBarButton.enabled = YES;
                         }];
        self.displayBarButton.image = [UIImage imageNamed:@"icon_list"];
        _displayMode = LTMediasDisplayModeGrid;
    }
}

- (MNMBottomPullToRefreshManager*)pullToRefreshManager
{
    if (!_pullToRefreshManager) {
        _pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    }
    return _pullToRefreshManager;
}

- (NSFetchedResultsController*)mediasListResultController
{    
    if (!_mediasListResultController) {
        NSPredicate* predicate = nil;
        if (self.currentUser) {
            predicate = [NSPredicate predicateWithFormat:@"status == %@ && author == %@",@"publie",self.currentUser];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"status == %@",@"publie"];
        }
        
        _mediasListResultController = [Media fetchAllSortedBy:@"date"
                                                     ascending:NO
                                                 withPredicate:predicate
                                                       groupBy:nil
                                                      delegate:nil];
    }
    return _mediasListResultController;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.mediasListResultController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media* media = [self.mediasListResultController objectAtIndexPath:indexPath];
    MediaListCell* cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:kMediaListCellIdentifier];
    if (!cell) {
        cell = [MediaListCell mediaListCell];
    }
    
    cell.media = media;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media *media = [self.mediasListResultController objectAtIndexPath:indexPath];
    if (self.mediaDetailViewController) {
        [self.mediaDetailViewController.navigationController popToRootViewControllerAnimated:YES];
        self.mediaDetailViewController.media = media;
        self.mediaDetailViewController.title = media.title;
    } else {
        if(media != nil){
            MediaDetailViewController* mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" bundle:nil];
            mediaDetailViewController.media = media;
            mediaDetailViewController.title = media.title;
            [self.navigationController pushViewController:mediaDetailViewController animated:YES];
        }
    }
}



/**
 * Asks the delegate for the height to use for a row in a specified location.
 *
 * @param The table-view object requesting this information.
 * @param indexPath: An index path that locates a row in tableView.
 * @return A floating-point value that specifies the height (in points) that row should be.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

/**
 * This is the same delegate method as UIScrollView but required in MNMBottomPullToRefreshManagerClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewScrolled]
 *
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView: The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.pullToRefreshManager tableViewScrolled];
}

/**
 * This is the same delegate method as UIScrollView but required in MNMBottomPullToRefreshClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewReleased]
 *
 * Tells the delegate when dragging ended in the scroll view.
 *
 * @param scrollView: The scroll-view object that finished scrolling the content view.
 * @param decelerate: YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.pullToRefreshManager tableViewReleased];
}

/**
 * Tells client that refresh has been triggered
 * After reloading is completed must call [MNMBottomPullToRefreshManager tableViewReloadFinished]
 *
 * @param manager PTR manager
 */
- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    
    [self loadMoreMedias];
}

@end
