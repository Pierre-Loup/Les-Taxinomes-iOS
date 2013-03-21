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

#import "LTMediasRootViewController.h"

// Model
#import "Author.h"
#import "LTConnectionManager.h"
#import "Reachability.h"
// Controllers
#import "LTMediasListViewController.h"
#import "LTMediasGridViewController.h"
#import "MediaDetailViewController.h"
// Views
#import "SpinnerCell.h"
#import "UIImageView+AFNetworking.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

#define kSpinnerCellIdentifier  @"SpinnerCell"
#define kCommonRowAnnimation UITableViewRowAnimationNone

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

typedef enum {
    LTMediasDisplayModeList,
    LTMediasDisplayModeGrid
} LTMediasDisplayMode ;

@interface LTMediasRootViewController ()

@property (nonatomic, strong) IBOutlet MediaDetailViewController *mediaDetailViewController;
@property (nonatomic, strong) LTMediasListViewController* listViewController;
@property (nonatomic, strong) LTMediasGridViewController* gridViewController;
@property (nonatomic, strong) UIBarButtonItem* displayBarButton;
@property (nonatomic, strong) NSFetchedResultsController* mediasResultController;
@property (nonatomic) LTMediasDisplayMode displayMode;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediasRootViewController

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
    
    [self.view addSubview:self.listViewController.view];
    [self.view addSubview:self.gridViewController.view];
    self.gridViewController.view.hidden = YES;
    
    self.mediaDetailViewController = (MediaDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.listViewController.view.frame = self.view.bounds;
    self.gridViewController.view.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[self.mediasResultController fetchedObjects] count] == 0) {
        [self showDefaultHud];
        [self loadMoreMedias];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.displayBarButton = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mediasResultController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [NSFetchedResultsController deleteCacheWithName:self.mediasResultController.cacheName];
    self.mediasResultController = nil;
}

- (void)reloadData
{
    self.mediasResultController = nil;
    if (self.displayMode == LTMediasDisplayModeList) {
        [self.listViewController.tableView reloadData];
    } else if (self.displayMode == LTMediasDisplayModeGrid) {
        [self.gridViewController.collectionView reloadData];
    }
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods

- (void)commonInit
{
    _displayMode = LTMediasDisplayModeList;
    _listViewController = [LTMediasListViewController new];
    _listViewController.dataSource = self;
    _listViewController.delegate = self;
    [self addChildViewController:_listViewController];
    _gridViewController = [LTMediasGridViewController new];
    _gridViewController.dataSource = self;
    _gridViewController.delegate = self;
    [self addChildViewController:_gridViewController];
}

- (void)loadMoreMedias
{
    self.listViewController.footerView.displayMode = LTMediasLoadMoreFooterViewDisplayModeLoading;
    self.gridViewController.footerView.displayMode = LTMediasLoadMoreFooterViewDisplayModeLoading;
    
    NSRange mediasRange;
    mediasRange.location = [[self.mediasResultController fetchedObjects] count];
    mediasRange.length = kLTMediasLoadingStep;
    [self.hud show:YES];
    LTConnectionManager* connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager getShortMediasByDateForAuthor:self.currentUser
                                        nearLocation:nil
                                           withRange:mediasRange
    responseBlock:^(NSArray *medias, NSError *error) {
        if (medias) {
            self.mediasResultController = nil;
            [self.hud hide:YES];
        } else if ([error shouldBeDisplayed]) {
            [UIAlertView showWithError:error];
            [self.hud hide:NO];
        }
        [self reloadData];
        self.listViewController.footerView.displayMode = LTMediasLoadMoreFooterViewDisplayModeNormal;
        self.gridViewController.footerView.displayMode = LTMediasLoadMoreFooterViewDisplayModeNormal;
    }];
}

//- (void)refreshButtonAction:(id)sender
//{
//    self.displayBarButton.enabled = NO;
//    [self showDefaultHud];
//    self.mediasResultController = nil;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [Media deleteAllMedias];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self reloadData];
//            [self loadMoreMedias];
//        });
//    });
//}

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
    if (displayMode == _displayMode) {
        return;
    }
    
    _displayMode = displayMode;
    
    if (_displayMode == LTMediasDisplayModeList) {
        [self.listViewController.tableView reloadData];
        [UIView transitionFromView:self.gridViewController.view
                            toView:self.listViewController.view
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {}];
        self.displayBarButton.image = [UIImage imageNamed:@"icon_grid"];
        
    } else if (_displayMode == LTMediasDisplayModeGrid) {
        [self.gridViewController.collectionView reloadData];
        [UIView transitionFromView:self.listViewController.view
                            toView:self.gridViewController.view
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {}];
        self.displayBarButton.image = [UIImage imageNamed:@"icon_list"];
        
    }
}

- (NSFetchedResultsController*)mediasResultController
{    
    if (!_mediasResultController) {
        NSPredicate* predicate = nil;
        if (self.currentUser) {
            predicate = [NSPredicate predicateWithFormat:@"status == %@ && author == %@",@"publie",self.currentUser];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"status == %@",@"publie"];
        }
        
        _mediasResultController = [Media fetchAllSortedBy:@"date"
                                                     ascending:NO
                                                 withPredicate:predicate
                                                       groupBy:nil
                                                      delegate:nil];
    }
    return _mediasResultController;
}

@end
