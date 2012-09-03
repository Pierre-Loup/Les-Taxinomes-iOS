//
//  LTConnectionManager.m
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

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreLocation/CoreLocation.h>
#import "LTConnectionManager.h"
#import "XMLRPCResponse.h"
#import "ASIHTTPRequest.h"
#import "Media.h"
#import "Author.h"
#import "License.h"
#import "LTXMLRPCClient.h"

@implementation LTConnectionManager
@synthesize downloadProgressDelegate = downloadProgressDelegate_;
@synthesize uploadProgressDelegate = uploadProgressDelegate_;
@synthesize authDelegate = authDelegate_;
@synthesize authStatus = authStatus_;



- (id)init {
	if (self = [super init]) {
        self.authStatus = UNAUTHENTICATED;
	}
	return self;
}

- (void)dealloc {
    [_authenticatedUser release];
	[super dealloc];
}

+ (LTConnectionManager *)sharedConnectionManager {
    static LTConnectionManager* connectionManager = nil;
    static dispatch_once_t  connectionManagerOnceToken;
    
    dispatch_once(&connectionManagerOnceToken, ^{
        connectionManager = [[LTConnectionManager alloc] init];
    });
    
    return connectionManager;
}

- (void)getLicensesWithResponseBlock:(void (^)(NSArray* licenses, NSError *error))responseBlock {
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"spip.liste_licences"
                 withParameters:nil
               authCookieEnable:NO
    success:^(AFHTTPRequestOperation *operation, XMLRPCResponse *response) {
        if([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary* responseDict = (NSDictionary*)response;
            NSMutableArray* licenses = [NSMutableArray array];
            for(NSString *key in (NSDictionary*)response){
                if ([[responseDict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *xmlLicenseDict = [responseDict objectForKey:key];
                    [licenses addObject:[License licenseWithXMLRPCResponse:xmlLicenseDict]];
                }
                
            }
            responseBlock(licenses, nil);
        }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         responseBlock(nil, error);
     }];
    
}

- (void)getShortMediasByDateForAuthor:(Author *)author
                         nearLocation:(CLLocation *)location
                            withRange:(NSRange)range
                        responseBlock:(void (^)(Author* author, NSRange range, NSArray* medias, NSError *error))responseBlock {
    
    if(range.length == 0 || range.length > kDefaultLimit)
        range.length = kDefaultLimit;
    NSString* limite = [NSString stringWithFormat:@"%d,%d", range.location,range.length];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"statut", @"vignette", @"auteurs", nil];
    NSNumber* thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber* thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       limite,                                     @"limite",
                                       requestedFields,                            @"champs_demandes",
                                       [NSArray arrayWithObject:@"date DESC"],     @"tri",
                                       @"carre",                                   @"vignette_format",
                                       thumbnailWidth,                             @"vignette_largeur",
                                       thumbnailHeight,                            @"vignette_hauteur",
                                       @"publie",                                  @"statut",
                                       nil];
    // Optional
    if (location) {
        [parameters setValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude]
                      forKey:@"lat"];
        [parameters setValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude]
                      forKey:@"lon"];
    }
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"geodiv.liste_medias"
                 withParameters:parameters
               authCookieEnable:author?YES:NO
    success:^(AFHTTPRequestOperation *operation, XMLRPCResponse *response) {
        if([response isKindOfClass:[NSArray  class]]) {
            NSMutableArray *medias = [NSMutableArray array];
            for(NSDictionary *mediaXML in (NSArray *)response){
                Media * mediaObject = [Media mediaWithXMLRPCResponse:mediaXML];
                if (mediaObject) {
                    [medias addObject:mediaObject];
                }
            }
            responseBlock(author, range, medias, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        responseBlock(author, range, nil, error);
    }];
}

///////////////////////////////////////////////////////////////////////////////

