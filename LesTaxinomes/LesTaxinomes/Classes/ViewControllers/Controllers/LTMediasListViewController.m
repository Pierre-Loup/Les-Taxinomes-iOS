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

#import "LTMediasLoadMoreFooterView.h"
#import "MediaListCell.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

#define kLTMediaListCellIdentifier  @"MediasListCell"
#define kLTMediasListCommonRowHeight  55.f

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTMediasListViewController ()
@property (nonatomic, strong) LTMediasLoadMoreFooterView* footerView;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediasListViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclasse overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect footerViewFrame = CGRectMake(0.f, 0.f,
                                        self.tableView.frame.size.width,
                                        kLTMediasListCommonRowHeight);
    self.footerView = [[LTMediasLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self.delegate
                                  action:@selector(loadMoreMedias)
                        forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = self.footerView;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)commonInit {
    
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
    return [[self.dataSource.mediasResultController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Media* media = [self.dataSource.mediasResultController objectAtIndexPath:indexPath];
    MediaListCell* cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:kLTMediaListCellIdentifier];
    if (!cell) {
        cell = [MediaListCell mediaListCell];
    }
    
    cell.media = media;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Media *media = [self.mediasResultController objectAtIndexPath:indexPath];
//    if (self.dataSource.mediaDetailViewController) {
//        [self.dataSource.mediaDetailViewController.navigationController popToRootViewControllerAnimated:YES];
//        self.mediaDetailViewController.media = media;
//        self.dataSource.mediaDetailViewController.title = media.title;
//    } else {
//        if(media != nil){
//            MediaDetailViewController* mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" bundle:nil];
//            mediaDetailViewController.media = media;
//            mediaDetailViewController.title = media.title;
//            [self.navigationController pushViewController:mediaDetailViewController animated:YES];
//        }
//    }
}

/**
 * Asks the delegate for the height to use for a row in a specified location.
 *
 * @param The table-view object requesting this information.
 * @param indexPath: An index path that locates a row in tableView.
 * @return A floating-point value that specifies the height (in points) that row should be.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLTMediasListCommonRowHeight;
}
@end
