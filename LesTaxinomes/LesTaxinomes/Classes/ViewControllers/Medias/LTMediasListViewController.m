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
#import "LTMediaListCell.h"
#import "LTLoadMoreFooterView.h"
////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

#define kLTMediaListCellIdentifier  @"MediasListCell"
#define kLTMediasListCommonRowHeight  55.f

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTMediasListViewController ()
@property (nonatomic, strong) LTLoadMoreFooterView* footerView;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediasListViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclasse overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Puff to refresh top view
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(slimeRefreshStartRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Footer load more view
    CGRect footerViewFrame = CGRectMake(0.f, 0.f,
                                        self.tableView.frame.size.width,
                                        kLTMediasListCommonRowHeight);
    self.footerView = [[LTLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self.delegate
                                  action:@selector(loadMoreMedias)
                        forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = self.footerView;
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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (LTMedia *)firstVisibleMedia
{
    if (self.tableView.visibleCells.count == 0) {
        return nil;
    }
    
    NSArray* sortedVisibleCells = [self.tableView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(LTMediaListCell *cell1, LTMediaListCell *cell2) {
        NSIndexPath* indexPath1 = [self.tableView indexPathForCell:cell1];
        NSIndexPath* indexPath2 = [self.tableView indexPathForCell:cell2];
        
        if (indexPath1.row < indexPath2.row)
            return NSOrderedAscending;
        else if (indexPath1.row > indexPath2.row)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    LTMediaListCell* cell = sortedVisibleCells[0];
    return cell.media;
}

- (void)setFirstVisibleMedia:(LTMedia *)firstVisibleMedia
{
    NSIndexPath* indexPath = [self.dataSource.mediasResultController indexPathForObject:firstVisibleMedia];
    if (self.dataSource.mediasResultController.fetchedObjects.count > indexPath.row) {
        [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

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
    LTMedia *media = [self.dataSource.mediasResultController objectAtIndexPath:indexPath];
    LTMediaListCell* cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:kLTMediaListCellIdentifier];
    if (!cell) {
        cell = [LTMediaListCell mediaListCell];
    }
    
    cell.media = media;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    LTMedia *media = [self.mediasResultController objectAtIndexPath:indexPath];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLTMediasListCommonRowHeight;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    LTMedia *media = (LTMedia *)anObject;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            ((LTMediaListCell*)[tableView cellForRowAtIndexPath:indexPath]).media = media;
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - SRRRefreshViewDelegate

- (void)slimeRefreshStartRefresh:(UIRefreshControl *)refreshControl
{
    [self.delegate refreshMedias];
}

@end
