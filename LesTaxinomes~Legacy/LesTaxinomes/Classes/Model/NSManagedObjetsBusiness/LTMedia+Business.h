//
//  Media+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMedia.h"

#import <MapKit/MapKit.h>

@interface LTMedia (Business) <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (LTMedia *)mediaWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (LTMedia *)mediaLargeURLWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;

@end
