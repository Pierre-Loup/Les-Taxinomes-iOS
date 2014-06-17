//
//  LTMediasListViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "LTMediasListViewController.h"

// UI
#import "LTMediaDetailViewController.h"
#import "LTMediaListCell.h"
#import "LTLoadMoreFooterView.h"

// Model
#import "LTMedia.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

static NSString* const LTMediaListCellIdentifier = @"MediasListCell";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTMediasListViewController ()
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@property (nonatomic, assign) BOOL shouldScrollToTop;
@property (nonatomic, readonly) NSArray* medias;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediasListViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclasse overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.clipsToBounds = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Puff to refresh top view
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAction:)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Footer load more view
    CGRect footerViewFrame = CGRectMake(0.f, 0.f,
                                        self.tableView.frame.size.width,
                                        LTMediasListCommonRowHeight);
    self.footerView = [[LTLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self
                                  action:@selector(loadMoreMediasAction:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = self.footerView;
    self.shouldScrollToTop = YES;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateScrollViewInsets];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.shouldScrollToTop)
    {
        CGPoint contentOffset = {0, -self.topBarOffset};
        self.tableView.contentOffset = contentOffset;
        self.shouldScrollToTop = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.medias count] == 0)
    {
        [self loadMoreMediasAction:self];
    }
    
    if (self.mediasRootViewController.isFetchingMedias)
    {
        self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeLoading;
    }
    else
    {
        self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.footerView = nil;
    self.refreshControl = nil;
}

- (void)dealloc
{
    [self.refreshControl removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (LTMedia *)firstVisibleMedia
{
    if (self.tableView.visibleCells.count == 0)
    {
        return nil;
    }
    
    CGPoint top = {0, self.tableView.contentOffset.y + self.tableView.contentInset.top};
    NSIndexPath* topVisibleCellIndexPath = [self.tableView indexPathForRowAtPoint:top];

    LTMedia* media = self.medias[topVisibleCellIndexPath.row];
    return media;
}

- (void)setFirstVisibleMedia:(LTMedia *)firstVisibleMedia
{
    NSInteger rowIndex = [self.medias indexOfObject:firstVisibleMedia];
    if (rowIndex != NSNotFound)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    
        if ([self.medias count] > indexPath.row)
        {
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:NO];
        }
    }
}

- (void)setTopBarOffset:(CGFloat)topBarOffset
{
    _topBarOffset = topBarOffset;
    [self updateScrollViewInsets];
}

- (void)setBottomBarOffset:(CGFloat)bottomBarOffset
{
    _bottomBarOffset = bottomBarOffset;
    [self updateScrollViewInsets];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)updateScrollViewInsets
{
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topBarOffset, 0
                                            ,self.bottomBarOffset , 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

#pragma mark Properties

- (NSArray*)medias
{
    return self.mediasRootViewController.medias;
}

#pragma mark Actions

- (void)refreshAction:(id)sender
{
    if (!self.mediasRootViewController.isFetchingMedias)
    {
        NSInteger mediasNumber = [self.medias count];

        __weak LTMediasListViewController* weakSelf = self;
        [self.mediasRootViewController refreshMediasWithCompletion:^(NSArray *medias, NSError *error)
         {
             [self.tableView beginUpdates];
             for (NSInteger rowIndex = 0; rowIndex < [weakSelf.medias count]; rowIndex++)
             {
                 NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                 [weakSelf.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                           withRowAnimation:UITableViewRowAnimationFade];
             }
             [self.tableView endUpdates];
             
             [self.refreshControl endRefreshing];
             self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
         }];
        
        // Delete all rows
        [self.tableView beginUpdates];
        for (NSInteger rowIndex = 0; rowIndex < mediasNumber; rowIndex++)
        {
            NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

- (void)loadMoreMediasAction:(id)sender
{
    if (!self.mediasRootViewController.isFetchingMedias)
    {
        self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeLoading;
        
        NSInteger mediaNumber = [self.medias count];
        __weak LTMediasListViewController* weakSelf = self;
        [self.mediasRootViewController loadMoreMediaWithCompletion:^(NSArray *medias, NSError *error)
         {
             [self.tableView beginUpdates];
             for (NSInteger rowIndex = mediaNumber; rowIndex < [weakSelf.medias count]; rowIndex++)
             {
                 NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                 [weakSelf.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                           withRowAnimation:UITableViewRowAnimationFade];
             }
             [self.tableView endUpdates];
             
             [self.refreshControl endRefreshing];
             self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
         }];
    }
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
    return [self.medias count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTMedia *media = self.medias[indexPath.row];
    LTMediaListCell* cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:LTMediaListCellIdentifier];
    if (!cell)
    {
        cell = [LTMediaListCell mediaListCell];
    }
    
    cell.media = media;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTMedia *media = self.medias[indexPath.row];

    if(media != nil)
    {
        LTMediaDetailViewController* mediaDetailViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"LTMediaDetailViewController"];
        mediaDetailViewController.media = media;
        mediaDetailViewController.title = media.mediaTitle;
        [self.navigationController pushViewController:mediaDetailViewController
                                             animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LTMediasListCommonRowHeight;
}

@end
