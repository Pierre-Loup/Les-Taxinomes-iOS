//
//  ConnectionManager.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "Author.h"
#import "XMLRPCRequest.h"

@interface ConnectionManager : NSObject {
    NSError *error;
}

@property (nonatomic, retain) NSError *error;
           
+ (ConnectionManager *)sharedConnectionManager;

- (NSArray *)getArticlesByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start;
- (NSArray *)getShortArticlesByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start;
- (Article *)getArticleWithId: (NSString *) id_article;
- (Article *)getShortArticleWithId: (NSString *) id_article;
- (Author *)getAuthorWithId: (NSString *) id_author;
- (void)getMediaWithArticleId: (NSString *) id_article;
- (Author *)authWithLogin:(NSString *) login password:(NSString *) password;
- (id)executeXMLRPCRequest:(XMLRPCRequest *)req;

@end
