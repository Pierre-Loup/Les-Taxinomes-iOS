//
//  License+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTLicense.h"

@interface LTLicense (Business)

@property (nonatomic, readonly) UIImage* licenseImage;

+ (LTLicense *)licenseWithXMLRPCResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*)context error:(NSError**)error;
+ (LTLicense *)licenseWithIdentifier:(NSNumber*)identifier inContext:(NSManagedObjectContext*)context;
+ (LTLicense *)defaultLicenseInContext:(NSManagedObjectContext*)context;

@end