- (void)getMediaWithId:(NSNumber *)mediaIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate {
    if (!mediaIdentifier) {
        return;
    }
    XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSNumber* mediaMaxHeight = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT];
    NSNumber* mediaMaxWidth = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT];
    NSDictionary* args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:mediaIdentifier, mediaMaxWidth, mediaMaxHeight, nil] forKeys:[NSArray arrayWithObjects:@"id_article", @"document_largeur", @"document_hauteur", nil]];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        
        [xmlrpcRequest release];
        if([response isKindOfClass:[NSDictionary class]]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didRetrievedMedia:[Media mediaWithXMLRPCResponse:response]];
            });
        } else if ([response isKindOfClass:[NSError class]]){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didFailWithError:response];
            });
        } else {
            NSString* localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Media with id: %d",kLTConnectionManagerInternalError, [mediaIdentifier intValue]];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didFailWithError:error];
            });
            
        }
    });
}

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate {
    if (!mediaIdentifier) {
        return;
    }
    XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSNumber* mediaMaxHeight = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT_LARGE];
    NSNumber* mediaMaxWidth = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT_LARGE];
    NSArray* values = [NSArray arrayWithObjects:mediaIdentifier, [NSArray arrayWithObjects:@"id_media", @"document", nil], mediaMaxWidth, mediaMaxHeight, nil];
    NSArray* keys = [NSArray arrayWithObjects:@"id_article",@"champs_demandes", @"document_largeur", @"document_hauteur", nil];
    NSDictionary* args = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        
        [xmlrpcRequest release];
        if([response isKindOfClass:[NSDictionary class]]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didRetrievedMedia:[Media mediaLargeURLWithXMLRPCResponse:response]];
            });
        } else if ([response isKindOfClass:[NSError class]]){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didFailWithError:response];
            });
        } else {
            NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Media with id: %d",kLTConnectionManagerInternalError, [mediaIdentifier intValue]];
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
            NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didFailWithError:error];
            });
        }
    });
}

- (void)getAuthorWithId:(NSNumber *)authorIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate {
    if (!authorIdentifier) {
        return;
    }
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:authorIdentifier, nil] forKeys:[NSArray arrayWithObjects:@"id_auteur", nil]];
    [xmlrpcRequest setMethod:@"spip.lire_auteur" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        
        [xmlrpcRequest release];
        if([response isKindOfClass:[NSDictionary class]]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didRetrievedAuthor:[Author authorWithXMLRPCResponse:response]];
            });
        } else if ([response isKindOfClass:[NSError class]]){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didFailWithError:response];
            });
        } else {
            NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Author with id: %d",kLTConnectionManagerInternalError, [authorIdentifier intValue]];
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
            NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate didFailWithError:error];
            });
        }
    });
}

- (void)addMediaWithInformations: (NSDictionary *)info delegate:(id<LTConnectionManagerDelegate>)delegate {
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"geodiv.creer_media" withObject:info];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
        
        [xmlrpcRequest release];
        if([response isKindOfClass:[NSDictionary class]]) {
            if ([response objectForKey:@"faultString"]
                && [response objectForKey:@"faultCode"]) {
                if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [delegate didFailWithError:response];
                    });
                }
            } else {
                if ([delegate respondsToSelector:@selector(didSuccessfullyUploadMedia:)]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [delegate didSuccessfullyUploadMedia:[Media mediaWithXMLRPCResponse:response]];
                        
                    });
                }
            }
        } else if ([response isKindOfClass:[NSError class]]){
            if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate didFailWithError:response];
                });
            }
        } else {
            if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate didFailWithError:nil];
                    
                });
            }
        }
    });
}

