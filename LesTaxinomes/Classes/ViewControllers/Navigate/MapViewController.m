//
//  MapViewController.m
//  LesTaxinomes
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
@synthesize referenceAnnotation = referenceAnnotation_;
@synthesize mapView = mapView_;

# pragma mark - View Lifecycle

- (id)initWithAnnotation:(id<MKAnnotation>)annotation {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        referenceAnnotation_ = [annotation retain];
    }
    return self;
}

- (void)dealloc {
    [referenceAnnotation_ release];
    [mapView_ release];
    [locationManager_ release];
    [reloadBarButton_ release];
    [scanBarButton_ release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    scanBarButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(scanButtonAction:)];
    [self.navigationItem setRightBarButtonItem:scanBarButton_];
    
    
    searchStartIndex_ = 0;
    mapView_.delegate = self;
    
    // Display the reference location of the map if already set
    if (referenceAnnotation_) {
        [mapView_ addAnnotation:referenceAnnotation_];
        [mapView_ setRegion:MKCoordinateRegionMake(referenceAnnotation_.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
    } else {
        mapView_.showsUserLocation = YES;
        [self showHudForLoading];
    }
    
    // Start monitoring the user location changes
    if (!locationManager_
        && [CLLocationManager locationServicesEnabled]) {
        locationManager_ = [[CLLocationManager alloc] init];
        [locationManager_ setDelegate:self];
    }
}

- (void)viewDidUnload
{
    [reloadBarButton_ release];
    reloadBarButton_ = nil;
    [scanBarButton_ release];
    scanBarButton_ = nil;
    self.mapView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([referenceAnnotation_ isKindOfClass:[MKUserLocation class]]
        || !referenceAnnotation_) {
        mapView_.showsUserLocation = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    mapView_.showsUserLocation = NO;
}

#pragma mark - Actions

- (IBAction)refreshButtonAction:(id)sender {
    searchStartIndex_ = 0;
    [mapView_ removeAnnotations:mapView_.annotations];
    [mapView_ addAnnotation:referenceAnnotation_];
    [mapView_ setRegion:MKCoordinateRegionMake(referenceAnnotation_.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
    [self loadMoreCloseMedias];
}

- (IBAction)scanButtonAction:(id)sender {
    [self loadMoreCloseMedias];
}

- (void)loadMoreCloseMedias {
    if (referenceAnnotation_) {
        reloadBarButton_.enabled = NO;
        scanBarButton_.enabled = NO;
        [self showHudForLoading];
        
        NSRange range;
        range.location = searchStartIndex_;
        range.length = kNbMediasStep;
        
        CLLocation* searchLocation = [[[CLLocation alloc] initWithLatitude:self.referenceAnnotation.coordinate.latitude
                                                                longitude:self.referenceAnnotation.coordinate.longitude] autorelease];
        
        [[LTConnectionManager sharedConnectionManager] getShortMediasByDateForAuthor:nil
                                                                        nearLocation:searchLocation
                                                                           withRange:range
        responseBlock:^(NSArray *medias, NSError *error) {
            searchStartIndex_ += medias.count;
            if (medias &&
                [medias count] &&
                !error) {
                
                [mapView_ addAnnotations:medias];
                [self.hud hide:YES];
                reloadBarButton_.enabled = YES;
                scanBarButton_.enabled = YES;
                Media* lastMedia = (Media *)[medias lastObject];
                CGFloat latDif = fabs(fabs(referenceAnnotation_.coordinate.latitude) - fabs(lastMedia.coordinate.latitude));
                CGFloat lonDif = fabs(fabs(referenceAnnotation_.coordinate.longitude) - fabs(lastMedia.coordinate.longitude));
                CGFloat lonDelta = MIN(2*MAX(latDif, lonDif), 360.0);
                CGFloat latDelta = MIN(2*MAX(latDif, lonDif), 180.0);
                // Display the closest region with all the medias displayed
                [mapView_ setRegion:MKCoordinateRegionMake(referenceAnnotation_.coordinate, MKCoordinateSpanMake(latDelta, lonDelta)) animated:YES];
            } else if ([error shouldBeDisplayed]) {
                [UIAlertView showWithError:error];
                [self.hud hide:NO];
            }
        }];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!referenceAnnotation_
        && mapView_.showsUserLocation
        && CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
        referenceAnnotation_ = [mapView_.userLocation retain];
        [mapView_ setRegion:MKCoordinateRegionMake(referenceAnnotation_.coordinate, MKCoordinateSpanMake(1, 1)) animated:YES];
        [self loadMoreCloseMedias];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    // Display the default annotation view for the reference annotation and the user location
    if ([annotation isEqual:referenceAnnotation_]
        || [annotation isEqual:mapView.userLocation]) {
        return nil;
    }
    
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
        annotationView.pinColor = MKPinAnnotationColorGreen;
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
                                                                                                            bundle:nil];
        mediaDetailViewController.media = media;
        mediaDetailViewController.title = _T(@"common.media");
        [self.navigationController pushViewController:mediaDetailViewController animated:YES];
        [mediaDetailViewController release];
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    searchStartIndex_ = 0;
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
            LogDebug(@"Media already displayed");
        }
    }
    
    searchStartIndex_ += [medias count];
    if (shouldLoadMoreMedias) {
        [self loadMoreCloseMedias];
    } else {
        [mapView_ addAnnotations:medias];
        [self.hud hide:YES];
        reloadBarButton_.enabled = YES;
        scanBarButton_.enabled = YES;
        
        Media* lastMedia = (Media *)[medias lastObject];
        CGFloat latDif = fabs(fabs(referenceAnnotation_.coordinate.latitude) - fabs(lastMedia.coordinate.latitude));
        CGFloat lonDif = fabs(fabs(referenceAnnotation_.coordinate.longitude) - fabs(lastMedia.coordinate.longitude));
        CGFloat lonDelta = MIN(2*MAX(latDif, lonDif), 360.0);
        CGFloat latDelta = MIN(2*MAX(latDif, lonDif), 180.0);
        // Display the closest region with all the medias displayed
        [mapView_ setRegion:MKCoordinateRegionMake(referenceAnnotation_.coordinate, MKCoordinateSpanMake(latDelta, lonDelta)) animated:YES];
    }
}

- (void)didFailWithError:(NSError *)error {
    [self.hud hide:YES];
    reloadBarButton_.enabled = YES;
    scanBarButton_.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_T(@"alert_network_unreachable_title") message:_T(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:_T(@"common.ok") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
