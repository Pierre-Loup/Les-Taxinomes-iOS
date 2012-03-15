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
    
    License *license = (License *)[NSEntityDescription insertNewObjectForEntityForName:kEntityLicenseName inManagedObjectContext:context];
    
    license.identifier = [NSNumber numberWithInt:[(NSString*)[response objectForKey:@"id"] intValue]];
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
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    return mutableFetchResults;
}


@end
