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
#import "LTAuthorCollectionCell.h"
#import "LTCollectionViewFlowLayout.h"
#import "LTLoadMoreFooterView.h"
#import "SRRefreshView.h"
// MODEL
#import "LTAuthor.h"

@interface LTAuthorsViewController () <SRRefreshDelegate>
@property (nonatomic, strong) SRRefreshView* slimeView;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@property (nonatomic, strong) NSFetchedResultsController* authorsResultController;
@property (nonatomic) LTAuthorsSortType sortType;
@end

@implementation LTAuthorsViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setupVC];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupVC];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupVC];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupVC];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slimeView = [SRRefreshView new];
    self.slimeView.delegate = self;
    [self.collectionView addSubview:self.slimeView];
    ((LTCollectionViewFlowLayout*)self.collectionView.collectionViewLayout).itemSize = CGSizeMake(70.f, 90.f);
    
    [self.collectionView registerClass:[LTAuthorCollectionCell class]
            forCellWithReuseIdentifier:[LTAuthorCollectionCell reuseIdentifier]];
    
    CGRect footerViewFrame = CGRectNull;
    footerViewFrame.size = ((LTCollectionViewFlowLayout*)self.collectionView.collectionViewLayout).footerReferenceSize;
    self.footerView = [[LTLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self
                                       action:@selector(loadMoreAuthors)
                             forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self.authorsResultController fetchedObjects] count] == 0) {
        [self loadMoreAuthors];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.authorsResultController = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)setupVC
{
    _sortType = LTAuthorsSortAlphabeticOrder;
}

- (void)loadMoreAuthors
{
    self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeLoading;
    [self.slimeView endRefresh];
    
    NSRange authorsRange;
    authorsRange.location = [[self.authorsResultController fetchedObjects] count];
    authorsRange.length = kLTAuthorsLoadingStep;
    
    LTConnectionManager* connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager getAuthorsSummariesWithRange:authorsRange
                                    withSortKey:self.sortType
    responseBlock:^(NSArray *authors, NSError *error) {
        NSLog(@"authors: %@", authors);
        if (authors) {
            self.authorsResultController = nil;
        } else if ([error shouldBeDisplayed]) {
            [UIAlertView showWithError:error];
        } else {
            [self showErrorHudWithText:_T(@"common.hud.failure")];
        }
        [self.collectionView reloadData];
        self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
    }];
}

- (void)refreshAuthors
{
    self.authorsResultController = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        ;
        [LTAuthor truncateAll];
        NSError* error;
        [[NSManagedObjectContext contextForCurrentThread] save:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self loadMoreAuthors];
        });
    });
}

#pragma mark Properties

- (NSFetchedResultsController*)authorsResultController
{
    if (!_authorsResultController) {
        
        NSString* sortAttribute = @"name";
        if (self.sortType == LTAuthorsSortBySignupDate) {
            sortAttribute = @"signupDate";
        }
        
        _authorsResultController = [LTAuthor fetchAllSortedBy:sortAttribute
                                                ascending:YES
                                            withPredicate:nil
                                                  groupBy:nil
                                                 delegate:nil];
    }
    return _authorsResultController;
}

- (void)setSortType:(LTAuthorsSortType)sortType
{
    _sortType = sortType;
    self.authorsResultController = nil;
    [self.collectionView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [[self.authorsResultController fetchedObjects] count];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTAuthorCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LTAuthorCollectionCell reuseIdentifier]
                                                                            forIndexPath:indexPath];
    cell.author = [self.authorsResultController objectAtIndexPath:indexPath];
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
    [self refreshAuthors];
}

@end
