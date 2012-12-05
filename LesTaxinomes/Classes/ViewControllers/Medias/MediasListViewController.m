//
//  MediasListViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "MediasListViewController.h"

#import "Author.h"
#import "MediaDetailViewController.h"
#import "MediaListCell.h"
#import "Reachability.h"
#import "SpinnerCell.h"
#import "UIImageView+AFNetworking.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

#define kMediaListCellIdentifier  @"MediasListCell"
#define kSpinnerCellIdentifier  @"SpinnerCell"
#define kCommonRowAnnimation UITableViewRowAnimationNone

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface MediasListViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) IBOutlet MediaDetailViewController *mediaDetailViewController;
@property (nonatomic, retain) UIBarButtonItem* reloadBarButton;
@property (nonatomic, assign) MediaLoadingStatus mediaLoadingStatus;
@property (nonatomic, retain) NSFetchedResultsController* mediasListResultController;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation MediasListViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Supermethods overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)dealloc
{
    [_currentUser release];
    [_mediaDetailViewController release];
    [_reloadBarButton release];
    [_mediasListResultController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reloadBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction:)];
    [self.navigationItem setRightBarButtonItem:self.reloadBarButton animated:YES];
    
    self.mediaDetailViewController = (MediaDetailViewController *)[[[self.splitViewController.viewControllers lastObject] topViewController] retain];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mediaDetailViewController = nil;
    self.reloadBarButton = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [NSFetchedResultsController deleteCacheWithName:self.mediasListResultController.cacheName];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods

- (void)commonInit {
    self.mediaLoadingStatus = SUCCEED;
}

- (void)loadSynchMedias {
    NSRange mediasRange;
    mediasRange.location = [[self.mediasListResultController fetchedObjects] count];
    mediasRange.length = kNbMediasStep;
    LTConnectionManager* connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager getShortMediasByDateForAuthor:self.currentUser
                                        nearLocation:nil
                                           withRange:mediasRange
                                       responseBlock:^(NSArray *medias, NSError *error) {
                                           if (medias) {
                                               if ([medias count] == 0) {
                                                   self.mediaLoadingStatus = NOMORETOLOAD;
                                               } else {
                                                   self.mediaLoadingStatus = SUCCEED;
                                               }
                                               [self.hud hide:YES];
                                           } else if ([error shouldBeDisplayed]) {
                                               [UIAlertView showWithError:error];
                                               [self.hud hide:NO];
                                           }
                                           if (!self.reloadBarButton.enabled) {
                                               self.reloadBarButton.enabled = YES;
                                               [self.tableView reloadData];
                                           }
                                       }];
}

- (void)refreshButtonAction:(id)sender {
    
    self.reloadBarButton.enabled = NO;
    self.mediaLoadingStatus = PENDING;
    [self showHudForLoading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Media deleteAllMedias];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self loadSynchMedias];
        });
    });
}

#pragma mark Properties

- (NSFetchedResultsController*)mediasListResultController
{
    if (!_mediasListResultController) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status = %@",@"publie"];
        _mediasListResultController = [[Media fetchAllSortedBy:@"date"
                                                     ascending:NO
                                                 withPredicate:predicate
                                                       groupBy:nil
                                                      delegate:self] retain];
    }
    return _mediasListResultController;
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
    NSInteger nbMedias = [[self.mediasListResultController fetchedObjects] count];
    switch (self.mediaLoadingStatus) {
        case FAILED:
        case NOMORETOLOAD:
            return nbMedias;
            break;
        default:
            return (nbMedias+1);
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger nbMedias = [[self.mediasListResultController fetchedObjects] count];
    if([indexPath row] == nbMedias) {
        SpinnerCell* spinnerCell = [self.tableView dequeueReusableCellWithIdentifier:kSpinnerCellIdentifier];
        if (!spinnerCell) {
            spinnerCell =  [SpinnerCell spinnerCell];
        }
        [spinnerCell.spinner startAnimating];
        if ( self.mediaLoadingStatus == SUCCEED) {
            [self loadSynchMedias];
            self.mediaLoadingStatus = PENDING;
        }
        return spinnerCell;
    }
    
    Media* media = [self.mediasListResultController objectAtIndexPath:indexPath];
    MediaListCell* cell = nil;
    
    cell = [aTableView dequeueReusableCellWithIdentifier:kMediaListCellIdentifier];
    if (!cell) {
        cell = [MediaListCell mediaListCell];
    }
    
    cell.media = media;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *media = [self.mediasListResultController objectAtIndexPath:indexPath];
    if (self.mediaDetailViewController) {
        [self.mediaDetailViewController.navigationController popToRootViewControllerAnimated:YES];
        self.mediaDetailViewController.media = media;
        self.mediaDetailViewController.title = media.title;
    } else {
        if(media != nil){
            MediaDetailViewController* mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" bundle:nil];
            mediaDetailViewController.media = media;
            mediaDetailViewController.title = media.title;
            [self.navigationController pushViewController:mediaDetailViewController animated:YES];
            [mediaDetailViewController release];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (!self.reloadBarButton.enabled) {
        return;
    }
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (!self.reloadBarButton.enabled) {
        return;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:kCommonRowAnnimation];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:kCommonRowAnnimation];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!self.reloadBarButton.enabled) {
        return;
    }
    
    UITableView *tableView = self.tableView;
    Media* media = [self.mediasListResultController objectAtIndexPath:indexPath];
    UITableViewCell* cell;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:kCommonRowAnnimation];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:kCommonRowAnnimation];
            break;
            
        case NSFetchedResultsChangeUpdate:
            cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[MediaListCell class]]) {
                ((MediaListCell*)[tableView cellForRowAtIndexPath:indexPath]).media = media;
            } else {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:kCommonRowAnnimation];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:kCommonRowAnnimation];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:kCommonRowAnnimation];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!self.reloadBarButton.enabled) {
        return;
    }
    [self.tableView endUpdates];
}

@end
