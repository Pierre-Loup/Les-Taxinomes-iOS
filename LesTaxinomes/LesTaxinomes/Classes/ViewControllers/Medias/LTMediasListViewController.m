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
#import "LTMediaDetailViewController.h"
#import "LTMediaListCell.h"
#import "LTLoadMoreFooterView.h"
// Model
#import "LTMedia.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

#define LTMediaListCellIdentifier  @"MediasListCell"
#define LTMediasListCommonRowHeight  55.f

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
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Puff to refresh top view
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self.delegate
                            action:@selector(refreshMedias)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Footer load more view
    CGRect footerViewFrame = CGRectMake(0.f, 0.f,
                                        self.tableView.frame.size.width,
                                        LTMediasListCommonRowHeight);
    self.footerView = [[LTLoadMoreFooterView alloc] initWithFrame:footerViewFrame];
    [self.footerView.loadMoreButton addTarget:self.delegate
                                  action:@selector(loadMoreMedias)
                        forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = self.footerView;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (LTMedia *)firstVisibleMedia
{
    if (self.tableView.visibleCells.count == 0)
    {
        return nil;
    }
    
    CGPoint top = CGPointMake(0, self.tableView.contentOffset.y);
    NSIndexPath* topVisibleCellIndexPath = [self.tableView indexPathForRowAtPoint:top];

    LTMedia* media = [self.dataSource.mediasResultController objectAtIndexPath:topVisibleCellIndexPath];
    return media;
}

- (void)setFirstVisibleMedia:(LTMedia *)firstVisibleMedia
{
    NSIndexPath* indexPath = [self.dataSource.mediasResultController indexPathForObject:firstVisibleMedia];
    
    if (self.dataSource.mediasResultController.fetchedObjects.count > indexPath.row)
    {
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
    
    cell = [aTableView dequeueReusableCellWithIdentifier:LTMediaListCellIdentifier];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LTMediasListCommonRowHeight;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
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

@end
