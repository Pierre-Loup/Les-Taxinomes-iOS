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
#import "Media.h"
#import "Author.h"
#import "License.h"
#import "XMLRPCRequest.h"

/**
 Indicates an error occured in LTConnectionManager.
 */
extern NSString* const LTConnectionManagerErrorDomain;

typedef enum  {
    LTConnectionManagerBadArgsError = 77001,
    LTConnectionManagerInternalError = 77002
} LTConnectionManagerError;

typedef enum {
    LTAuthorsSortBySignupDate,
    LTAuthorsSortAlphabeticOrder
} LTAuthorsSortType;

@protocol LTConnectionManagerDelegate <NSObject>
@optional
- (void)uploadDeterminationDidUpdate:(CGFloat)determination;
- (void)downloadDeterminationDidUpdate:(CGFloat)determination;
@end

@interface LTConnectionManager : NSObject

@property (nonatomic, strong) Author * authenticatedUser;
@property (nonatomic, unsafe_unretained) id<LTConnectionManagerDelegate> delegate;

+ (LTConnectionManager *)sharedConnectionManager;
- (void)getLicensesWithResponseBlock:(void (^)(NSArray* licenses, NSError *error))responseBlock;

- (void)getMediasSummariesByDateForAuthor:(Author *)author
                             nearLocation:(CLLocation *)location
                                withRange:(NSRange)range
                            responseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock;

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(Media* media, NSError *error))responseBlock;

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier
                 responseBlock:(void (^)(Media* media, NSError *error))responseBlock;

- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(Author* author, NSError *error))responseBlock;

- (void)getAuthorsSummariesWithRange:(NSRange)range
                     withSortKey:(LTAuthorsSortType)sortType
                   responseBlock:(void (^)(NSArray* authors, NSError *error))responseBlock;

- (void)addMediaWithTitle:(NSString *)title
                     text:(NSString *)text
                  license:(License *)license
                 location:(CLLocation*)location
                 assetURL:(NSURL *)assetURL
            responseBlock:(void (^)(Media* media, NSError *error))responseBlock;

- (void)authWithLogin:(NSString *)login
             password:(NSString *)password
        responseBlock:(void (^)(Author* authenticatedUser, NSError *error))responseBlock;

- (void)unAuthenticate;

@end
