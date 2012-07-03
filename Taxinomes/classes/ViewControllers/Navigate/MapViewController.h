//
//  MapViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "LTConnectionManager.h"
#import "LTViewController.h"

@interface MapViewController : LTViewController <MKMapViewDelegate, LTConnectionManagerDelegate> {
    LTConnectionManager * connectionManager_;
    BOOL shouldZoomToUserLocation_;
    NSMutableArray * medias_;
}


@property (retain, nonatomic) IBOutlet MKMapView * mapView;

@end
