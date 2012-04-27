//
//  MapViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 26/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    BOOL shouldZoomToUserLocation_;
    IBOutlet MKMapView * mapView_;
    NSMutableArray * annotations_;
}

@end
