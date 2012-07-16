//
//  MediaLocalisationPickerViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 16/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MediaLocalisationPickerViewController.h"
#import "Annotation.h"

@interface MediaLocalisationPickerViewController ()

@end

@implementation MediaLocalisationPickerViewController
@synthesize delegate = delegate_;
@synthesize mapView = mapView_;

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common_OK") style:UIBarButtonItemStylePlain target:self action:@selector(okButtonButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:NO];
    
    Annotation* annotation = [[Annotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    annotation.title = TRANSLATE(@"media_location_picker.drag_me");
    [mapView_ addAnnotation:annotation];
    [mapView_ selectAnnotation:annotation animated:NO];
    [annotation release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [rightBarButton_ release];
    [mapView_ release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [location_ release];
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
    return pinView;
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
