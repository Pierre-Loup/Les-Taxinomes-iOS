//
//  License.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 27/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "License.h"
#import "Media.h"

@implementation License

@dynamic abbr;
@dynamic desc;
@dynamic icon;
@dynamic identifier;
@dynamic link;
@dynamic name;
@dynamic medias;

+ (License *)licenseWithXMLRPCResponse: (NSDictionary *) response {
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

+ (License *)licenseWithIdentifier: (NSNumber *)identifier {
    NSManagedObjectContext* context = [NSManagedObjectContext contextForCurrentThread];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [identifier integerValue]];
    License* license = [License findFirstWithPredicate:predicate inContext:context];
    return  license;
}

+ (License *)defaultLicense {
    return [License licenseWithIdentifier:[NSNumber numberWithInt:8]];
}

+ (NSArray *)allLicenses {
    NSManagedObjectContext* context = [NSManagedObjectContext contextForCurrentThread];
    return [License findAllInContext:context];
}

@end
