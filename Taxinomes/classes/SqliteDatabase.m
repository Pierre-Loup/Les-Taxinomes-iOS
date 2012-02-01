	//
//  SqliteDatabase.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 20/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import "SqliteDatabase.h"

//SELECT
#define selectArticle_string "SELECT * FROM article WHERE id_article=?"
static sqlite3_stmt *selectArticle_statement = nil;
#define selectAuthor_string "SELECT * FROM author WHERE id_author=?"
static sqlite3_stmt *selectAuthor_statement = nil;
#define selectArticleAuthor_string "SELECT id_author FROM article_author WHERE id_article=?"
static sqlite3_stmt *selectArticleAuthor_statement = nil;

//INSERT
#define insertArticle_string "INSERT INTO article (id_article, title, text, id_section, status, date, updateDate, visits, popularity, id_license, mediaURL, mediaThumbnailURL, media, mediaThumbnail, row_last_update) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )"
static sqlite3_stmt *insertArticle_statement = nil;
#define insertAuthor_string "INSERT INTO author (id_author, name, biography, status, signupDate, avatarURL, avatar, row_last_update) VALUES(?, ?, ?, ?, ?, ?, ?, ?)"
static sqlite3_stmt *insertAuthor_statement = nil;
#define insertArticleAuthor_string "INSERT INTO article_author (id_article, id_author) VALUES(?, ?)"
static sqlite3_stmt *insertArticleAuthor_statement = nil;

//DELETE
#define deleteArticle_string "DELETE FROM article WHERE id_article=?";
static sqlite3_stmt *deleteArticle_statement = nil;
#define deleteAuthor_string "DELETE FROM author WHERE id_author=?";
static sqlite3_stmt *deleteAuthor_statement = nil;
#define deleteArticleAuthor_string "DELETE FROM article_author WHERE id_article=?";
static sqlite3_stmt *deleteArticleAuthor_statement = nil;

@implementation SqliteDatabase

- (id)initWithDb:(sqlite3*)db {
	if((self = [super init])) {
		database = db;
	}
	return self;
}

- (Article *)selectArticleWithId:(NSString *)id_article{
    Article *article = [[[Article alloc] init] autorelease];
	
	if (selectArticle_statement == nil) {
		const char *sql = selectArticle_string;
		if (sqlite3_prepare_v2(database, sql, -1, &selectArticle_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
    sqlite3_bind_text(selectArticle_statement, 1, [id_article UTF8String], -1, SQLITE_TRANSIENT);
	int succes =sqlite3_step(selectArticle_statement);
    if (succes == SQLITE_ROW) {
		article.id_article = id_article;
        if(sqlite3_column_text(selectArticle_statement, 1))
            article.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 1)];
        if(sqlite3_column_text(selectArticle_statement, 2))
            article.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 2)];
        if(sqlite3_column_text(selectArticle_statement, 3))
            article.id_section = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 3)];
        if(sqlite3_column_text(selectArticle_statement, 4))
            article.status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 4)];
        
        if(sqlite3_column_text(selectArticle_statement, 5)){
            NSString *strDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 5)];
            NSDate *date = [[NSDate alloc] initWithString:strDate];
            article.date = date;
            [date release];
        }
        
        if(sqlite3_column_text(selectArticle_statement, 6)){
            NSString *strUpdateDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 6)];
            NSDate *updateDate = [[NSDate alloc] initWithString:strUpdateDate];
            article.updateDate = updateDate;
            [updateDate release];
        }
        
        if(sqlite3_column_text(selectArticle_statement, 7))
            article.visits = sqlite3_column_int(selectArticle_statement, 7);
        if(sqlite3_column_text(selectArticle_statement, 8))
            article.popularity = sqlite3_column_double(selectArticle_statement, 8);
        if(sqlite3_column_text(selectArticle_statement, 9))
            article.id_license  = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 9)];
        if(sqlite3_column_text(selectArticle_statement, 10))
            article.mediaURL  = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 10)];
        if(sqlite3_column_text(selectArticle_statement, 11))
            article.mediaThumbnailURL = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 11)];
        if (article.mediaURL != @"" && sqlite3_column_blob(selectArticle_statement, 12)) {
            NSData *mediaData = [NSData dataWithBytes:sqlite3_column_blob(selectArticle_statement, 12) length:sqlite3_column_bytes(selectArticle_statement, 12)];
            article.media = [UIImage imageWithData:mediaData];
        }
        if (article.mediaThumbnailURL != @"" && sqlite3_column_blob(selectArticle_statement, 13)) {
            NSData *mediaThumbnailData = [NSData dataWithBytes:sqlite3_column_blob(selectArticle_statement, 13) length:sqlite3_column_bytes(selectArticle_statement, 13)];
            article.mediaThumbnail = [UIImage imageWithData:mediaThumbnailData];
        }        
        
        if (sqlite3_column_text(selectArticle_statement, 14)) {
            NSString *strDataReceivedDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticle_statement, 14)];
            NSDate *dataReceivedDate = [[NSDate alloc] initWithString:strDataReceivedDate];
            article.dataReceivedDate = dataReceivedDate;
            [dataReceivedDate release];
        }
        
        NSArray *authorsIds = [self selectAuthorsIdForArticleId:id_article];
        NSMutableArray *authors = [[NSMutableArray alloc] initWithCapacity:[authorsIds count]];
        if ([authorsIds count] > 0) {
            for (NSString *authorId in authorsIds){
                Author *author = [self selectAuthorWithId:authorId];
                if(author != nil){
                    [authors addObject:author];
                    //[author release];
                }
            }
            article.authors = [NSArray arrayWithArray:authors];
        }
        [authors release];     

	} else {
        sqlite3_reset(selectArticle_statement);
		return nil;
	}
	// Reset the statement for future reuse.
	sqlite3_reset(selectArticle_statement);
	return article;
}

