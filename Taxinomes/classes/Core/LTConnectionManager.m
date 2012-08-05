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
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "Media.h"
#import "Author.h"
#import "License.h"

static LTConnectionManager *instance = nil;

@implementation LTConnectionManager
@synthesize authenticatedUser = authenticatedUser_;
@synthesize downloadProgressDelegate = downloadProgressDelegate_;
@synthesize uploadProgressDelegate = uploadProgressDelegate_;
@synthesize authDelegate = authDelegate_;
@synthesize authStatus;

- (void)dealloc {
	[instance release];
    self.authenticatedUser = nil;
    self.authDelegate = nil;
    self.downloadProgressDelegate = nil;
    self.uploadProgressDelegate = nil;
	[super dealloc];
}

+ (LTConnectionManager *)sharedConnectionManager {
	if(instance == nil) {
		instance = [[LTConnectionManager alloc] init];
	}
	
	return instance;
}

- (id)init {
	if (self = [super init]) {
        self.authStatus = UNAUTHENTICATED;
	}
	return self;
}

- (void)getShortMediasByDateForAuthor:(Author *)author 
                                 withLimit:(NSInteger)limit 
                          startingAtRecord:(NSInteger)start 
                                  delegate:(id<LTConnectionManagerDelegate>)delegate{
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"statut", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", @"champs_demandes", @"tri", @"vignette_format", @"vignette_largeur", @"vignette_hauteur",@"statut", nil];
    
    BOOL authenticated = NO;
    if (author) {
        authenticated = YES;
    }
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], requestedFields, [NSArray arrayWithObject:@"date DESC"], @"carre", thumbnailWidth, thumbnailHeight, @"publie", nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.liste_medias" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:authenticated];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSArray  class]]) {
                NSMutableArray *medias = [NSMutableArray arrayWithCapacity:limit];
                for(NSDictionary *mediaXML in response){
                    Media * mediaObject = [Media mediaWithXMLRPCResponse:mediaXML];
                    if (mediaObject) {
                        [medias addObject:mediaObject];
                    }
                }
                [delegate didRetrievedShortMedias:medias];
            } else if ([response isKindOfClass:[NSError class]]){
                [delegate didFailWithError:response];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Medias",kLTConnectionManagerInternalError];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError 
                                                      code:0 
                                                  userInfo:userInfo];
                [delegate didFailWithError:error];
            }
            [response release];
        });
    });
}

- (void)getShortMediasNearLocation:(CLLocationCoordinate2D)location
                        forAuthor:(Author *)author
                        withLimit:(NSInteger)limit 
                 startingAtRecord:(NSInteger)start 
                         delegate:(id<LTConnectionManagerDelegate>)delegate {
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"statut", @"gis", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", @"champs_demandes", @"tri", @"lat", @"lon", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    
    BOOL authenticated = NO;
    if (author) {
        authenticated = YES;
    }
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSString * strLat = [NSString stringWithFormat:@"%f",location.latitude];
    NSString * strLon = [NSString stringWithFormat:@"%f",location.longitude];
    NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], requestedFields, [NSArray arrayWithObject:@"distance"], strLat, strLon, @"carre", thumbnailWidth, thumbnailHeight, nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.liste_medias" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
         NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:authenticated];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSArray  class]]) {
                NSMutableArray *medias = [NSMutableArray arrayWithCapacity:limit];
                for(NSDictionary *mediaXML in response){
                    Media * mediaObject = [Media mediaWithXMLRPCResponse:mediaXML];
                    if (mediaObject) {
                        [medias addObject:mediaObject];
                    }
                }
                [delegate didRetrievedShortMedias:medias];
            } else if ([response isKindOfClass:[NSError class]]){
                [delegate didFailWithError:response];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Medias",kLTConnectionManagerInternalError];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError 
                                                      code:0 
                                                  userInfo:userInfo];
                [delegate didFailWithError:error];
            }
            [response release];
        });
    });
}

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
         NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSDictionary class]]) {
                [delegate didRetrievedMedia:[Media mediaWithXMLRPCResponse:response]];
            } else if ([response isKindOfClass:[NSError class]]){
                [delegate didFailWithError:response];
            } else {
                NSString* localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Media with id: %d",kLTConnectionManagerInternalError, [mediaIdentifier intValue]];
                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
                [delegate didFailWithError:error];
            }
            [response release];
        });
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
        NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSDictionary class]]) {
                [delegate didRetrievedMedia:[Media mediaLargeURLWithXMLRPCResponse:response]];
            } else if ([response isKindOfClass:[NSError class]]){
                [delegate didFailWithError:response];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Media with id: %d",kLTConnectionManagerInternalError, [mediaIdentifier intValue]];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
                [delegate didFailWithError:error];
            }
            [response release];
        });
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
        NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSDictionary class]]) {
                [delegate didRetrievedAuthor:[Author authorWithXMLRPCResponse:response]];
            } else if ([response isKindOfClass:[NSError class]]){
                [delegate didFailWithError:response];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Author with id: %d",kLTConnectionManagerInternalError, [authorIdentifier intValue]];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
                [delegate didFailWithError:error];
            }
            [response release];
        });
    });
}

