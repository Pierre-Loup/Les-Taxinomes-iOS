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
// VCs
#import "LTMediasRootViewController.h"
// MODEL
#import "LTAuthor.h"

static NSString* const LTAuthorsViewControllerFooterIdentifier = @"LTAuthorsViewControllerFooterIdentifier";
static NSString* const LTMediasRootViewControllerSegueId = @"LTMediasRootViewControllerSegueId";

@interface LTAuthorsViewController ()
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@property (nonatomic, strong) NSFetchedResultsController* authorsResultController;
@property (nonatomic, assign) NSInteger searchIndex;
@property (nonatomic, assign) LTAuthorsSortType sortType;
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
    
    self.searchIndex = 0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAuthors)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    ((LTCollectionViewFlowLayout*)self.collectionView.collectionViewLayout).itemSize = CGSizeMake(70.f, 90.f);
    
    [self.collectionView registerClass:[LTAuthorCollectionCell class]
            forCellWithReuseIdentifier:[LTAuthorCollectionCell reuseIdentifier]];
    
    [self.collectionView registerClass:[LTLoadMoreFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LTAuthorsViewControllerFooterIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self.authorsResultController fetchedObjects] count] <= 1)
    {
        [self loadMoreAuthors];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.authorsResultController = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LTMediasRootViewControllerSegueId])
    {
        LTMediasRootViewController* homeVC = (LTMediasRootViewController*)segue.destinationViewController;
        if ([sender isKindOfClass:[LTAuthorCollectionCell class]])
        {
            LTAuthorCollectionCell* cell = (LTAuthorCollectionCell*)sender;
            homeVC.currentUser = cell.author;
        }
    }
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
    [self.refreshControl endRefreshing];
    self.footerView.displayMode = LTLoadMoreFooterViewDisplayModeLoading;
    
    NSRange authorsRange;
    authorsRange.location = self.searchIndex;
    authorsRange.length = LTAuthorsLoadingStep;
    
    __block LTAuthorsViewController* weakSelf = self;
    LTConnectionManager* connectionManager = [LTConnectionManager sharedManager];
    [connectionManager getAuthorsSummariesWithRange:authorsRange
                                    withSortKey:self.sortType
    responseBlock:^(NSArray *authors, NSError *error)
    {
        if (authors)
        {
            weakSelf.authorsResultController = nil;
            self.searchIndex += [authors count];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:_T(@"common.hud.failure")];
        }
        [weakSelf.collectionView reloadData];
        weakSelf.footerView.displayMode = LTLoadMoreFooterViewDisplayModeNormal;
    }];
}

- (void)refreshAuthors
{
    __block LTAuthorsViewController* weakSelf = self;
    
    self.searchIndex = 0;
    self.authorsResultController = nil;
    [weakSelf.collectionView reloadData];
    [weakSelf loadMoreAuthors];
}

#pragma mark Properties

- (NSFetchedResultsController*)authorsResultController
{
    if (!_authorsResultController) {
        
        NSString* sortAttribute = @"name";
        if (self.sortType == LTAuthorsSortBySignupDate) {
            sortAttribute = @"signupDate";
        }
        
        _authorsResultController = [LTAuthor MR_fetchAllSortedBy:sortAttribute
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

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [[self.authorsResultController fetchedObjects] count];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTAuthorCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LTAuthorCollectionCell reuseIdentifier]
                                                                            forIndexPath:indexPath];
    cell.author = [self.authorsResultController objectAtIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* view;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        
        self.footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:LTAuthorsViewControllerFooterIdentifier
                                                                         forIndexPath:indexPath];
        [self.footerView.loadMoreButton addTarget:self
                                           action:@selector(loadMoreAuthors)
                                 forControlEvents:UIControlEventTouchUpInside];
        view = self.footerView;
    }
    
    return view;
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTAuthorCollectionCell* cell = (LTAuthorCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:LTMediasRootViewControllerSegueId sender:cell];
}

@end
