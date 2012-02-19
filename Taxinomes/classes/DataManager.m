//
//  DataManager.m
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

#import "DataManager.h"
#import "Constants.h"

static DataManager *instance = nil;

@implementation DataManager
@synthesize sqliteDatabase;

- (void)dealloc {
	[sqliteDatabase release];
	[super dealloc];
}	

+ (DataManager *)sharedDataManager {
	if(instance == nil) {
		instance = [[DataManager alloc] init];
		[instance initDatabase];
	}	
	return instance;
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

@end
