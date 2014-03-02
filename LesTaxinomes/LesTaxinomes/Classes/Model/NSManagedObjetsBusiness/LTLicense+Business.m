//
//  License+Business.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTLicense+Business.h"

@implementation LTLicense (Business)

+ (LTLicense *)licenseWithXMLRPCResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    if(response == nil){
        return nil;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [(NSString*)[response objectForKey:@"id"] intValue]];
    LTLicense *license = [LTLicense MR_findFirstWithPredicate:predicate inContext:context];
    
    if (!license) {
        license = [LTLicense MR_createInContext:context];
        license.identifier = [NSNumber numberWithInt:[(NSString*)[response objectForKey:@"id"] intValue]];
    }
    
    license.name = [response objectForKey:@"name"];
    license.icon = [response objectForKey:@"icon"];
    license.link = [response objectForKey:@"link"];
    license.desc = [response objectForKey:@"description"];
    license.abbr = [response objectForKey:@"addr"];
    
    return license;
}

+ (LTLicense *)licenseWithIdentifier:(NSNumber*)identifier inContext:(NSManagedObjectContext*)context
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [identifier integerValue]];
    LTLicense *license = [LTLicense MR_findFirstWithPredicate:predicate inContext:context];
    return  license;
}

+ (LTLicense *)defaultLicenseInContext:(NSManagedObjectContext*)context
{
    return [LTLicense licenseWithIdentifier:[NSNumber numberWithInt:8] inContext:context];
}


@end
