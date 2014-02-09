//
//  MapViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "LTConnectionManager.h"
#import "LTViewController.h"

@interface MapViewController : LTViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, readonly) id<MKAnnotation> referenceAnnotation;
@property (strong, nonatomic) IBOutlet MKMapView * mapView;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end