//id_author, name, biography, status, signupDate, avatarURL, avatar, row_last_update
- (Author *)selectAuthorWithId:(NSString *)id_author{
    Author *author = [[Author alloc] init];
	
	if (selectAuthor_statement == nil) {
		const char *sql = selectAuthor_string;
		if (sqlite3_prepare_v2(database, sql, -1, &selectAuthor_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
    sqlite3_bind_text(selectAuthor_statement, 1, [id_author UTF8String], -1, SQLITE_TRANSIENT);
    int succes = sqlite3_step(selectAuthor_statement);
	if (succes == SQLITE_ROW) {
		author.id_author = id_author;
        if(sqlite3_column_text(selectAuthor_statement, 1))
            author.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAuthor_statement, 1)];
        if(sqlite3_column_text(selectAuthor_statement, 2))
            author.biography = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAuthor_statement, 2)];
        if(sqlite3_column_text(selectAuthor_statement, 3))
            author.status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAuthor_statement, 3)];
        if(sqlite3_column_text(selectAuthor_statement, 4)){
            NSString *strSignupDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAuthor_statement, 4)];
            NSDate *signupDate = [[NSDate alloc] initWithString:strSignupDate];
            author.signupDate = signupDate;
            [signupDate release];
        }
        
        if(sqlite3_column_text(selectAuthor_statement, 5))
            author.avatarURL = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAuthor_statement, 5)];
        
        if (author.avatarURL != @"" && sqlite3_column_blob(selectAuthor_statement, 6)) {
            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(selectAuthor_statement, 6) length:sqlite3_column_bytes(selectAuthor_statement, 6)];
            author.avatar = [UIImage imageWithData:imageData];
        }
        
        if(sqlite3_column_text(selectAuthor_statement, 7)){
            NSString *strDataReceivedDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAuthor_statement, 7)];
            NSDate *dataReceivedDate = [[NSDate alloc] initWithString:strDataReceivedDate];
            author.dataReceivedDate = dataReceivedDate;
            [dataReceivedDate release];
        }       
	} else {
        sqlite3_reset(selectAuthor_statement);        
		return nil;
	}
	// Reset the statement for future reuse.
	sqlite3_reset(selectAuthor_statement);
	
	return [author autorelease];
}

