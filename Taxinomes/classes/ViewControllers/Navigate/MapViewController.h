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
    LTConnectionManager* connectionManager_;
    CLLocationManager* locationManager_;
    BOOL shouldZoomToUserLocation_;
    NSInteger searchStarIndex_;
    
    UIBarButtonItem* reloadBarButton_;
    UIBarButtonItem* scanBarButton_;
}


@property (retain, nonatomic) IBOutlet MKMapView * mapView;

@end
