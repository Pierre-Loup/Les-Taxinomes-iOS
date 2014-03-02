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

+ (LTMedia *)mediaWithXMLRPCResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*) context error:(NSError**)error;
+ (LTMedia *)mediaLargeURLWithXMLRPCResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*)context error:(NSError**)error;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
