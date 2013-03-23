//
//  LTMediasGridViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMediasGridViewController.h"
#import "LTCollectionViewFlowLayout.h"
#import "LTMediaCollectionCell.h"
#import "LTMediasLoadMoreFooterView.h"

@interface LTMediasGridViewController ()
@property (nonatomic, strong) LTMediasLoadMoreFooterView* footerView;
@end

@implementation LTMediasGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[LTMediaCollectionCell class]
            forCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]];
    
    CGRect footerViewFrame = CGRectNull;
    footerViewFrame.size = ((LTCollectionViewFlowLayout*)self.collectionView.collectionViewLayout).footerReferenceSize;
    self.footerView = [[LTMediasLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self.delegate
                                  action:@selector(loadMoreMedias)
                        forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

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

@end
