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
@property (nonatomic, strong) NSMutableSet* medias;

@end

@implementation LTMapViewController

////////////////////////////////////////////////////////////////////////////////
# pragma mark - Superclass overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _T(@"common.map");
    
    self.medias = [NSMutableSet new];
    
    self.scanBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(scanButtonAction:)];
    [self.navigationItem setRightBarButtonItem:self.scanBarButton];
    
    
    self.searchStartIndex = 0;
    self.mapView.delegate = self;
    
    // Display the reference location of the map if already set
    if (self.referenceAnnotation)
    {
        [self.mapView addAnnotation:self.referenceAnnotation];
    }
    else
    {
        self.mapView.showsUserLocation = YES;
        [SVProgressHUD show];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                      object:self queue:nil usingBlock:^(NSNotification *note)
     {
         [self stopMonitoringSignificantLocationChanges];
     }];
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
        if (self.referenceAnnotation &&
            self.locationManager)
        {
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.showsUserLocation = NO;
    [self stopMonitoringSignificantLocationChanges];
    self.locationManager = nil;
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    if (!self.view.window)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.medias removeAllObjects];
    }
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self stopMonitoringSignificantLocationChanges];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
#pragma mark Properties

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
        
        [[LTConnectionManager sharedManager] fetchMediasSummariesByDateForAuthor:nil
                                                                  nearLocation:searchLocation
                                                                  searchFilter:nil
                                                                     withRange:range
        responseBlock:^(NSArray *medias, NSError *error)
        {
            
            if (!error)
            {
                NSMutableSet* newMediasSet = [NSMutableSet setWithArray:medias];
                
                [newMediasSet minusSet:self.medias];
                [self.mapView addAnnotations: [newMediasSet allObjects]];
                
                self.searchStartIndex += [newMediasSet count];
                [self.medias addObjectsFromArray:[newMediasSet allObjects]];
                
                [self updateDisplayedRegion];
                
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
        && CLLocationCoordinate2DIsValid(userLocation.coordinate)
        && self.view.window)
    {
        _referenceAnnotation = self.mapView.userLocation;
        [self.mapView setRegion:MKCoordinateRegionMake(self.referenceAnnotation.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
        CLLocation* newLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                                longitude:userLocation.coordinate.longitude];
        [self updateLocation:newLocation];
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
        && CLLocationCoordinate2DIsValid(newLocation.coordinate)
        && ![SVProgressHUD isVisible]
        && self.view.window)
    {
        [self updateLocation:newLocation];
    }
}

- (void)updateLocation:(CLLocation*)newLocation
{
    self.reloadBarButton.enabled = NO;
    self.scanBarButton.enabled = NO;
    [SVProgressHUD showWithStatus:_T(@"explore.positionupdate.hud.status")];
    
    NSRange range;
    range.location = 0;
    range.length = LTMediasLoadingStep;
    
    [[LTConnectionManager sharedManager] fetchMediasSummariesByDateForAuthor:nil
                                                                nearLocation:newLocation
                                                                searchFilter:nil
                                                                   withRange:range
                                                               responseBlock:^(NSArray *medias, NSError *error)
     {
         if (!error)
         {
             // If there is at least one media that is already display it means that
             // there has been a significant location changer : reset de search start index
             NSMutableSet* newMediasSet = [NSMutableSet setWithArray:medias];
             [newMediasSet minusSet:self.medias];
             if ([newMediasSet count] == [medias count])
             {
                 self.searchStartIndex = [newMediasSet count];
                 if (!self.locationManager)
                 {
                     [self setupLocationManager];
                 }
             }
             
             [self.mapView addAnnotations: [newMediasSet allObjects]];
             [self.medias addObjectsFromArray:[newMediasSet allObjects]];
             
             [self updateDisplayedRegion];
             
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

- (void)updateDisplayedRegion
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

- (void)stopMonitoringSignificantLocationChanges
{
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

@end
