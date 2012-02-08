//
//  ConnectionManager.h
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
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>
 
 */

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
