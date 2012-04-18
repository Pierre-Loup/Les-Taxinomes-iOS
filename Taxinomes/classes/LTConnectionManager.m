//
//  LTConnectionManager.m
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

#import "LTConnectionManager.h"
#import "XMLRPCResponse.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "Media.h"
#import "Author.h"
#import "License.h"

static LTConnectionManager *instance = nil;

@implementation LTConnectionManager
@synthesize error = _error;
@synthesize author= _author;
@synthesize progressDelegate = progressDelegate_;
@synthesize authStatus, delegate;

- (void)dealloc {
	[instance release];
	[super dealloc];
}

+ (LTConnectionManager *)sharedConnectionManager {
	if(instance == nil) {
		instance = [[LTConnectionManager alloc] init];
        instance.author = UNAUTHENTICATED;
	}
	
	return instance;
}

- (id)init {
	if (self = [super init]) {
        
	}
	return self;
}

- (NSArray *)getmediasByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start{
    
    NSMutableArray *medias = [[NSMutableArray alloc] initWithCapacity:limit];
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], nil] forKeys:[NSArray arrayWithObjects:@"limite", nil]];
    [xmlrpcRequest setMethod:@"spip.liste_medias" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        //NSLog(@"failed");
        return [NSMutableArray array];
    }
    
    for(NSDictionary *media in result){
        [medias addObject:[Media mediaWithXMLRPCResponse:media]];
    }
    
    return medias;
}

- (NSArray *)getShortmediasByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start{
    
    NSMutableArray *medias = [[[NSMutableArray alloc] initWithCapacity:limit] autorelease];
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", @"champs_demandes", @"tri", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], requestedFields, [NSArray arrayWithObject:@"date DESC"], @"carre", thumbnailWidth, thumbnailHeight, nil];
    //NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", nil];
    //NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.liste_medias" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        //NSLog(@"failed");
        return [NSMutableArray array];
    }
    
    for(NSDictionary *media in result){
        [medias addObject:[Media mediaWithXMLRPCResponse:media]];
    }
    
    return medias;
}

- (Media *)getShortmediaWithId: (NSString *) id_media{
        
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_media", @"titre", @"date", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"id_media", @"champs_demandes", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    //NSLog(@"%f",kScreenScale);
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:id_media, requestedFields, @"carre", thumbnailWidth, thumbnailHeight, nil];
    //NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", nil];
    //NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return [NSMutableArray array];
    }
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return nil;
    }
    
    return [Media mediaWithXMLRPCResponse:result];

}

- (Media *)getmediaWithId: (NSString *) id_media{
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    //NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_media intValue]],[NSNumber numberWithDouble:[UIScreen mainScreen].bounds.size.width ], nil] forKeys:[NSArray arrayWithObjects:@"id_media", @"document_largeur", nil]];
    //NSLog(@"%f",kScreenScale*MEDIA_MAX_WIDHT);
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_media intValue]],[NSNumber numberWithDouble:MEDIA_MAX_WIDHT], nil] forKeys:[NSArray arrayWithObjects:@"id_media", @"document_largeur", nil]];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return nil;
    }
    
    return [Media mediaWithXMLRPCResponse:result];
    
}

- (Author *)getAuthorWithId: (NSString *) id_author{
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_author intValue]], nil] forKeys:[NSArray arrayWithObjects:@"id_auteur", nil]];
    [xmlrpcRequest setMethod:@"spip.lire_auteur" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSDictionary class]]){
        return [Author authorWithXMLRPCResponse:result];
    } else {
        return nil;
    }
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

- (void)getSectionWithIdentifier:(NSNumber*)identifier {
    XMLRPCRequest* xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:identifier, nil] forKeys:[NSArray arrayWithObjects:@"id_rubrique", nil]];
    [xmlrpcRequest setMethod:@"spip.lire_rubrique" withObject:args];
    id response = [self executeXMLRPCRequest:xmlrpcRequest authenticated:NO];
    [xmlrpcRequest release];
    /*
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
    */
}

- (void)authWithLogin:(NSString *) login password:(NSString *) password{
    self.authStatus = AUTH_PENDING;
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSArray arrayWithObjects:login, password, nil];
    [xmlrpcRequest setMethod:@"spip.auth" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSDictionary class]]){
        self.authStatus = AUTHENTICATED;
        self.author = [Author authorWithXMLRPCResponse:result];
        [delegate didAuthenticate];
    } else {
        self.authStatus = AUTH_FAILED;
        //TODO: LOCAL ERROR LABELS
        [delegate didFailToAuthenticate:@"Login ou mot de passe éronné"];

    }
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req  authenticated:(BOOL)auth{
    
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[req host]];
    request.uploadProgressDelegate = progressDelegate_;
    request.downloadProgressDelegate = progressDelegate_;
    [request setUseCookiePersistence:auth];
	[request setRequestMethod:@"POST"];
	[request setTimeOutSeconds:30];
    //NSLog(@"executeXMLRPCRequest host: %@",[req host]);
    //NSLog(@"executeXMLRPCRequest request: %@",[req source]);
    [request appendPostData:[[req source] dataUsingEncoding:NSUTF8StringEncoding]];
	[request startSynchronous];
	
	//generic error
	NSError *err = [request error];
    if (err) {
        //TODO ERROR
        //NSLog(@"executeXMLRPCRequest error: %@", err);
		[request release];
        return err;
    }
    
    
    int statusCode = [request responseStatusCode];
    if (statusCode >= 404) {
         NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[request responseStatusMessage], NSLocalizedDescriptionKey, nil];
        self.error = [NSError errorWithDomain:@"org.taxinomes.iphone.http_connection_error" code:statusCode userInfo:usrInfo];
        [request release];
        return self.error;
    }
    
	NSLog(@"executeXMLRPCRequest response: %@", [request responseString]);	
	XMLRPCResponse *userInfoResponse = [[[XMLRPCResponse alloc] initWithData:[request responseData]] autorelease];
    if([userInfoResponse isKindOfClass:[NSError class]]){
        [request release];
        return userInfoResponse;
    }
	[request release];
	
    return [userInfoResponse object];
    
}

- (Media *)addmediaWithInformations: (NSDictionary *)info {
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    [xmlrpcRequest setMethod:@"geodiv.creer_media" withObject:info];
    [self executeXMLRPCRequest:xmlrpcRequest authenticated:YES];
    [xmlrpcRequest release];
}

@end