- (NSArray *)selectAuthorsIdForArticleId:(NSString *)id_article {
    if (selectArticleAuthor_statement == nil) {
		const char *sql = selectArticleAuthor_string;
		if (sqlite3_prepare_v2(database, sql, -1, &selectArticleAuthor_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
    NSMutableArray *authorsIds = [[NSMutableArray alloc] init];
    sqlite3_bind_text(selectArticleAuthor_statement, 1, [id_article UTF8String], -1, SQLITE_TRANSIENT);
	while (sqlite3_step(selectArticleAuthor_statement) == SQLITE_ROW) {
		[authorsIds addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectArticleAuthor_statement, 0)]];        
	}
	// Reset the statement for future reuse.
	sqlite3_reset(selectArticleAuthor_statement);
	return [authorsIds autorelease];
}

- (bool)insertArticle:(Article *)article{
    
    if (insertArticle_statement == nil) {
		static char *sql = insertArticle_string;
		if (sqlite3_prepare_v2(database, sql, -1, &insertArticle_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return NO;
		}
	}
    sqlite3_bind_text(insertArticle_statement, 1, [article.id_article UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 2, [article.title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 3, [article.text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 4, [article.id_section UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 5, [article.status UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 6, [[article.date description] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 7, [[article.updateDate description] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insertArticle_statement, 8, article.visits);
    sqlite3_bind_double(insertArticle_statement, 9, article.popularity);
    sqlite3_bind_text(insertArticle_statement, 10, [article.id_license UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 11, [article.mediaURL UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticle_statement, 12, [article.mediaThumbnailURL UTF8String], -1, SQLITE_TRANSIENT);
    
    if(article.mediaURL != @""){        
        NSData *mediaData = UIImagePNGRepresentation(article.media);
        sqlite3_bind_blob(insertArticle_statement, 13, mediaData.bytes, mediaData.length, SQLITE_TRANSIENT);
    } else {
        sqlite3_bind_null(insertArticle_statement, 13);
    }
    
    if(article.mediaThumbnailURL != @""){        
        NSData *mediaThumbnailData = UIImagePNGRepresentation(article.mediaThumbnail);
        sqlite3_bind_blob(insertArticle_statement, 14, mediaThumbnailData.bytes, mediaThumbnailData.length, SQLITE_TRANSIENT);
    } else {
        sqlite3_bind_null(insertArticle_statement, 14);
    }
    
    sqlite3_bind_text(insertArticle_statement, 15, [[article.dataReceivedDate description] UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insertArticle_statement);
    sqlite3_reset(insertArticle_statement);
    if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		return NO;
	}
    
    if ([article.authors count] > 0){
        for (Author *author in article.authors) {
            [self insertAuteurArticleWithArticleId:article.id_article AuthorId:author.id_author];
            if([self selectAuthorWithId:author.id_author] == nil){
                [self insertAuthor:author];
            }
        }
    }
    
	return YES;
}

- (bool)insertAuthor:(Author *)author{
    
    if (insertAuthor_statement == nil) {
		static char *sql = insertAuthor_string;
		if (sqlite3_prepare_v2(database, sql, -1, &insertAuthor_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return NO;
		}
	}
    //id_author, name, biography, status, signupDate, avatarURL, avatar, row_last_update
    sqlite3_bind_text(insertAuthor_statement, 1, [author.id_author UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertAuthor_statement, 2, [author.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertAuthor_statement, 3, [author.biography UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertAuthor_statement, 4, [author.status UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertAuthor_statement, 5, [[author.signupDate description] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertAuthor_statement, 6, [author.avatarURL UTF8String], -1, SQLITE_TRANSIENT);
    if(author.avatarURL != @""){        
        NSData *imageData = UIImagePNGRepresentation(author.avatar);
        sqlite3_bind_blob(insertAuthor_statement, 7, imageData.bytes, imageData.length, SQLITE_TRANSIENT);
    } else {
        sqlite3_bind_null(insertAuthor_statement, 7);
    }
    sqlite3_bind_text(insertAuthor_statement, 8, [[author.dataReceivedDate description] UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insertAuthor_statement);
    sqlite3_reset(insertAuthor_statement);
    if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		return NO;
	} else {
		return YES;
	}
}

- (bool)insertAuteurArticleWithArticleId:(NSString*) id_article AuthorId:(NSString *)id_author {
    
    if (insertArticleAuthor_statement == nil) {
		static char *sql = insertArticleAuthor_string;
		if (sqlite3_prepare_v2(database, sql, -1, &insertArticleAuthor_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return NO;
		}
	}
    //id_author, name, biography, status, signupDate, avatarURL, avatar, row_last_update
    sqlite3_bind_text(insertArticleAuthor_statement, 1, [id_article UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertArticleAuthor_statement, 2, [id_author UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insertArticleAuthor_statement);
    sqlite3_reset(insertArticleAuthor_statement);
    if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		return NO;
	} else {
		return YES;
	}
}

- (bool)deleteArticleWithId:(NSString *)id_article{
    if (deleteArticle_statement == nil) {
		const char *sql = deleteArticle_string;
		if (sqlite3_prepare_v2(database, sql, -1, &deleteArticle_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return NO;
		}
	}
    sqlite3_bind_text(deleteArticle_statement, 1, [id_article UTF8String], -1, SQLITE_TRANSIENT);
    
	// Execute the query.
	int success = sqlite3_step(deleteArticle_statement);
	// Reset the statement for future use.
	sqlite3_reset(deleteArticle_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
		return NO;
	}
    
    
    [self deleteArticleAuthorWithArticleId:id_article];
    
	return YES;
}

- (bool)deleteAuthorWithId:(NSString *)id_author{
    if (deleteAuthor_statement == nil) {
		const char *sql = deleteAuthor_string;
		if (sqlite3_prepare_v2(database, sql, -1, &deleteAuthor_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return NO;
		}
	}
    sqlite3_bind_text(deleteAuthor_statement, 1, [id_author UTF8String], -1, SQLITE_TRANSIENT);
    
	// Execute the query.
	int success = sqlite3_step(deleteAuthor_statement);
	// Reset the statement for future use.
	sqlite3_reset(deleteAuthor_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
		return NO;
	}
	return YES;
}

- (bool)deleteArticleAuthorWithArticleId:(NSString *)id_article{
    if (deleteArticleAuthor_statement == nil) {
		const char *sql = deleteArticleAuthor_string;
		if (sqlite3_prepare_v2(database, sql, -1, &deleteArticleAuthor_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return NO;
		}
	}
    sqlite3_bind_text(deleteArticleAuthor_statement, 1, [id_article UTF8String], -1, SQLITE_TRANSIENT);
    
	// Execute the query.
	int success = sqlite3_step(deleteArticleAuthor_statement);
	// Reset the statement for future use.
	sqlite3_reset(deleteArticleAuthor_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
		return NO;
	}
    
	return YES;
}

@end
