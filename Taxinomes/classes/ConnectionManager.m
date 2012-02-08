//
//  ConnectionManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import "ConnectionManager.h"
#import "XMLRPCResponse.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "Article.h"
#import "Author.h"

static ConnectionManager *instance = nil;

@implementation ConnectionManager

- (void)dealloc {
	[instance release];
	[super dealloc];
}

+ (ConnectionManager *)sharedConnectionManager {
	if(instance == nil) {
		instance = [[ConnectionManager alloc] init];
	}
	
	return instance;
}

- (id)init {
	if (self = [super init]) {
        
	}
	return self;
}

- (NSArray *)getArticlesByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start{
    
    NSMutableArray *articles = [[NSMutableArray alloc] initWithCapacity:limit];
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], nil] forKeys:[NSArray arrayWithObjects:@"limite", nil]];
    [xmlrpcRequest setMethod:@"spip.liste_articles" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        //NSLog(@"failed");
        return [NSMutableArray array];
    }
    
    for(NSDictionary *article in result){
        [articles addObject:[Article articleWithXMLRPCResponse:article]];
    }
    
    return articles;
}

- (NSArray *)getShortArticlesByDateWithLimit: (NSInteger) limit startingAtRecord: (NSInteger) start{
    
    NSMutableArray *articles = [[[NSMutableArray alloc] initWithCapacity:limit] autorelease];
    
    if(limit == 0 || limit > kDefaultLimit)
        limit = kDefaultLimit;
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_article", @"titre", @"date", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", @"champs_demandes", @"tri", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(kScreenScale*THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(kScreenScale*THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], requestedFields, [NSArray arrayWithObject:@"date DESC"], @"carre", thumbnailWidth, thumbnailHeight, nil];
    //NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", nil];
    //NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.liste_medias" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        //NSLog(@"failed");
        return [NSMutableArray array];
    }
    
    for(NSDictionary *article in result){
        [articles addObject:[Article articleWithXMLRPCResponse:article]];
    }
    
    return articles;
}

- (Article *)getShortArticleWithId: (NSString *) id_article{
        
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSArray *requestedFields = [NSArray arrayWithObjects:@"id_article", @"titre", @"date", @"vignette", @"auteurs", nil];
    NSArray *argsKeys = [NSArray arrayWithObjects:@"id_article", @"champs_demandes", @"vignette_format", @"vignette_largeur", @"vignette_hauteur", nil];
    //NSLog(@"%f",kScreenScale);
    NSNumber *thumbnailWidth = [NSNumber numberWithDouble:(kScreenScale*THUMBNAIL_MAX_WIDHT)];
    NSNumber *thumbnailHeight = [NSNumber numberWithDouble:(kScreenScale*THUMBNAIL_MAX_HEIGHT)];
    NSArray *argsObjects = [NSArray arrayWithObjects:id_article, requestedFields, @"carre", thumbnailWidth, thumbnailHeight, nil];
    //NSArray *argsKeys = [NSArray arrayWithObjects:@"limite", nil];
    //NSArray *argsObjects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d,%d", start, limit], nil];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:argsObjects forKeys:argsKeys];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return [NSMutableArray array];
    }
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return nil;
    }
    
    return [Article articleWithXMLRPCResponse:result];

}

- (Article *)getArticleWithId: (NSString *) id_article{
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    //NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_article intValue]],[NSNumber numberWithDouble:[UIScreen mainScreen].bounds.size.width ], nil] forKeys:[NSArray arrayWithObjects:@"id_article", @"document_largeur", nil]];
    //NSLog(@"%f",kScreenScale*MEDIA_MAX_WIDHT);
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_article intValue]],[NSNumber numberWithDouble:kScreenScale*MEDIA_MAX_WIDHT], nil] forKeys:[NSArray arrayWithObjects:@"id_article", @"document_largeur", nil]];
    [xmlrpcRequest setMethod:@"geodiv.lire_media" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSError class]]){
        NSLog(@"failed");
        return nil;
    }
    
    return [Article articleWithXMLRPCResponse:result];
    
}

- (Author *)getAuthorWithId: (NSString *) id_author{
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_author intValue]], nil] forKeys:[NSArray arrayWithObjects:@"id_auteur", nil]];
    [xmlrpcRequest setMethod:@"spip.lire_auteur" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSDictionary class]]){
        return [Author authorWithXMLRPCResponse:result];
    } else {
        return nil;
    }
}

- (Author *)authWithLogin:(NSString *) login password:(NSString *) password{
    
    XMLRPCRequest *xmlrpcRequest = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:kXMLRCPWebServiceURL]];
    NSDictionary *args = [NSArray arrayWithObjects:login, password, nil];
    [xmlrpcRequest setMethod:@"spip.auth" withObject:args];
    id result = [self executeXMLRPCRequest:xmlrpcRequest];
    [xmlrpcRequest release];
    
    if([result isKindOfClass:[NSDictionary class]]){
        return [Author authorWithXMLRPCResponse:result];
    } else {
        return nil;
    }
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req {
    
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[req host]];
	[request setRequestMethod:@"POST"];
	[request setTimeOutSeconds:30];
    NSLog(@"executeXMLRPCRequest host: %@",[req host]);
    NSLog(@"executeXMLRPCRequest request: %@",[req source]);
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

@end
