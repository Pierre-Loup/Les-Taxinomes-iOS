//
//  LTConnectionManager.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
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
#import <CoreLocation/CoreLocation.h>
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

@protocol LTConnectionManagerAuthDelegate <NSObject>
@required
- (void)authDidEndWithLogin:(NSString *)login
                   password:(NSString *)password
                     author:(Author *)author
                      error:(NSError *)error;
@end

@interface LTConnectionManager : NSObject

@property (nonatomic, assign) id<LTConnectionManagerAuthDelegate> authDelegate;
@property (nonatomic, assign) id<ASIProgressDelegate> downloadProgressDelegate;
@property (nonatomic, assign) id<ASIProgressDelegate> uploadProgressDelegate;
@property (nonatomic, retain) Author * authenticatedUser;
@property (nonatomic, assign) AuthenticationStatus authStatus;

+ (LTConnectionManager *)sharedConnectionManager;
- (void)getLicensesWithResponseBlock:(void (^)(NSArray* license, NSError *error))responseBlock;

- (void)getShortMediasByDateForAuthor:(Author *)author 
                                 withLimit:(NSInteger)limit 
                          startingAtRecord:(NSInteger)start 
                                  delegate:(id<LTConnectionManagerDelegate>)delegate;

- (void)getShortMediasNearLocation:(CLLocationCoordinate2D)location
                        forAuthor:(Author *)author
                        withLimit:(NSInteger)limit 
                 startingAtRecord:(NSInteger)start 
                          delegate:(id<LTConnectionManagerDelegate>)delegate;

- (void)getMediaWithId:(NSNumber *)mediaIdentifier 
                    delegate:(id<LTConnectionManagerDelegate>)delegate;

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier 
                            delegate:(id<LTConnectionManagerDelegate>)delegate;

- (void)getAuthorWithId:(NSNumber *)authorIdentifier 
                     delegate:(id<LTConnectionManagerDelegate>)delegate;

- (void)addMediaWithInformations: (NSDictionary *)info 
                        delegate:(id<LTConnectionManagerDelegate>)delegate;

- (void)authWithLogin:(NSString *)login
             password:(NSString *)password
             delegate:(id<LTConnectionManagerAuthDelegate>)delegate;

- (void)checkUserAuthStatusWithDelegate:(id<LTConnectionManagerAuthDelegate>)delegate;
- (void)unAuthenticate; 
- (id)executeXMLRPCRequest:(XMLRPCRequest *)req authenticated:(BOOL) auth;

@end
