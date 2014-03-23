//
//  LTSectionsViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTSectionsViewController.h"

#import "LTMediasRootViewController.h"
#import "LTSection.h"
#import "LTSectionCell.h"

static NSString* const LTSectionCellId = @"LTSectionCellId";

static NSString* const LTMediasRootViewControllerSegueId = @"LTMediasRootViewControllerSegueId";
static NSString* const LTSectionsViewControllerSegueId = @"LTSectionsViewControllerSegueId";

@interface LTSectionsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController* sectionsResultController;
@property (nonatomic, readonly) NSArray* sections;

@end

@implementation LTSectionsViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

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
    
    if (self.section)
    {
        self.title = self.section.title;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:LTSectionsViewControllerSegueId])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        LTSection* section = self.sections[indexPath.row];
        
        return ([section.children count] > 0);
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LTSectionsViewControllerSegueId])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        LTSection* section = self.sections[indexPath.row];
        
        LTSectionsViewController* sectionVC = (LTSectionsViewController*)segue.destinationViewController;
        sectionVC.section = section;
    }
    else
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil)
        {
            LTSection* section = self.sections[indexPath.row];
            LTMediasRootViewController* mediasVC = (LTMediasRootViewController*)segue.destinationViewController;
            mediasVC.section = section;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
#pragma mark Properties

- (NSFetchedResultsController*)sectionsResultController
{
    if (!_sectionsResultController)
    {
        NSPredicate* findPredicate;
        if (self.section)
        {
            findPredicate = [NSPredicate predicateWithFormat:@"self.parent == %@", self.section];
        }
        else
        {
            findPredicate = [NSPredicate predicateWithFormat:@"self.identifier == 1"];
        }
        
        NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
        _sectionsResultController = [LTSection MR_fetchAllSortedBy:@"identifier"
                                                         ascending:YES
                                                     withPredicate:findPredicate
                                                           groupBy:nil
                                                          delegate:self
                                                         inContext:context];
    }
    return _sectionsResultController;
}

- (NSArray*)sections
{
    return [self.sectionsResultController fetchedObjects];
}

#pragma mark Actions

- (void)infoButtonTouched:(UIButton*)infoButton
{
    [self performSegueWithIdentifier:LTMediasRootViewControllerSegueId sender:infoButton];
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
    return [self.sections count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTSection* section = self.sections[indexPath.row];
    
    LTSectionCell* cell = (LTSectionCell*)[aTableView dequeueReusableCellWithIdentifier:LTSectionCellId];

    cell.section = section;
    [cell.infoButton addTarget:self
                        action:@selector(infoButtonTouched:)
              forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView* tableView = self.tableView;
    LTSection* section = (LTSection*)anObject;
    
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
            ((LTSectionCell*)[tableView cellForRowAtIndexPath:indexPath]).section = section;
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
