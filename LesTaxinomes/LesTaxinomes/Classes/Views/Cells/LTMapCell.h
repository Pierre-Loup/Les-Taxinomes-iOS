//
//  MapCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 11/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LTMapCell : UITableViewCell

@property (nonatomic, readonly) IBOutlet MKMapView* mapView;

+ (NSString *)reuseIdentifier;
- (NSString *)reuseIdentifier;

@end
