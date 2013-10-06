//
//  MapCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 11/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "LTMapCell.h"

@interface LTMapCell () <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView* mapView;

@end

@implementation LTMapCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    MKPinAnnotationView* pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:@""];
    pinAnnotationView.canShowCallout = NO;
    pinAnnotationView.pinColor = MKPinAnnotationColorRed;
    return pinAnnotationView;
}

@end
