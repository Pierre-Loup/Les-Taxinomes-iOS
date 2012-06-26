//
//  LTDataManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "LTDataManager.h"
#import "Constants.h"
#import "Media.h"

static LTDataManager *instance = nil;

@interface LTDataManager (Private)

@end

@implementation LTDataManager
@synthesize synchLimit = synchLimit_;

- (id)init
{
    self = [super init];
    if (self) {
        synchLimit_ = 0;
    }
    return self;
}

- (void)dealloc {
	[mainManagedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
	[super dealloc];
}	

+ (LTDataManager *)sharedDataManager {
	if(instance == nil) {
		instance = [[LTDataManager alloc] init];
	}	
	return instance;
}

- (BOOL)getAuthorAsychIfNeededWithId:(NSNumber *)authorIdentifier 
                        withDelegate:(id<LTConnectionManagerDelegate>)delegate {
    
    Author * author = [Author authorWithIdentifier:authorIdentifier];
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    
    if(author == nil
       || author.avatarURL == nil
       || ([[NSDate date] timeIntervalSinceDate:author.localUpdateDate] > kMediaCacheTime)){
        
        [connectionManager getAuthorWithId:authorIdentifier delegate:delegate];
        return YES;
    }
    return NO;
}

- (BOOL)getMediaAsychIfNeededWithId:(NSNumber *)mediaIdentifier 
                       withDelegate:(id<LTConnectionManagerDelegate>)delegate {
    
    Media * media = [Media mediaWithIdentifier:mediaIdentifier];
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    NSLog(@"media.text %@",media.text);
    if( media == nil
       || media.mediaMediumURL == nil
       || [[NSDate date] timeIntervalSinceDate:media.localUpdateDate] > kMediaCacheTime){
        [connectionManager getMediaWithId:mediaIdentifier delegate:delegate];
        return YES;
    }
    return NO;
}

#pragma mark - Core Data

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self mainManagedObjectContext] save:&error]) {
		// Handle error
    }
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) mainManagedObjectContext {
	
    if (mainManagedObjectContext_ != nil) {
        return mainManagedObjectContext_;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        mainManagedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [mainManagedObjectContext_ setPersistentStoreCoordinator: coordinator];
    }
    return mainManagedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    managedObjectModel_ = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Taxinomes.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
