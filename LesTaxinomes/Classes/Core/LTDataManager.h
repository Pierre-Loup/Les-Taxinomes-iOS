//
//  LTDataManager.h
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

#import <Foundation/Foundation.h>
#import "LTConnectionManager.h"
#import "Author.h"
#import "Media.h"

@interface LTDataManager : NSObject

@property (nonatomic, retain, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext* mainManagedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectContext* backgroundManagedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, assign) NSInteger synchLimit;
@property (nonatomic, readonly) NSString* applicationDocumentsDirectory;

+ (LTDataManager *)sharedDataManager;

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(NSNumber* mediaIdentifier, Media* media, NSError *error))responseBlock;

- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(NSNumber* authorIdentifier, Author* author, NSError *error))responseBlock;

@end
