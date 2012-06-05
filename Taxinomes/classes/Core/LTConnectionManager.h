//
//  LTConnectionManager.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <Foundation/Foundation.h>
#import "media.h"
#import "Author.h"
#import "License.h"
#import "XMLRPCRequest.h"
#import "ASIProgressDelegate.h"

typedef enum {
    UNAUTHENTICATED = 0,
    AUTH_PENDING,
    AUTH_FAILED,
    AUTHENTICATED
} AuthenticationStatus;

@protocol LTConnectionManagerDelegate <NSObject>
@optional
- (void)didRetrievedShortMedias:(NSArray *)medias;
- (void)didRetrievedMedia:(Media *)media;
- (void)didRetrievedAuthor:(Author *)author;
- (void)didSuccessfullyUploadMedia:(Media *)media;
- (void)didFailWithError:(NSError *)error;
@end

@protocol LTConnectionManagerAuthDelegate
- (void)didAuthenticateWithAuthor:(Author *)author;
- (void)didFailToAuthenticateWithError:(NSError *)error;
@end

@interface LTConnectionManager : NSObject {
    id <LTConnectionManagerAuthDelegate> authDelegate_;
    id <ASIProgressDelegate> progressDelegate_;
    Author * authenticatedUser_;
    AuthenticationStatus authStatus;
}

@property (nonatomic, retain) id authDelegate;
@property (nonatomic, retain) id progressDelegate;
@property (nonatomic, retain) Author * authenticatedUser;
@property (nonatomic, assign) AuthenticationStatus authStatus;

+ (LTConnectionManager *)sharedConnectionManager;

- (void)getShortMediasAsychByDateForAuthor:(Author *)author withLimit:(NSInteger)limit startingAtRecord:(NSInteger)start delegate:(id<LTConnectionManagerDelegate>)delegate;
- (NSArray *)getShortMediasByDateWithLimit:(NSInteger)limit startingAtRecord:(NSInteger)start;
- (Media *)getMediaWithId:(NSNumber *)mediaIdentifier;
- (void)getMediaAsynchWithId:(NSNumber *)mediaIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate;
- (void)getMediaLargeURLAsynchWithId:(NSNumber *)mediaIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate;
- (Author *)getAuthorWithId:(NSNumber *)authorIdentifier;
- (void)getAuthorAsynchWithId:(NSNumber *)authorIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate;
- (NSArray *)getLicenses;
//- (void)getSectionWithIdentifier:(NSNumber*)identifier;
- (void)authAsynchWithLogin:(NSString *)login password:(NSString *)password delegate:(id<LTConnectionManagerAuthDelegate>)delegate;
- (BOOL)isAuthenticated;
- (void)unAuthenticate; 
- (void)addMediaWithInformations: (NSDictionary *)info;
- (void)addMediaAsynchWithInformations: (NSDictionary *)info delegate:(id<LTConnectionManagerDelegate>)delegate;
- (id)executeXMLRPCRequest:(XMLRPCRequest *)req authenticated:(BOOL) auth;

@end
