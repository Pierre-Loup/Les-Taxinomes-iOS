//
//  MapViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMapViewController.h"
// VCs
#import "LTMediaDetailViewController.h"
// MODEL
#import "LTMedia+Business.h"

#define kPinAnnotationIdentifier @"pin"

@interface LTMapViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) NSInteger searchStartIndex;
@property (nonatomic, strong) UIBarButtonItem* reloadBarButton;
@property (nonatomic, strong) UIBarButtonItem* scanBarButton;
@property (nonatomic, strong) NSFetchedResultsController* mediasResultController;

@property (nonatomic, assign) NSInteger insertedMedias;
@property (nonatomic, assign) NSInteger updatedMedias;

@end

@implementation LTMapViewController

////////////////////////////////////////////////////////////////////////////////
# pragma mark - Superclass overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _T(@"common.map");
    
    self.scanBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(scanButtonAction:)];
    [self.navigationItem setRightBarButtonItem:self.scanBarButton];
    
    
    self.searchStartIndex = 0;
    self.mapView.delegate = self;
    
    // Display the reference location of the map if already set
    if (self.referenceAnnotation)
    {
        [self.mapView addAnnotation:self.referenceAnnotation];
        [self.mapView setRegion:MKCoordinateRegionMake(self.referenceAnnotation.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
    }
    else
    {
        self.mapView.showsUserLocation = YES;
        [SVProgressHUD show];
    }
}

- (void)viewDidUnload
{
    self.reloadBarButton = nil;
    self.scanBarButton = nil;
    self.mapView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.referenceAnnotation isKindOfClass:[MKUserLocation class]]
        || !self.referenceAnnotation)
    {
        self.mapView.showsUserLocation = YES;
        [self setupLocationManager];
    }
    [self resetMediasResultController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.showsUserLocation = NO;
    [self.locationManager stopMonitoringSignificantLocationChanges];
    self.locationManager = nil;
    self.mediasResultController = nil;
    [SVProgressHUD dismiss];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
#pragma mark Properties

- (void)resetMediasResultController
{
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status == %@",@"publie"];
        self.mediasResultController = [LTMedia MR_fetchAllSortedBy:@"date"
                                                         ascending:NO
                                                     withPredicate:predicate
                                                           groupBy:nil
                                                          delegate:self
                                                         inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        // Start monitoring the user location changes
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

#pragma mark Actions

- (IBAction)refreshButtonAction:(id)sender
{
    self.searchStartIndex = 0;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.referenceAnnotation];
    [self.mapView setRegion:MKCoordinateRegionMake(self.referenceAnnotation.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
    [self loadMoreCloseMedias];
}

- (IBAction)scanButtonAction:(id)sender
{
    [self loadMoreCloseMedias];
}

- (void)loadMoreCloseMedias
{
    if (self.referenceAnnotation)
    {
        self.reloadBarButton.enabled = NO;
        self.scanBarButton.enabled = NO;
        [SVProgressHUD show];
        
        NSRange range;
        range.location = self.searchStartIndex;
        range.length = LTMediasLoadingStep;
        
        CLLocation* searchLocation = [[CLLocation alloc] initWithLatitude:self.referenceAnnotation.coordinate.latitude
                                                                longitude:self.referenceAnnotation.coordinate.longitude];
        
        [[LTConnectionManager sharedManager] getMediasSummariesByDateForAuthor:nil
                                                                        nearLocation:searchLocation
                                                                           withRange:range
        responseBlock:^(NSArray *medias, NSError *error)
        {
            self.searchStartIndex += (self.insertedMedias + self.updatedMedias);
            if (!error)
            {
                [SVProgressHUD dismiss];
                self.reloadBarButton.enabled = YES;
                self.scanBarButton.enabled = YES;
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:nil];
                self.reloadBarButton.enabled = YES;
                self.scanBarButton.enabled = YES;
            }
        }];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.referenceAnnotation
        && self.mapView.showsUserLocation
        && CLLocationCoordinate2DIsValid(userLocation.coordinate))
    {
        _referenceAnnotation = self.mapView.userLocation;
        [self.mapView setRegion:MKCoordinateRegionMake(self.referenceAnnotation.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
        [self loadMoreCloseMedias];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // Display the default annotation view for the reference annotation and the user location
    if ([annotation isEqual:self.referenceAnnotation]
        || [annotation isEqual:mapView.userLocation])
    {
        return nil;
    }
    
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [annotationView setAnimatesDrop:YES];
    [annotationView setAnnotation:annotation];
    [annotationView setUserInteractionEnabled:YES];
    [annotationView setCanShowCallout:YES];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[LTMedia class]])
    {
        LTMedia *media = (LTMedia *)view.annotation;
        LTMediaDetailViewController* mediaDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LTMediaDetailViewController"];

        mediaDetailViewController.media = media;
        mediaDetailViewController.title = _T(@"common.media");
        [self.navigationController pushViewController:mediaDetailViewController animated:YES];
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations lastObject];
    if (self.referenceAnnotation
        && self.mapView.showsUserLocation
        && CLLocationCoordinate2DIsValid(newLocation.coordinate))
    {
        
        self.reloadBarButton.enabled = NO;
        self.scanBarButton.enabled = NO;
        [SVProgressHUD showWithStatus:_T(@"explore.positionupdate.hud.status")];
        
        NSRange range;
        range.location = 0;
        range.length = LTMediasLoadingStep;
        
        [[LTConnectionManager sharedManager] getMediasSummariesByDateForAuthor:nil
                                                                  nearLocation:newLocation
                                                                     withRange:range
                                                                 responseBlock:^(NSArray *medias, NSError *error)
         {
             if (!error)
             {
                 if (self.insertedMedias != 0)
                 {
                     self.searchStartIndex = self.insertedMedias + self.updatedMedias;
                 }
                 
                 [SVProgressHUD dismiss];
                 self.reloadBarButton.enabled = YES;
                 self.scanBarButton.enabled = YES;
             }
             else
             {
                 [SVProgressHUD showErrorWithStatus:nil];
                 self.reloadBarButton.enabled = YES;
                 self.scanBarButton.enabled = YES;
             }
         }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.insertedMedias = 0;
    self.updatedMedias = 0;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    LTMedia *media = (LTMedia *)anObject;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            self.insertedMedias++;
        case NSFetchedResultsChangeUpdate:
            self.updatedMedias++;
            [self.mapView addAnnotation:media];
            break;
        case NSFetchedResultsChangeDelete:
            [self.mapView removeAnnotation:media];
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    CGFloat maxLatDif = 0;
    CGFloat maxLonDif = 0;
    
    NSArray* medias = [self.mapView annotations];
    for (LTMedia* media in medias)
    {
        CGFloat latDif = fabs(fabs(self.referenceAnnotation.coordinate.latitude) - fabs(media.coordinate.latitude));
        CGFloat lonDif = fabs(fabs(self.referenceAnnotation.coordinate.longitude) - fabs(media.coordinate.longitude));
        if (latDif > maxLatDif)
        {
            maxLatDif = latDif;
        }
        
        if (lonDif > maxLonDif)
        {
            maxLonDif = lonDif;
        }
    }
    
    CGFloat lonDelta = MIN(2.1*maxLonDif, 360.0);
    CGFloat latDelta = MIN(2.1*maxLatDif, 180.0);
    
    // Display the closest region with all the medias displayed
    [self.mapView setRegion:MKCoordinateRegionMake(self.referenceAnnotation.coordinate, MKCoordinateSpanMake(latDelta, lonDelta)) animated:YES];
}

@end
