//
//  MapViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "LTConnectionManager.h"
#import "LTViewController.h"

@interface MapViewController : LTViewController <MKMapViewDelegate, CLLocationManagerDelegate, LTConnectionManagerDelegate> {
    
    CLLocationManager* locationManager_;    
    NSInteger searchStartIndex_;
    
    //UI
    UIBarButtonItem* reloadBarButton_;
    UIBarButtonItem* scanBarButton_;
}

@property (retain, readonly) id<MKAnnotation> referenceAnnotation;
@property (retain, nonatomic) IBOutlet MKMapView * mapView;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
