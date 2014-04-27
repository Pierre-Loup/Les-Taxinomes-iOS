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
#import "LTAuthor.h"
#import "LTConnectionManager.h"
#import "Reachability.h"
// Controllers
#import "LTMediasListViewController.h"
#import "LTMediasGridViewController.h"
#import "LTMediaDetailViewController.h"
// Views
#import "SpinnerCell.h"

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

@property (nonatomic, strong) IBOutlet LTMediaDetailViewController* mediaDetailViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* displayBarButton;
@property (nonatomic, strong) UIViewController* contentViewController;
@property (nonatomic, strong) LTMediasListViewController* listViewController;
@property (nonatomic, strong) LTMediasGridViewController* gridViewController;
@property (nonatomic, strong) NSArray* medias;
@property (nonatomic, assign) BOOL isFetchingMedias;
@property (nonatomic) LTMediasDisplayMode displayMode;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediasRootViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Supermethods overrides

- (id)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation bar
    self.title = _T(@"tabbar.medias");
    self.displayBarButton.image = [UIImage imageNamed:@"icon_grid"];
    
    self.mediaDetailViewController = (LTMediaDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.listViewController.view.frame = self.view.bounds;
    self.gridViewController.view.frame = self.view.bounds;
    
    if (!self.contentViewController)
    {
        [self addChildViewController:self.listViewController];
        [self.listViewController didMoveToParentViewController:self];
        [self.view addSubview:self.listViewController.view];
        self.contentViewController = self.listViewController;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateContraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.parentViewController respondsToSelector:@selector(topLayoutGuide)] &&
        [self.parentViewController respondsToSelector:@selector(bottomLayoutGuide)])
    {
        self.listViewController.topBarOffset = self.topLayoutGuide.length;
        self.gridViewController.topBarOffset = self.topLayoutGuide.length;
        self.listViewController.bottomBarOffset = self.bottomLayoutGuide.length;
        self.gridViewController.bottomBarOffset = self.bottomLayoutGuide.length;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.displayBarButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

- (void)loadMoreMediaWithCompletion:(void (^)(NSArray* medias, NSError *error))completion
{
    NSRange mediasRange;
    mediasRange.location = [self.medias count];
    mediasRange.length = LTMediasLoadingStep;
    
    self.isFetchingMedias = YES;
    
    LTConnectionManager* connectionManager = [LTConnectionManager sharedManager];
    [connectionManager fetchMediasSummariesByDateForAuthor:self.currentUser
                                              nearLocation:nil
                                              searchFilter:nil
                                                 withRange:mediasRange
                                             responseBlock:^(NSArray *medias, NSError *error)
     {
         if (!medias)
         {
             [SVProgressHUD showErrorWithStatus:_T(@"common.hud.failure")];
         }
         else if([medias count])
         {
             NSMutableArray* allMedias;
             if (self.medias)
             {
                 allMedias = [self.medias mutableCopy];
             }
             else
             {
                 allMedias = [NSMutableArray new];
             }
             [allMedias addObjectsFromArray:medias];
             self.medias = [NSArray arrayWithArray:allMedias];
         }
         
         if (completion)
         {
             completion(medias, error);
         }
         
         if (self.contentViewController == self.listViewController)
         {
             [self.gridViewController.collectionView reloadData];
         }
         else if (self.contentViewController == self.gridViewController)
         {
             [self.listViewController.tableView reloadData];
         }
         
         self.isFetchingMedias = NO;
         
     }];
}


- (void)refreshMediasWithCompletion:(void (^)(NSArray* medias, NSError *error))completion
{
    self.medias = nil;
    
    self.isFetchingMedias = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        [LTMedia MR_truncateAll];
        NSError* error;
        [[NSManagedObjectContext MR_contextForCurrentThread] save:&error];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self loadMoreMediaWithCompletion:completion];
        });
    });
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods

- (void)commonInit
{
    _displayMode = LTMediasDisplayModeList;
    
    _listViewController = [LTMediasListViewController new];
    _listViewController.mediasRootViewController = self;
    [self addChildViewController:_listViewController];
    
    _gridViewController = [LTMediasGridViewController new];
    _gridViewController.mediasRootViewController = self;
}

- (IBAction)displayBarButton:(UIBarButtonItem*)barButtonItem
{
    if (self.displayMode == LTMediasDisplayModeList)
    {
        self.displayMode = LTMediasDisplayModeGrid;
    }
    else if (self.displayMode == LTMediasDisplayModeGrid)
    {
        self.displayMode = LTMediasDisplayModeList;
    }
}

- (void)updateContraints
{
    if (self.contentViewController.view.superview == self.view)
    {
        UIView* contentView = self.contentViewController.view;
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentViewController.view.frame = self.view.bounds;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(contentView)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(contentView)]];
    }
}

#pragma mark Properties

- (void)setIsFetchingMedias:(BOOL)isFetchingMedias
{
    if (_isFetchingMedias != isFetchingMedias)
    {
        _isFetchingMedias = isFetchingMedias;
        self.displayBarButton.enabled = !isFetchingMedias;
    }
}

- (void)setDisplayMode:(LTMediasDisplayMode)displayMode
{
    if (!self.isFetchingMedias)
    {
        _displayMode = displayMode;
        
        // Switch between grid and list display
        if (_displayMode == LTMediasDisplayModeList &&
            self.contentViewController != self.listViewController)
        {
            // Add the VC to display the root VC
            [self addChildViewController:self.listViewController];
            [self.listViewController didMoveToParentViewController:self];
            [self.view addSubview:self.listViewController.view];
            
            [self.listViewController.tableView reloadData];
            self.listViewController.firstVisibleMedia = self.gridViewController.firstVisibleMedia;
            
            self.listViewController.view.hidden = YES;
            [self.view addSubview:self.listViewController.view];
            self.contentViewController = self.listViewController;
            
            [UIView transitionFromView:self.gridViewController.view
                                toView:self.listViewController.view
                              duration:1.0
                               options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionShowHideTransitionViews
                            completion:^(BOOL finished)
             {
                 [self.gridViewController willMoveToParentViewController:self];
                 [self.gridViewController removeFromParentViewController];
             }];
            
            self.displayBarButton.image = [UIImage imageNamed:@"icon_grid"];
            
        }
        else if (_displayMode == LTMediasDisplayModeGrid &&
                 self.contentViewController != self.gridViewController)
        {
            // Add the VC to display the root VC
            [self addChildViewController:self.gridViewController];
            [self.gridViewController didMoveToParentViewController:self];
            [self.view addSubview:self.gridViewController.view];
            
            [self.gridViewController.collectionView reloadData];
            LTMedia* firstVisibleMedia = self.listViewController.firstVisibleMedia;
            
            self.gridViewController.view.hidden = YES;
            [self.view addSubview:self.gridViewController.view];
            self.contentViewController = self.gridViewController;
            self.gridViewController.firstVisibleMedia = firstVisibleMedia;
            
            [UIView transitionFromView:self.listViewController.view
                                toView:self.gridViewController.view
                              duration:1.0
                               options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews
                            completion:^(BOOL finished)
             {
                 [self.listViewController willMoveToParentViewController:nil];
                 [self.listViewController removeFromParentViewController];
             }];
            
            self.displayBarButton.image = [UIImage imageNamed:@"icon_list"];
        }
    }
}

@end
