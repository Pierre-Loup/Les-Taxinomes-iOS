//
//  LTMediasGridViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "LTMediasGridViewController.h"

// UI
#import "LTMediaDetailViewController.h"
#import "LTCollectionViewFlowLayout.h"
#import "LTMediaCollectionCell.h"
#import "LTLoadMoreFooterView.h"

// Model
#import "LTMedia.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

static NSString* const LTMediasGridViewControllerFooterIdentifier = @"LTMediasGridViewControllerFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTMediasGridViewController ()
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@property (nonatomic, strong) NSMutableSet *updates;
@property (nonatomic, readonly) NSArray* medias;

@property (nonatomic, assign) BOOL shouldScrollToTop;

@end

@implementation LTMediasGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _T(@"tabbar.medias");
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAction:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    [self.collectionView registerClass:[LTMediaCollectionCell class]
            forCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]];
    
    [self.collectionView registerClass:[LTLoadMoreFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LTMediasGridViewControllerFooterIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.medias count] == 0)
    {
        [self loadMoreMediasAction:self];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.shouldScrollToTop)
    {
        CGPoint contentOffset = {0, -self.topBarOffset};
        self.collectionView.contentOffset = contentOffset;
        self.shouldScrollToTop = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (LTMedia *)firstVisibleMedia
{
    if (self.collectionView.visibleCells.count == 0)
    {
        return nil;
    }
    
    CGPoint top = {10, self.collectionView.contentOffset.y + self.collectionView.contentInset.top +10};
    NSIndexPath* topVisibleCellIndexPath = [self.collectionView indexPathForItemAtPoint:top];
    
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
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionTop
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
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

#pragma mark Properties

- (NSArray*)medias
{
    return self.mediasRootViewController.medias;
}

#pragma mark Actions

- (void)refreshAction:(id)sender
{
    NSInteger mediasNumber = [self.medias count];
    __weak LTMediasGridViewController* weakSelf = self;
    [self.mediasRootViewController refreshMediasWithCompletion:^(NSArray *medias, NSError *error)
     {
         [weakSelf.collectionView performBatchUpdates:^
          {
              for (NSInteger rowIndex = 0; rowIndex < [weakSelf.medias count]; rowIndex++)
              {
                  NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                  [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
              }
          }
                                           completion:^(BOOL finished)
          {
              [self.refreshControl endRefreshing];
              self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
          }];
     }];
    
    // Delete all rows
    [weakSelf.collectionView performBatchUpdates:^
     {
         for (NSInteger rowIndex = 0; rowIndex < mediasNumber; rowIndex++)
         {
             NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
             [weakSelf.collectionView deleteItemsAtIndexPaths:@[newIndexPath]];
         }
     }
     completion:^(BOOL finished){}];
}

- (void)loadMoreMediasAction:(id)sender
{
    self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeLoading;
    
    NSInteger mediaNumber = [self.medias count];
    __weak LTMediasGridViewController* weakSelf = self;
    [self.mediasRootViewController loadMoreMediaWithCompletion:^(NSArray *medias, NSError *error)
     {
         [weakSelf.collectionView performBatchUpdates:^
          {
              for (NSInteger rowIndex = mediaNumber; rowIndex < [weakSelf.medias count]; rowIndex++)
              {
                  NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                  [weakSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
              }
          }
          completion:^(BOOL finished)
          {
              [self.refreshControl endRefreshing];
              self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
          }];
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.medias count];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTMediaCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]
                                                                            forIndexPath:indexPath];
    cell.media = self.medias[indexPath.row];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* view;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        
        self.footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:LTMediasGridViewControllerFooterIdentifier
                                                                         forIndexPath:indexPath];
        [self.footerView.loadMoreButton addTarget:self
                                           action:@selector(loadMoreMediasAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
        view = self.footerView;
    }
    
    return view;
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
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

@end
