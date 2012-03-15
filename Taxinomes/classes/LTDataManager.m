//
//  LTDataManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "LTDataManager.h"
#import "Constants.h"

static LTDataManager *instance = nil;

@implementation LTDataManager

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

/*
- (NSManagedObjectContext *)mainManagedObjectContext {
    
    if (!mainManagedObjectContext_) {
        
        mainManagedObjectContext_ = [[NSManagedObjectContext alloc] init];
        
        [mainManagedObjectContext_ setPersistentStoreCoordinator:[self pe]];
        
        [mainManagedObjectContext_ setUndoManager:nil];
        
        [mainManagedObjectContext_ setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        [mainManagedObjectContext_ setRetainsRegisteredObjects:NO];
        
    }
    
    
    
    return mainManagedObjectContext_;
    
}

- (void)initDatabase {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kDatabaseFile];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success) {
		//NSLog(@"Database exists : %@", writableDBPath);
	} else {
        // The writable database does not exist, delete the old Databases
        NSArray *contentsOfDocumentsDirectory = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
        for( NSString* file in contentsOfDocumentsDirectory) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*\.db$'"];
            if ([predicate evaluateWithObject:file]) {
                success = [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file] error:&error];
            }
        }
       
        // The writable database does not exist, so copy the default to the appropriate location.
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseFile];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        //NSLog(defaultDBPath);
        //NSLog(writableDBPath);
        if (!success) {
            NSAssert1(0, @"DataManager>Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    
    // The database is stored in the application bundle. 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kDatabaseFile];
    // Open the database. The database was prepared outside the application.
    sqlite3_open([path UTF8String], &database);
	sqliteDatabase = [[SqliteDatabase alloc] initWithDb:database];
}

- (Author *)getAuthorWithId: (NSString *) id_author{
    Author *author = [sqliteDatabase selectAuthorWithId:id_author];
    //NSLog(@"%f",[[NSDate date] timeIntervalSinceDate:author.dataReceivedDate]);
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    if(author==nil){        
        author = [connectionManager getAuthorWithId:id_author];
        [sqliteDatabase insertAuthor:author];
    } else if ([[NSDate date] timeIntervalSinceDate:author.dataReceivedDate] > kAuthorCacheTime 
               || author.avatar == nil){
        [sqliteDatabase deleteAuthorWithId:id_author];
        author = [connectionManager getAuthorWithId:id_author];
        [sqliteDatabase insertAuthor:author];
    }
    
    return author;
}

- (Article *)getArticleWithId: (NSString *) id_article{
    Article *article = [sqliteDatabase selectArticleWithId:id_article];
    //NSLog(@"%f",[[NSDate date] timeIntervalSinceDate:article.dataReceivedDate]);
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    if(article==nil){        
        article = [connectionManager getArticleWithId:id_article];
        [sqliteDatabase insertArticle:article];
    } else if ([[NSDate date] timeIntervalSinceDate:article.dataReceivedDate] > kArticleCacheTime){
        [sqliteDatabase deleteArticleWithId:id_article];
        article = [connectionManager getArticleWithId:id_article];
        [sqliteDatabase insertArticle:article];
    }
    
    return article;
}

- (Article *)getShortArticleWithId: (NSString *) id_article{
    Article *article = [sqliteDatabase selectArticleWithId:id_article];
    //NSLog(@"%f",[[NSDate date] timeIntervalSinceDate:article.dataReceivedDate]);
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    if(article==nil){        
        article = [connectionManager getShortArticleWithId:id_article];
        [sqliteDatabase insertArticle:article];
    } else if ([[NSDate date] timeIntervalSinceDate:article.dataReceivedDate] > kArticleCacheTime){
        [sqliteDatabase deleteArticleWithId:id_article];
        article = [connectionManager getShortArticleWithId:id_article];
        [sqliteDatabase insertArticle:article];
    }
    
    return article;
}

- (NSArray *)getShortArticlesByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start{

    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    return [NSMutableArray arrayWithArray:[connectionManager getShortArticlesByDateWithLimit:limit startingAtRecord:start]];
}

- (void)addArticleWithInformations: (NSDictionary *)info {
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    [connectionManager addArticleWithInformations:info];
}
 
 */

#pragma mark -
#pragma mark Saving

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


#pragma mark -
#pragma mark Core Data stack

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
