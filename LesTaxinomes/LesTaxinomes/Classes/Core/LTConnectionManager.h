//
//  LTConnectionManager.h
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
#import <CoreLocation/CoreLocation.h>

#import "LTConnectionManagerError.h"

#import "LTMedia.h"
#import "LTAuthor.h"
#import "LTLicense.h"
#import "XMLRPCRequest.h"


typedef enum {
    LTAuthorsSortBySignupDate,
    LTAuthorsSortAlphabeticOrder
} LTAuthorsSortType;

@protocol LTConnectionManagerDelegate <NSObject>
@optional
- (void)uploadDeterminationDidUpdate:(CGFloat)determination;
- (void)downloadDeterminationDidUpdate:(CGFloat)determination;
@end

@class AFHTTPRequestOperation;

@interface LTConnectionManager : NSObject

@property (nonatomic, strong) LTAuthor *authenticatedUser;
@property (nonatomic, unsafe_unretained) id<LTConnectionManagerDelegate> delegate;

+ (LTConnectionManager *)sharedManager;
- (void)getLicensesWithResponseBlock:(void (^)(NSArray* licenses, NSError *error))responseBlock;

- (AFHTTPRequestOperation*)fetchMediasSummariesByDateForAuthor:(LTAuthor *)author
                                                  nearLocation:(CLLocation *)location
                                                  searchFilter:(NSString *)searchFilter
                                                     withRange:(NSRange)range
                                                 responseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock;

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock;

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier
                 responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock;

- (void)fetchHomeCoversWithResponseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock;

- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(LTAuthor *author, NSError *error))responseBlock;

- (void)getAuthorsSummariesWithRange:(NSRange)range
                     withSortKey:(LTAuthorsSortType)sortType
                   responseBlock:(void (^)(NSArray* authors, NSError *error))responseBlock;

- (void)addMediaWithTitle:(NSString *)title
                     text:(NSString *)text
                  license:(LTLicense *)license
                 location:(CLLocation*)location
                  address:(NSDictionary*)addressDict
                 assetURL:(NSURL *)assetURL
            responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock;

- (void)authWithLogin:(NSString *)login
             password:(NSString *)password
        responseBlock:(void (^)(LTAuthor *authenticatedUser, NSError *error))responseBlock;

- (void)unAuthenticate;

- (void)fetchFullTreeWithCompletion:(void (^)(NSError *error))completion;

@end
