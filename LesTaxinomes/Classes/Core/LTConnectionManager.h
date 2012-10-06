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

typedef enum LTConnectionManagerError {
    LTConnectionManagerBadArgsError = 77001,
    LTConnectionManagerInternalError = 77002
} LTConnectionManagerError;

@interface LTConnectionManager : NSObject

@property (nonatomic, retain) Author * authenticatedUser;

+ (LTConnectionManager *)sharedConnectionManager;
- (void)getLicensesWithResponseBlock:(void (^)(NSArray* licenses, NSError *error))responseBlock;

- (void)getShortMediasByDateForAuthor:(Author *)author
                         nearLocation:(CLLocation *)location
                            withRange:(NSRange)range
                        responseBlock:(void (^)(Author* author, NSRange range, NSArray* medias, NSError *error))responseBlock;

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(NSNumber* mediaIdentifier, Media* media, NSError *error))responseBlock;

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier
                 responseBlock:(void (^)(NSNumber* mediaIdentifier, Media* media, NSError *error))responseBlock;

- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(NSNumber* authorIdentifier, Author* author, NSError *error))responseBlock;

- (void)addMediaWithTitle:(NSString *)title
                     text:(NSString *)text
                  license:(License *)license
                 assetURL:(NSURL *)assetURL
            responseBlock:(void (^)(NSString* title, NSString* text, License* license, NSURL* assetURL, Media* media, NSError *error))responseBlock;

- (void)authWithLogin:(NSString *)login
             password:(NSString *)password
        responseBlock:(void (^)(NSString* login, NSString* password, Author* authenticatedUser, NSError *error))responseBlock;

- (void)unAuthenticate;

@end