- (void)getLicenses {
    XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"spip.liste_licences" withObject:[NSDictionary dictionary]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSDictionary class]]) {
                NSDictionary* responseDict = (NSDictionary*)response;
                for(NSString *key in response){
                    if ([[responseDict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *xmlLicenseDict = [responseDict objectForKey:key];
                        [License licenseWithXMLRPCResponse:xmlLicenseDict];
                    }
                    
                }
            }
            [response release];
        });
    });
}

- (void)addMediaWithInformations: (NSDictionary *)info delegate:(id<LTConnectionManagerDelegate>)delegate {
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"geodiv.creer_media" withObject:info];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
        [response retain];
        [pool release];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSDictionary class]]) {
                if ([response objectForKey:@"faultString"] 
                    && [response objectForKey:@"faultCode"]) {
                    if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                        [delegate didFailWithError:response];
                    }
                } else {
                    if ([delegate respondsToSelector:@selector(didSuccessfullyUploadMedia:)]) {
                        [delegate didSuccessfullyUploadMedia:[Media mediaWithXMLRPCResponse:response]];
                    }
                }
            } else if ([response isKindOfClass:[NSError class]]){
                if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                    [delegate didFailWithError:response];
                }
            } else {
                if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                    [delegate didFailWithError:nil];
                }
            }
            [response release];
        });
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
        NSAutoreleasePool* pool = [NSAutoreleasePool new];
        id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
        [response retain];
        [pool release];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([response isKindOfClass:[NSDictionary class]]){
                self.authStatus = AUTHENTICATED;
                self.authenticatedUser = [Author authorWithXMLRPCResponse:response];
                [delegate authDidEndWithLogin:login
                                     password:password
                                       author:self.authenticatedUser
                                        error:nil];
            } else {
                self.authStatus = AUTH_FAILED;
                if ([response isKindOfClass:[NSError class]]) {
                    NSError * error = (NSError *)response;
                    [delegate authDidEndWithLogin:login
                                         password:password
                                           author:nil
                                            error:error];
                } else {
                    NSError * error = [NSError errorWithDomain:kLTAuthenticationFailedError code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:TRANSLATE(@"error_auth_failed"), NSLocalizedDescriptionKey, nil]];
                    [delegate authDidEndWithLogin:login
                                         password:password
                                           author:nil
                                            error:error];
                }
            }
            [response release];
        });
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
    
    if (authenticatedUser_) {
            [delegate authDidEndWithLogin:nil
                                 password:nil
                                   author:authenticatedUser_
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
#if DEBUG
    NSLog(@"executeXMLRPCRequest host: %@",[req host]);
    NSLog(@"executeXMLRPCRequest request: %@",[req source]);
#endif  
	[request startSynchronous];
	request.uploadProgressDelegate = nil;
    self.uploadProgressDelegate = nil;
    request.downloadProgressDelegate = nil;
    self.downloadProgressDelegate = nil;
	//generic error
	NSError *err = [request error];
    if (err) {
        //TODO ERROR
#if DEBUG
        NSLog(@"executeXMLRPCRequest error: %@", err);
#endif
        return err;
    }
    
    
    int statusCode = [request responseStatusCode];
    if (statusCode >= 404) {
        NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[request responseStatusMessage], NSLocalizedDescriptionKey, nil];
        NSError * error = [NSError errorWithDomain:kNetworkRequestErrorDomain code:statusCode userInfo:usrInfo];
        return error;
    }
    
#if DEBUG
	NSLog(@"executeXMLRPCRequest response: %@", [request responseString]);
#endif
	XMLRPCResponse *userInfoResponse = [[[XMLRPCResponse alloc] initWithData:[request responseData]] autorelease];
    if([userInfoResponse isKindOfClass:[NSError class]]){
        return userInfoResponse;
    }
	
    return [userInfoResponse object];
}

@end
