//
//  LTAuthorsViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAuthorsViewController.h"

// CORE
#import "LTConnectionManager.h"
// UI
#import "SRRefreshView.h"
// MODEL
#import "Author.h"

@interface LTAuthorsViewController ()
@property (nonatomic, strong) NSFetchedResultsController* authorsResultController;
@end

@implementation LTAuthorsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSRange range = {0,10};
	[[LTConnectionManager sharedConnectionManager] getShortAuthorsWithRange:range
                                                                withSortKey:LTAuthorsSortAlphabeticOrder
    responseBlock:^(NSArray *authors, NSError *error) {
        NSLog(@"authors: %@", authors);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//- (NSFetchedResultsController*)mediasResultController
//{
//    if (!_authorsResultController) {
//        NSPredicate* predicate = nil;
//        if (self.currentUser) {
//            predicate = [NSPredicate predicateWithFormat:@"status == %@ && author == %@",@"publie",self.currentUser];
//        } else {
//            predicate = [NSPredicate predicateWithFormat:@"status == %@",@"publie"];
//        }
//        
//        _authorsResultController = [Authors fetchAllSortedBy:@"date"
//                                                ascending:NO
//                                            withPredicate:predicate
//                                                  groupBy:nil
//                                                 delegate:nil];
//    }
//    return _authorsResultController;
//}
//
//////////////////////////////////////////////////////////////////////////////////
//#pragma mark - UICollectionViewDataSource
//
//- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section
//{
//    return [[self.dataSource.mediasResultController fetchedObjects] count];
//}
//
//
//// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    LTMediaCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LTMediaCollectionCell reuseIdentifier]
//                                                                            forIndexPath:indexPath];
//    cell.media = [self.dataSource.mediasResultController objectAtIndexPath:indexPath];
//    return cell;
//}
//
//- (PSTCollectionReusableView *)collectionView:(PSTCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    PSTCollectionReusableView* view;
//    if ([kind isEqualToString:PSTCollectionElementKindSectionFooter]) {
//        
//        view = self.footerView;
//    }
//    
//    return view;
//    
//}
//
//////////////////////////////////////////////////////////////////////////////////
//#pragma mark - UICollectionViewDelegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.slimeView scrollViewDidScroll];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self.slimeView scrollViewDidEndDraging];
//}
//
//////////////////////////////////////////////////////////////////////////////////
//#pragma mark - SRRRefreshViewDelegate
//
//- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
//{
//    [self.delegate refreshMedias];
//}

@end
