//
//  MapViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MapViewController.h"
#import "MediaDetailViewController.h"

#define kPinAnnotationIdentifier @"pin"

@interface MapViewController ()
- (void)loadClosestMedias;
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
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * reloadBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction:)];
    [self.navigationItem setRightBarButtonItem:reloadBarButton animated:YES];
    [reloadBarButton release];
    
    mapView_.delegate = self;
    mapView_.showsUserLocation = YES;
    shouldZoomToUserLocation_ = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)refreshButtonAction:(id)sender {
    [self loadClosestMedias];
}

- (void)loadClosestMedias {
    connectionManager_ =  [LTConnectionManager sharedConnectionManager];
    [self displayLoader];
    [connectionManager_ getShortMediasNearLocation:mapView_.userLocation.coordinate forAuthor:nil withLimit:kNbMediasStep startingAtRecord:0 delegate:self];
}

#pragma mark - MKMapViewDelegate
     
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    
 }

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldZoomToUserLocation_) {
        if ([mapView_ isUserLocationVisible] && CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
            [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(5.0, 5.0)) animated:YES];
             [self loadClosestMedias];
            shouldZoomToUserLocation_ = NO;
        }
    }
    mapView_.showsUserLocation = YES;
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedShortMedias:(NSArray *)medias {
    [mapView_ addAnnotations:medias];
    [self hideLoader];
}

- (void)didFailWithError:(NSError *)error {
    [self hideLoader];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    [alert show];
    [alert release];
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

@end
