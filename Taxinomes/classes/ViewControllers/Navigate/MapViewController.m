//
//  MapViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

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
    shouldZoomToUserLocation_ = YES;
    mapView_.delegate = self;
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldZoomToUserLocation_) {
        [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(5.0, 5.0)) animated:YES];
    }
    shouldZoomToUserLocation_ = NO;
}
@end
