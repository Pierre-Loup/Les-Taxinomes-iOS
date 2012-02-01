//
//  SqliteDatabase.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 20/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Article.h"
#import "Author.h"

@interface SqliteDatabase : NSObject {
    sqlite3* database;
}

- (id)initWithDb:(sqlite3*)db;

//SELECT

- (Article *)selectArticleWithId:(NSString *)id_article;
- (Author *)selectAuthorWithId:(NSString *)id_author;
- (NSArray *)selectAuthorsIdForArticleId:(NSString *)id_article;

//INSERT

- (bool)insertArticle:(Article *)article;
- (bool)insertAuthor:(Author *)author;
- (bool)insertAuteurArticleWithArticleId:(NSString*) id_article AuthorId:(NSString *)id_author;

//DELETE

- (bool)deleteArticleWithId:(NSString *)id_article;
- (bool)deleteAuthorWithId:(NSString *)id_author;
- (bool)deleteArticleAuthorWithArticleId:(NSString *)id_article;

@end
