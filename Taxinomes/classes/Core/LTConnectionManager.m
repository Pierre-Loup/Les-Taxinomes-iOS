//
//  LTConnectionManager.m
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

#import <SystemConfiguration/SystemConfiguration.h>
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
@synthesize progressDelegate = progressDelegate_;
@synthesize authDelegate = authDelegate_;
@synthesize authStatus;

- (void)dealloc {
	[instance release];
    self.authenticatedUser = nil;
    self.authDelegate = nil;
    self.progressDelegate = nil;
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

- (void)getShortMediasAsychByDateWithLimit:(NSInteger)limit startingAtRecord:(NSInteger)start delegate:(id<LTConnectionManagerDelegate>)delegate{
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", @"champs_demandes", @"tri", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], requestedFields, [NSArray arrayWithObject:@"date DESC"], @"carre", thumbnailWidth, thumbnailHeight, nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.liste_medias" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([result isKindOfClass:[NSArray  class]]) {
                NSMutableArray *medias = [NSMutableArray arrayWithCapacity:limit];
                for(NSDictionary *media in result){
                    [medias addObject:[Media mediaWithXMLRPCResponse:media]];
                }
                [delegate didRetrievedShortMedias:medias];
            } else if ([result isKindOfClass:[NSError class]]){
                [delegate didFailWithError:result];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Medias",kLTConnectionManagerInternalError];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
                [delegate didFailWithError:error];
            }
        });
    });
}

- (NSArray *)getShortMediasByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start {
    
    NSMutableArray *medias = [[[NSMutableArray alloc] initWithCapacity:limit] autorelease];
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", @"champs_demandes", @"tri", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], requestedFields, [NSArray arrayWithObject:@"date DESC"], @"carre", thumbnailWidth, thumbnailHeight, nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.liste_medias" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        return [NSMutableArray array];
    }
    
    return medias;
}

- (Media *)getMediaWithId:(NSNumber *)mediaIdentifier {
    if (!mediaIdentifier) {
        return nil;
    }
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:mediaIdentifier,[NSNumber numberWithDouble:MEDIA_MAX_WIDHT], nil] forKeys:[NSArray arrayWithObjects:@"id_article", @"document_largeur", nil]];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return nil;
    }
    return [Media mediaWithXMLRPCResponse:result];
}

- (void)getMediaAsynchWithId:(NSNumber *)mediaIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate {
    if (!mediaIdentifier) {
        return;
    }
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:mediaIdentifier,[NSNumber numberWithDouble:MEDIA_MAX_WIDHT], nil] forKeys:[NSArray arrayWithObjects:@"id_article", @"document_largeur", nil]];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([result isKindOfClass:[NSDictionary class]]) {
                [delegate didRetrievedMedia:[Media mediaWithXMLRPCResponse:result]];
            } else if ([result isKindOfClass:[NSError class]]){
                [delegate didFailWithError:result];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Media with id: %d",kLTConnectionManagerInternalError, [mediaIdentifier intValue]];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
                [delegate didFailWithError:error];
            }
        });
    });
}

- (Author *)getAuthorWithId:(NSNumber *)authorIdentifier {
    if (!authorIdentifier) {
        return nil;
    }
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:authorIdentifier, nil] forKeys:[NSArray arrayWithObjects:@"id_auteur", nil]];
    [xmlrpcRequest setMethod:@"spip.lire_auteur" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSDictionary class]]){
        return [Author authorWithXMLRPCResponse:result];
    } else {
        return nil;
    }
}

- (void)getAuthorAsynchWithId:(NSNumber *)authorIdentifier delegate:(id<LTConnectionManagerDelegate>)delegate {
    if (!authorIdentifier) {
        return;
    }
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:authorIdentifier, nil] forKeys:[NSArray arrayWithObjects:@"id_auteur", nil]];
    [xmlrpcRequest setMethod:@"spip.lire_auteur" withObject:args];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([result isKindOfClass:[NSDictionary class]]) {
                [delegate didRetrievedAuthor:[Author authorWithXMLRPCResponse:result]];
            } else if ([result isKindOfClass:[NSError class]]){
                [delegate didFailWithError:result];
            } else {
                NSString * localizedErrorString = [NSString stringWithFormat:@"%@ Failed retrieving Author with id: %d",kLTConnectionManagerInternalError, [authorIdentifier intValue]];
                NSDictionary * userInfo = [NSDictionary dictionaryWithObject:localizedErrorString forKey:NSLocalizedDescriptionKey];
                NSError * error = [NSError errorWithDomain:kLTConnectionManagerInternalError code:0 userInfo:userInfo];
                [delegate didFailWithError:error];
            }
        });
    });
}

