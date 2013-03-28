//
//  License+Business.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "License+Business.h"

@implementation License (Business)

+ (License *)licenseWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error {
    if(response == nil){
        return nil;
    }
    
    NSManagedObjectContext* context = [NSManagedObjectContext contextForCurrentThread];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [(NSString*)[response objectForKey:@"id"] intValue]];
    License* license = [License findFirstWithPredicate:predicate inContext:context];
    
    if (!license) {
        license = [License createInContext:context];
        license.identifier = [NSNumber numberWithInt:[(NSString*)[response objectForKey:@"id"] intValue]];
    }
    
    license.name = [response objectForKey:@"name"];
    license.icon = [response objectForKey:@"icon"];
    license.link = [response objectForKey:@"link"];
    license.desc = [response objectForKey:@"description"];
    license.abbr = [response objectForKey:@"addr"];
    
    return license;
}

+ (License *)licenseWithIdentifier:(NSNumber*)identifier {
    NSManagedObjectContext* context = [NSManagedObjectContext contextForCurrentThread];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [identifier integerValue]];
    License* license = [License findFirstWithPredicate:predicate inContext:context];
    return  license;
}

+ (License *)defaultLicense {
    return [License licenseWithIdentifier:[NSNumber numberWithInt:8]];
}


@end
