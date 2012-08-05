//
//  MapViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "MapViewController.h"
#import "MediaDetailViewController.h"

#define kPinAnnotationIdentifier @"pin"

@interface MapViewController ()
- (void)loadMoreCloseMedias;
@end

@implementation MapViewController
@synthesize mapView = mapView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [mapView_ release];
    [locationManager_ release];
    [reloadBarButton_ release];
    [scanBarButton_ release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    connectionManager_ =  [LTConnectionManager sharedConnectionManager];
    
    reloadBarButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction:)];
    [self.navigationItem setRightBarButtonItem:reloadBarButton_];
    scanBarButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(scanButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:scanBarButton_];
    
    
    shouldZoomToUserLocation_ = YES;
    searchStarIndex_ = 0;
    mapView_.delegate = self;
    mapView_.showsUserLocation = YES;
    if ([CLLocationManager locationServicesEnabled]
        && [CLLocationManager significantLocationChangeMonitoringAvailable]) {
        locationManager_ = [[CLLocationManager alloc] init];
        [locationManager_ setDelegate:self];
        [locationManager_ startMonitoringSignificantLocationChanges];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [reloadBarButton_ release];
    reloadBarButton_ = nil;
    [scanBarButton_ release];
    scanBarButton_ = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [mapView_ removeAnnotations:mapView_.annotations];
    searchStarIndex_ = 0;
    mapView_.showsUserLocation = YES;
}

#pragma mark - Actions

- (IBAction)refreshButtonAction:(id)sender {
    shouldZoomToUserLocation_ = YES;
    searchStarIndex_ = 0;
    [mapView_ removeAnnotations:mapView_.annotations];
    mapView_.showsUserLocation = NO;
    mapView_.showsUserLocation = YES;
}

- (IBAction)scanButtonAction:(id)sender {
    [self loadMoreCloseMedias];
}

- (void)loadMoreCloseMedias {
    if (mapView_.showsUserLocation) {
        reloadBarButton_.enabled = NO;
        scanBarButton_.enabled = NO;
        [self displayLoader];
        [connectionManager_ getShortMediasNearLocation:mapView_.userLocation.coordinate forAuthor:nil withLimit:kNbMediasStep startingAtRecord:searchStarIndex_ delegate:self];
    }
    
}

#pragma mark - MKMapViewDelegate
     
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    
 }

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (mapView_.showsUserLocation 
        && CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
        if (shouldZoomToUserLocation_) {
            [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.5, 0.5)) animated:YES];
            [self loadMoreCloseMedias];
            shouldZoomToUserLocation_ = NO;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    if ([annotation isEqual:mapView_.userLocation]) {
        return nil;
    }
    
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
    }
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [annotationView setAnimatesDrop:YES];
    [annotationView setAnnotation:annotation];
    [annotationView setUserInteractionEnabled:YES];
    [annotationView setCanShowCallout:YES];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[Media class]]) {
        Media * media = (Media *)view.annotation;
        MediaDetailViewController * mediaDetailViewController = [[MediaDetailViewController alloc] initWithNibName:@"MediaDetailViewController" 
                                                                                                            bundle:nil 
                                                                                                           mediaId:media.identifier];
        [self.navigationController pushViewController:mediaDetailViewController animated:YES];
        [mediaDetailViewController release];
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    searchStarIndex_ = 0;
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedShortMedias:(NSArray *)medias {
    BOOL shouldLoadMoreMedias = YES;
    for (Media* newMedia in medias) {
        __block Media* blockNewMedia = newMedia;
        NSInteger mediaFoundIndex = [mapView_.annotations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[Media class]]) {
                Media* displayedMedia = (Media *)obj;
                if ([blockNewMedia.identifier intValue] == [displayedMedia.identifier intValue]) {
                    *stop = YES;
                    return YES;
                }
            }
            return NO;
        }];
        if (mediaFoundIndex == NSNotFound) {
            shouldLoadMoreMedias = NO;
        } else {
            NSLog(@"Media already displayed");
        }
    }
    
    searchStarIndex_ += [medias count];
    if (shouldLoadMoreMedias) {
        [self loadMoreCloseMedias];
    } else {
        [mapView_ addAnnotations:medias];
        [self hideLoader];
        reloadBarButton_.enabled = YES;
        scanBarButton_.enabled = YES;
        
        
        MKUserLocation* userLocation = mapView_.userLocation;
        
        Media* lastMedia = (Media *)[medias lastObject];
        CGFloat latDelta = fabs(fabs(userLocation.coordinate.latitude) - fabs(lastMedia.coordinate.latitude));
        CGFloat lonDelta = fabs(fabs(userLocation.coordinate.longitude) - fabs(lastMedia.coordinate.longitude));
                
        [mapView_ setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(2*latDelta, 2*lonDelta)) animated:YES];
        LogDebug(@"user lon:%f lastMedia lon:%f",userLocation.coordinate.longitude,lastMedia.coordinate.longitude);

    }
}

- (void)didFailWithError:(NSError *)error {
    [self hideLoader];
    reloadBarButton_.enabled = YES;
    scanBarButton_.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
