//
//  LTMediasGridViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMediasGridViewController.h"

// UI
#import "LTMediaDetailViewController.h"
#import "LTCollectionViewFlowLayout.h"
#import "LTMediaCollectionCell.h"
#import "LTLoadMoreFooterView.h"

// Model
#import "LTMedia.h"

typedef void (^UICollectionViewUpdateBlock)();

static NSString* const LTMediasGridViewControllerFooterIdentifier = @"LTMediasGridViewControllerFooterIdentifier";

@interface LTMediasGridViewController ()
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@property (nonatomic, strong) NSMutableSet *updates;

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
    [self.refreshControl addTarget:self.delegate
                            action:@selector(refreshMedias)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    [self.collectionView registerClass:[LTMediaCollectionCell class]
            forCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]];
    
    [self.collectionView registerClass:[LTLoadMoreFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LTMediasGridViewControllerFooterIdentifier];
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
    
    LTMedia* media = [self.dataSource.mediasResultController objectAtIndexPath:topVisibleCellIndexPath];
    return media;
}

- (void)setFirstVisibleMedia:(LTMedia *)firstVisibleMedia
{
    NSIndexPath* indexPath = [self.dataSource.mediasResultController indexPathForObject:firstVisibleMedia];

    if (self.dataSource.mediasResultController.fetchedObjects.count > indexPath.row)
    {
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:NO];
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [[self.dataSource.mediasResultController fetchedObjects] count];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTMediaCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]
                                                                            forIndexPath:indexPath];
    cell.media = [self.dataSource.mediasResultController objectAtIndexPath:indexPath];
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
        [self.footerView.loadMoreButton addTarget:self.delegate
                                           action:@selector(loadMoreMedias)
                                 forControlEvents:UIControlEventTouchUpInside];
        view = self.footerView;
    }
    
    return view;
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTMedia *media = [self.dataSource.mediasResultController objectAtIndexPath:indexPath];
    
    if(media != nil)
    {
        LTMediaDetailViewController* mediaDetailViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"LTMediaDetailViewController"];
        mediaDetailViewController.media = media;
        mediaDetailViewController.title = media.mediaTitle;
        [self.navigationController pushViewController:mediaDetailViewController
                                             animated:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.updates = [NSMutableSet new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UICollectionViewUpdateBlock update;
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            update = ^
            {
                [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            };
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            update = ^
            {
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            };
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            update = ^
            {
                //((LTMediaCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath]).media = media;
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            };
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            update = ^
            {
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            };
            break;
        }
    }
    [self.updates addObject:update];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^
    {
        for (UICollectionViewUpdateBlock update in self.updates) update();
    }
    completion:^(BOOL finished)
    {
        self.updates = nil;
    }];
}

@end
