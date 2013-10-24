//
//  LTMediasGridViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMediasGridViewController.h"

// UI
#import "LTCollectionViewFlowLayout.h"
#import "LTMediaCollectionCell.h"
#import "LTLoadMoreFooterView.h"

static NSString* const kLTMediasGridViewControllerFooterIdentifier = @"kLTMediasGridViewControllerFooterIdentifier";

@interface LTMediasGridViewController ()
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@end

@implementation LTMediasGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _T(@"tabbar.medias");
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(slimeRefreshStartRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    [self.collectionView registerClass:[LTMediaCollectionCell class]
            forCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]];
    
    CGRect footerViewFrame = CGRectZero;
    footerViewFrame.size = ((LTCollectionViewFlowLayout*)self.collectionView.collectionViewLayout).footerReferenceSize;
    [self.collectionView registerClass:[LTLoadMoreFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kLTMediasGridViewControllerFooterIdentifier];
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
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:NO];
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

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
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        self.footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:kLTMediasGridViewControllerFooterIdentifier
                                                                         forIndexPath:indexPath];
        [self.footerView.loadMoreButton addTarget:self.delegate
                                           action:@selector(loadMoreMedias)
                                 forControlEvents:UIControlEventTouchUpInside];
        view = self.footerView;
    }
    
    return view;
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SRRRefreshViewDelegate

- (void)slimeRefreshStartRefresh:(UIRefreshControl *)refreshControl
{
    [self.delegate refreshMedias];
}

#pragma mark - NSFetchedResultsControllerDelegate


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UICollectionView * collectionView = self.collectionView;
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
