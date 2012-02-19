//
//  SqliteDatabase.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 20/11/11.
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
