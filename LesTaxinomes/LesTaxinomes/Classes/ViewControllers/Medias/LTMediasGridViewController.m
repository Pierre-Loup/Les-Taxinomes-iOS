//
//  LTMediasGridViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMediasGridViewController.h"

// UI
#import "SRRefreshView.h"
#import "LTCollectionViewFlowLayout.h"
#import "LTMediaCollectionCell.h"
#import "LTLoadMoreFooterView.h"

@interface LTMediasGridViewController () <SRRefreshDelegate>
@property (nonatomic, strong) SRRefreshView* slimeView;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@end

@implementation LTMediasGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _T(@"tabbar.medias");
    self.slimeView = [SRRefreshView new];
    self.slimeView.delegate = self;
    [self.collectionView addSubview:self.slimeView];
    
    [self.collectionView registerClass:[LTMediaCollectionCell class]
            forCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]];
    
    CGRect footerViewFrame = CGRectNull;
    footerViewFrame.size = ((LTCollectionViewFlowLayout*)self.collectionView.collectionViewLayout).footerReferenceSize;
    self.footerView = [[LTLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self.delegate
                                       action:@selector(loadMoreMedias)
                             forControlEvents:UIControlEventTouchUpInside];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (LTMedia *)firstVisibleMedia
{
    if (self.collectionView.visibleCells.count == 0) {
        return nil;
    }
    
    NSArray* sortedVisibleCells = [self.collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(LTMediaCollectionCell *cell1, LTMediaCollectionCell *cell2) {
        NSIndexPath* indexPath1 = [self.collectionView indexPathForCell:cell1];
        NSIndexPath* indexPath2 = [self.collectionView indexPathForCell:cell2];
        
        if (indexPath1.row < indexPath2.row)
            return NSOrderedAscending;
        else if (indexPath1.row > indexPath2.row)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    LTMediaCollectionCell* cell = sortedVisibleCells[0];
    return cell.media;
}

- (void)setFirstVisibleMedia:(LTMedia *)firstVisibleMedia
{
    NSIndexPath* indexPath = [self.dataSource.mediasResultController indexPathForObject:firstVisibleMedia];
    if (self.dataSource.mediasResultController.fetchedObjects.count > indexPath.row) {
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:PSTCollectionViewScrollPositionTop
                                            animated:NO];
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [[self.dataSource.mediasResultController fetchedObjects] count];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTMediaCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]
                                                                            forIndexPath:indexPath];
    cell.media = [self.dataSource.mediasResultController objectAtIndexPath:indexPath];
    return cell;
}

- (PSTCollectionReusableView *)collectionView:(PSTCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PSTCollectionReusableView* view;
    if ([kind isEqualToString:PSTCollectionElementKindSectionFooter]) {
        
        view = self.footerView;
    }
    
    return view;
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.slimeView scrollViewDidEndDraging];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SRRRefreshViewDelegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self.delegate refreshMedias];
}

#pragma mark - NSFetchedResultsControllerDelegate


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    PSTCollectionView * collectionView = self.collectionView;
    LTMedia *media = (LTMedia *)anObject;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            ((LTMediaCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath]).media = media;
            break;
            
        case NSFetchedResultsChangeMove:
            [collectionView performBatchUpdates:^{
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            } completion:^(BOOL finished) {}];
            break;
    }
}

@end
