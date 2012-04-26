//
//  LTConnectionManager.h
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
 
 This program is distributed in the hope that it will be useful,
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

@protocol LTConnectionManagerDelegate
- (void)didAuthenticate;
- (void)didFailToAuthenticate:(NSString *)message;
@end

@interface LTConnectionManager : NSObject {
    id delegate;
    id <ASIProgressDelegate> progressDelegate_;
    Author *_author;
    NSError *_error;
    AuthenticationStatus authStatus;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) id progressDelegate;
@property (nonatomic, retain) Author *author;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, assign) AuthenticationStatus authStatus;


           
+ (LTConnectionManager *)sharedConnectionManager;

- (NSArray *)getShortMediasByDateWithLimit:(NSInteger)limit startingAtRecord:(NSInteger)start;
- (Media *)getMediaWithId:(NSNumber *)mediaIdentifier;
- (Author *)getAuthorWithId:(NSNumber *)authorIdentifier;
- (NSArray *)getLicenses;
- (void)getSectionWithIdentifier:(NSNumber*)identifier;
- (void)authWithLogin:(NSString *)login password:(NSString *)password;
- (id)executeXMLRPCRequest:(XMLRPCRequest *)req authenticated:(BOOL) auth;

@end
