//
//  MediaLocalisationPickerViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 16/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MediaLocalisationPickerViewController.h"
#import "Annotation.h"

@interface MediaLocalisationPickerViewController () <MKMapViewDelegate> {
    UIBarButtonItem* rightBarButton_;
}
@property (nonatomic, retain) IBOutlet MKMapView* mapView;
- (void)refreshMap;
@end

@implementation MediaLocalisationPickerViewController
@synthesize delegate = delegate_;
@synthesize mapView = mapView_;
@synthesize location = location_;

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common.ok") style:UIBarButtonItemStylePlain target:self action:@selector(okButtonButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:NO];
    if (location_) {
        [self refreshMap];
    } else {
        self.location = [[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0] autorelease];
        [mapView_ setRegion:MKCoordinateRegionMake(location_.coordinate, MKCoordinateSpanMake(180.0, 180.0))];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [rightBarButton_ release];
    rightBarButton_ = nil;
    self.mapView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [location_ release];
    [mapView_ release];
    [rightBarButton_ release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)okButtonButtonPressed:(UIBarButtonItem *)sender {
    if ([delegate_ respondsToSelector:@selector(mediaLocationPicker:didPickLocation:)]
        && location_) {
        [delegate_ mediaLocationPicker:self didPickLocation:location_];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setLocation:(CLLocation *)location {
    [location_ release];
    location_ = [location retain];
    
    [self refreshMap];
}

- (void)refreshMap {
    
    if (mapView_) {
        [mapView_ removeAnnotations:mapView_.annotations];
        
        Annotation* annotation = [[Annotation alloc] init];
        annotation.coordinate = location_.coordinate;
        annotation.title = TRANSLATE(@"media_location_picker.drag_me");
        mapView_.showsUserLocation = YES;
        [mapView_ addAnnotation:annotation];
        [mapView_ selectAnnotation:annotation animated:YES];
        [mapView_ setRegion:MKCoordinateRegionMake(location_.coordinate, MKCoordinateSpanMake(18.0, 18.0))];
        [annotation release];
    }
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isEqual:mapView_.userLocation]) {
        return nil;
    }
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]
                                    initWithAnnotation:annotation reuseIdentifier:nil];
    [pinView setDraggable:YES];
    [pinView setAnimatesDrop:YES];
    [pinView setPinColor:MKPinAnnotationColorGreen];
    return [pinView autorelease];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (oldState == MKAnnotationViewDragStateDragging
        && newState == MKAnnotationViewDragStateEnding) {
        
        [location_ release];
        location_ = [[CLLocation alloc] initWithLatitude:annotationView.annotation.coordinate.latitude 
                                               longitude:annotationView.annotation.coordinate.longitude];
    }
}

@end
