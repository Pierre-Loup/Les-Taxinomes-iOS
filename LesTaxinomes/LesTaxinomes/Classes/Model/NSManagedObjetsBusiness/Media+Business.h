//
//  Media+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "Media.h"

#import <MapKit/MapKit.h>

@interface Media (Business) <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (Media *)mediaWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (Media *)mediaLargeURLWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;

@end