- (NSArray*)getLicenses {
    XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"spip.liste_licences" withObject:[NSDictionary dictionary]];
    id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    if ( [response isKindOfClass: [NSDictionary class]]) {
        NSDictionary* responseDict = (NSDictionary*)response;
        NSMutableArray* licenses = [[NSMutableArray alloc] initWithCapacity:[responseDict count]];
        for(NSString *key in response){
            if ([[responseDict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *xmlLicenseDict = [responseDict objectForKey:key];
                License* license = nil;
                license = [License licenseWithXMLRPCResponse:xmlLicenseDict];
                if (license != nil) {
                    [licenses addObject:license];
                }
            }
            
        }
        return [licenses autorelease];
    } else {
        return nil;
    }
}

/*
 - (void)getSectionWithIdentifier:(NSNumber*)identifier {
 XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
 NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:identifier, nil] forKeys:[NSArray arrayWithObjects:@"id_rubrique", nil]];
 [xmlrpcRequest setMethod:@"spip.lire_rubrique" withObject:args];
 id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
 [xmlrpcRequest release];
 if ( [response isKindOfClass: [NSDictionary class]]) {
 NSDictionary* responseDict = (NSDictionary*)response;
 NSMutableArray* licenses = [[NSMutableArray alloc] initWithCapacity:[responseDict count]];
 for(NSString *key in response){
 if ([[responseDict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
 NSDictionary *xmlLicenseDict = [responseDict objectForKey:key];
 License* license = nil;
 license = [License licenseWithXMLRPCResponse:xmlLicenseDict];
 if (license != nil) {
 [licenses addObject:license];
 }
 }
 
 }
 return [licenses autorelease];
 } else {
 return nil;
 }
 
 }
 //*/

- (void)authAsynchWithLogin:(NSString *)login password:(NSString *)password delegate:(id<LTConnectionManagerAuthDelegate>)delegate{
    self.authStatus = AUTH_PENDING;
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSArray arrayWithObjects:login, password, nil];
    [xmlrpcRequest setMethod:@"spip.auth" withObject:args];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([result isKindOfClass:[NSDictionary class]]){
                self.authStatus = AUTHENTICATED;
                self.authenticatedUser = [Author authorWithXMLRPCResponse:result];
                [authDelegate_ didAuthenticateWithAuthor:self.authenticatedUser];
            } else {
                self.authStatus = AUTH_FAILED;
                //TODO: LOCAL ERROR LABELS
                if ([result isKindOfClass:[NSError class]]) {
                    NSError * error = (NSError *)result;
                    [authDelegate_ didFailToAuthenticateWithError:error];
                } else {
                    NSError * error = [NSError errorWithDomain:kLTAuthenticationFailedError code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:TRANSLATE(@"error_auth_failed"), NSLocalizedDescriptionKey, nil]];
                    [authDelegate_ didFailToAuthenticateWithError:error];
                }
            }
        });
    });
}

- (BOOL)isAuthenticated {
    BOOL returnValue = NO;
    if (authenticatedUser_ == nil) {
        return returnValue;
    }
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[NSURL URLWithString:kHTTPHost] absoluteURL]];
    for (NSHTTPCookie * cookie in cookies) {
        if([cookie.name isEqualToString:kSessionCookieName]
           && cookie.value != nil
           && ![cookie.value isEqualToString:@""]
           && [cookie.expiresDate timeIntervalSinceNow] > 0.0) {
            returnValue = YES;
        }
    }
    return returnValue;
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

- (void)addMediaWithInformations: (NSDictionary *)info {
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"geodiv.creer_media" withObject:info];
    [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
    [xmlrpcRequest release];
}

- (void)addMediaAsynchWithInformations: (NSDictionary *)info delegate:(id<LTConnectionManagerDelegate>)delegate {
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"geodiv.creer_media" withObject:info];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [xmlrpcRequest release];
            if([result isKindOfClass:[NSDictionary class]]) {
                if ([result objectForKey:@"faultString"] 
                    && [result objectForKey:@"faultCode"]) {
                    if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                        [delegate didFailWithError:result];
                    }
                } else {
                    if ([delegate respondsToSelector:@selector(didSuccessfullyUploadMedia:)]) {
                        [delegate didSuccessfullyUploadMedia:[Media mediaWithXMLRPCResponse:result]];
                    }
                }
            } else if ([result isKindOfClass:[NSError class]]){
                if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                    [delegate didFailWithError:result];
                }
            } else {
                if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
                    [delegate didFailWithError:nil];
                }
            }
        });
    });
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req  authenticated:(BOOL)auth{
    
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[req host]];
    request.uploadProgressDelegate = progressDelegate_;
    [request setUseCookiePersistence:auth];
	[request setRequestMethod:@"POST"];
	[request setTimeOutSeconds:30];
    [request appendPostData:[[req source] dataUsingEncoding:NSUTF8StringEncoding]];
#if DEBUG
    //NSLog(@"executeXMLRPCRequest host: %@",[req host]);
    //NSLog(@"executeXMLRPCRequest request: %@",[req source]);
#endif  
	[request startSynchronous];
	request.uploadProgressDelegate = nil;
	//generic error
	NSError *err = [request error];
    if (err) {
        //TODO ERROR
#if DEBUG
        NSLog(@"executeXMLRPCRequest error: %@", err);
#endif
		[request release];
        return err;
    }
    
    
    int statusCode = [request responseStatusCode];
    if (statusCode >= 404) {
        NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[request responseStatusMessage], NSLocalizedDescriptionKey, nil];
        NSError * error = [NSError errorWithDomain:kNetworkRequestErrorDomain code:statusCode userInfo:usrInfo];
        [request release];
        return error;
    }
    
#if DEBUG
	NSLog(@"executeXMLRPCRequest response: %@", [request responseString]);
#endif
	XMLRPCResponse *userInfoResponse = [[[XMLRPCResponse alloc] initWithData:[request responseData]] autorelease];
    if([userInfoResponse isKindOfClass:[NSError class]]){
        [request release];
        return userInfoResponse;
    }
	[request release];
	
    return [userInfoResponse object];
}

@end