- (void)authWithLogin:(NSString *)login password:(NSString *)password delegate:(id<LTConnectionManagerAuthDelegate>)delegate{
    self.authStatus = AUTH_PENDING;
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    
    NSMutableArray *args = [NSMutableArray array];
    if (login) {
        [args addObject:login];
    }
    if (password) {
        [args addObject:password];
    }
    [xmlrpcRequest setMethod:@"spip.auth" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
        
        [xmlrpcRequest release];
        if([response isKindOfClass:[NSDictionary class]]){
            self.authStatus = AUTHENTICATED;
            self.authenticatedUser = [Author authorWithXMLRPCResponse:response];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [delegate authDidEndWithLogin:login
                                     password:password
                                       author:self.authenticatedUser
                                        error:nil];
                
            });
        } else {
            self.authStatus = AUTH_FAILED;
            if ([response isKindOfClass:[NSError class]]) {
                NSError * error = (NSError *)response;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate authDidEndWithLogin:login
                                         password:password
                                           author:nil
                                            error:error];
                    
                });
            } else {
                NSError * error = [NSError errorWithDomain:kLTAuthenticationFailedError code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:TRANSLATE(@"error_auth_failed"), NSLocalizedDescriptionKey, nil]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate authDidEndWithLogin:login
                                         password:password
                                           author:nil
                                            error:error];
                    
                });
            }
        }
    });
}

- (void)checkUserAuthStatusWithDelegate:(id<LTConnectionManagerAuthDelegate>)delegate {
    NSHTTPCookie* authCookie = nil;
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[NSURL URLWithString:kHTTPHost] absoluteURL]];
    for (NSHTTPCookie * cookie in cookies) {
        if([cookie.name isEqualToString:kSessionCookieName]
           && cookie.value != nil
           && ![cookie.value isEqualToString:@""]
           && [cookie.expiresDate timeIntervalSinceNow] > 0.0) {
            authCookie = cookie;
        }
    }
    
    if (self.authenticatedUser) {
            [delegate authDidEndWithLogin:nil
                                 password:nil
                                   author:self.authenticatedUser
                                    error:nil];
            
    } else if (authCookie) {
        [self authWithLogin:nil password:nil delegate:delegate];
    } else {
            [delegate authDidEndWithLogin:nil
                                 password:nil
                                   author:nil
                                    error:nil];
            
    }
    
    
}

- (void)unAuthenticate {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[NSURL URLWithString:kHTTPHost] absoluteURL]];
    for (NSHTTPCookie * cookie in cookies) {
        if([cookie.name isEqualToString:kSessionCookieName]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    self.authenticatedUser = nil;
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req  authenticated:(BOOL)auth{
    
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[req host]] autorelease];
    request.downloadProgressDelegate = downloadProgressDelegate_;
    request.uploadProgressDelegate = uploadProgressDelegate_;
    [request setUseCookiePersistence:auth];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30];
    [request appendPostData:[[req source] dataUsingEncoding:NSUTF8StringEncoding]];
    LogDebug(@"executeXMLRPCRequest host: %@",[req host]);
    //LogDebug(@"executeXMLRPCRequest request: %@",[req source]);
    [request startSynchronous];
    request.uploadProgressDelegate = nil;
    self.uploadProgressDelegate = nil;
    request.downloadProgressDelegate = nil;
    self.downloadProgressDelegate = nil;
    //generic error
    NSError *err = [request error];
    if (err) {
        //TODO ERROR
        LogDebug(@"executeXMLRPCRequest error: %@", err);
        return err;
    }
    
    
    int statusCode = [request responseStatusCode];
    if (statusCode >= 404) {
        NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[request responseStatusMessage], NSLocalizedDescriptionKey, nil];
        NSError * error = [NSError errorWithDomain:kNetworkRequestErrorDomain code:statusCode userInfo:usrInfo];
        return error;
    }
    
    LogDebug(@"executeXMLRPCRequest response: %@", [request responseString]);
    XMLRPCResponse *userInfoResponse = [[[XMLRPCResponse alloc] initWithData:[request responseData]] autorelease];
    if([userInfoResponse isKindOfClass:[NSError class]]){
        return userInfoResponse;
    }
    
    return [userInfoResponse object];
}

@end
