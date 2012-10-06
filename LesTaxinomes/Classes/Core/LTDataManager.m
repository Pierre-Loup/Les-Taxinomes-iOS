//
//  LTDataManager.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import "LTDataManager.h"
#import "Constants.h"
#import "Media.h"

@interface LTDataManager (Private)

@end

@implementation LTDataManager
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;
@synthesize mainManagedObjectContext = mainManagedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;
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
	static LTDataManager* dataManager = nil;
    static dispatch_once_t  dataManagerOnceToken;
    
    dispatch_once(&dataManagerOnceToken, ^{
        dataManager = [[LTDataManager alloc] init];
    });
    
    return dataManager;
}

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(NSNumber* mediaIdentifier, Media* media, NSError *error))responseBlock {
    
    Media * localMedia = [Media mediaWithIdentifier:mediaIdentifier];
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    
    if(  localMedia == nil
       ||  localMedia.mediaMediumURL == nil
       || [[NSDate date] timeIntervalSinceDate: localMedia.localUpdateDate] > kMediaCacheTime){
        
        [connectionManager getMediaWithId:mediaIdentifier
                            responseBlock:responseBlock];
    } else {
        responseBlock(mediaIdentifier, localMedia, nil);
    }
}



- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(NSNumber* authorIdentifier, Author* author, NSError *error))responseBlock {
    
    Author * localAuthor = [Author authorWithIdentifier:authorIdentifier];
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    
    if(localAuthor == nil
       || localAuthor.avatarURL == nil
       || ([[NSDate date] timeIntervalSinceDate:localAuthor.localUpdateDate] > kMediaCacheTime)){
        
        [connectionManager getAuthorWithId:authorIdentifier
                             responseBlock:responseBlock];
    } else {
        responseBlock(authorIdentifier, localAuthor, nil);
    }
}

@end
