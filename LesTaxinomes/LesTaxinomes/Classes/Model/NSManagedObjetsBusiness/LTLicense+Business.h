//
//  License+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTLicense.h"

@interface LTLicense (Business)

+ (LTLicense *)licenseWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (LTLicense *)licenseWithIdentifier:(NSNumber*)identifier;
+ (LTLicense *)defaultLicense;

@end
