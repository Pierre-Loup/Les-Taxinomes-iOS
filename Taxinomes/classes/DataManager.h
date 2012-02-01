//
//  DataManager.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SqliteDatabase.h"
#import "ConnectionManager.h"
#import "Author.h"
#import "Article.h"

@interface DataManager : NSObject {
    sqlite3 *database;
    SqliteDatabase *sqliteDatabase;
}

@property (nonatomic, retain) SqliteDatabase *sqliteDatabase;
@property (nonatomic, retain) ConnectionManager *connectionManager;

+ (DataManager *)sharedDataManager;
- (void)initDatabase;

- (Author *)getAuthorWithId: (NSString *) id_author;
- (Article *)getArticleWithId: (NSString *) id_article;
- (NSArray *)getShortArticlesByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start;
- (Article *)getShortArticleWithId: (NSString *) id_article;
@end
