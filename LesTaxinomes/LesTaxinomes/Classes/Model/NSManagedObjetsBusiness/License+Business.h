//
//  License+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "License.h"

@interface License (Business)

+ (License*)licenseWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (License*)licenseWithIdentifier:(NSNumber*)identifier;
+ (License*)defaultLicense;

@end
