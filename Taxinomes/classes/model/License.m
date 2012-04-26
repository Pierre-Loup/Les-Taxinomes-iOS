//
//  License.m
//  Taxinomes
//
//  Created by Pierre-Loup on 11/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "License.h"
#import "LTDataManager.h"


@implementation License

@dynamic identifier;
@dynamic name;
@dynamic icon;
@dynamic link;
@dynamic desc;
@dynamic abbr;

+ (License *)licenseWithXMLRPCResponse: (NSDictionary *) response {
    if(response == nil){
        return nil;
    }
    
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    
    License *license = [License licenseWithIdentifier:[NSNumber numberWithInt:[(NSString*)[response objectForKey:@"id"] intValue]]];
    
    if (!license) {
        license = (License *)[NSEntityDescription insertNewObjectForEntityForName:kLicenseEntityName inManagedObjectContext:context];
        license.identifier = [NSNumber numberWithInt:[(NSString*)[response objectForKey:@"id"] intValue]];
    }
    
    license.name = [response objectForKey:@"name"];
    license.icon = [response objectForKey:@"icon"];
    license.link = [response objectForKey:@"link"];
    license.desc = [response objectForKey:@"description"];
    license.abbr = [response objectForKey:@"addr"];
    
    if (![context save:nil]) {
        return nil;
    }
    
    return license;
}

+ (License *)licenseWithIdentifier: (NSNumber *)identifier {
     NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %d",kLicenseEntityIdentifierField,[identifier intValue]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kLicenseEntityIdentifierField ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[[context executeFetchRequest:request error:&error] mutableCopy] autorelease];
    [request release];
    if ([mutableFetchResults count] == 0) {
        return nil;
    } else if ([mutableFetchResults count] > 1) {
        return [mutableFetchResults objectAtIndex:0];
    } else {
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

+ (NSArray *)allLicenses {
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    return [mutableFetchResults autorelease];
}


@end
