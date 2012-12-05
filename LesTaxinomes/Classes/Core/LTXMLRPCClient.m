//
//  LTXMLRPCClient.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTXMLRPCClient.h"

#import "XMLRPCRequest.h"
#import "AFXMLRequestOperation.h"
#import "LTConnectionManager.h"

#define kBodyParamKey @"body"
#define kFaultCodeKey @"faultCode"
#define kFaultStringKey @"faultString"

NSString* const LTXMLRPCServerErrorDomain = @"org.lestaxinomes.app.iphone.LesTaxinomes.LTXMLRPCServerError";

NSString* const LTXMLRCPMethodSPIPListeLicences = @"spip.liste_licences";
NSString* const LTXMLRCPMethodSPIPLireAuteur = @"spip.lire_auteur";
NSString* const LTXMLRCPMethodSPIPAuth = @"spip.auth";
NSString* const LTXMLRCPMethodGeoDivListeMedias = @"geodiv.liste_medias";
NSString* const LTXMLRCPMethodGeoDivLireMedia = @"geodiv.lire_media";
NSString* const LTXMLRCPMethodGeoDivCreerMedia = @"geodiv.creer_media";



@interface LTXMLRPCClient ()
- (void)setDefaultHeader;
@end

@implementation LTXMLRPCClient

#pragma mark - Public

+ (LTXMLRPCClient *)sharedClient {
    static LTXMLRPCClient*    _sharedClient = nil;
    static dispatch_once_t  onceToken;
    
    NSString *baseUrl = kXMLRCPWebServiceURL;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    });
    
    return _sharedClient;
}

- (void)executeMethod:(NSString *)method
           withObject:(id)object
     authCookieEnable:(BOOL)authCookieEnable
              success:(void (^)(id response))success
              failure:(void (^)(NSError *error))failure
{
    [self executeMethod:method
             withObject:object
       authCookieEnable:authCookieEnable
    uploadProgressBlock:nil
  downloadProgressBlock:nil
                success:success
                failure:failure];
}

- (void)executeMethod:(NSString *)method
           withObject:(id)object
     authCookieEnable:(BOOL)authCookieEnable
  uploadProgressBlock:(void (^)(CGFloat progress))uploadProgressBlock
downloadProgressBlock:(void (^)(CGFloat progress))downloadProgressBlock
              success:(void (^)(id response))success
              failure:(void (^)(NSError *error))failure
{
    
    if (!method) {
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerInternalError
                                         userInfo:nil];
        if(failure) failure(error);
    }
    
    [self setDefaultHeader];
    
    LogDebug(@"WS url: %@", self.baseURL);
    LogDebug(@"WS method: %@", method);
    
    // Create XML-RPC body from array or dict object parameter
    NSDictionary* parameters = nil;
    XMLRPCRequest* xmlrpcRequest = [[[XMLRPCRequest alloc] initWithURL:self.baseURL] autorelease];
    [xmlrpcRequest setMethod:method withParameter:object?object:@{}];
    if (method != LTXMLRCPMethodGeoDivCreerMedia) LogDebug(@"REQUEST: %@",[xmlrpcRequest body]);
    parameters = @{kBodyParamKey :  [[xmlrpcRequest body] dataUsingEncoding:self.stringEncoding]};
    
    // Cookies management
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self.baseURL absoluteURL]];
    NSString* cookieHeaderValue = @"";
    for (NSHTTPCookie * cookie in cookies) {
        //Add cookies other than session cookie
        if(![cookie.name isEqualToString: kSessionCookieName]) {
            if ([cookieHeaderValue isEqualToString:@""]) {
				cookieHeaderValue = [NSString stringWithFormat: @"%@=%@",cookie.name,cookie.value];
			} else {
				cookieHeaderValue = [NSString stringWithFormat: @"%@; %@=%@",cookieHeaderValue,cookie.name,cookie.value];
			}
            // Add session cookie only if authCookieEnable is YES
        } else if ([cookie.name isEqualToString: kSessionCookieName] &&
                   authCookieEnable) {
            if ([cookieHeaderValue isEqualToString:@""]) {
				cookieHeaderValue = [NSString stringWithFormat: @"%@=%@",cookie.name,cookie.value];
			} else {
				cookieHeaderValue = [NSString stringWithFormat: @"%@; %@=%@",cookieHeaderValue,cookie.name,cookie.value];
			}
        }
    }
    // Add cookies to the request header
    [self setDefaultHeader:@"Cookie" value:cookieHeaderValue];
    
    // Create success block
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject);
    successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        id response = [[[[XMLRPCResponse alloc] initWithData:responseObject] autorelease] object];
        LogDebug(@"RESPONSE: %@",response);
        if (![response isKindOfClass:[NSError class]]) {
            NSError* wsResponseError = nil;
            if ([response isKindOfClass:[NSDictionary class]]) {
                NSString* faultCode = [(NSDictionary *)response objectForKey:kFaultCodeKey];
                NSString* faultString = [(NSDictionary *)response objectForKey:kFaultStringKey];
                if (faultCode && faultString) {
                    wsResponseError = [NSError errorWithDomain:LTXMLRPCServerErrorDomain
                                                          code:[faultCode integerValue]
                                                      userInfo:@{NSLocalizedDescriptionKey:faultString,LTXMLRPCMethodKey:method}];
                }
            }
            
            // Succes block call
            if (!wsResponseError && success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(response);
                });
            }
            // Failure block calls
            else if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(wsResponseError);
                });
            }
        } else if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure((NSError *)response);
            });
        }
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
    failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    };
    
    NSURLRequest *request = [self requestWithMethod:@"POST" path:@"" parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:successBlock
                                                                      failure:failureBlock];
    if (downloadProgressBlock)
        [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            downloadProgressBlock(((CGFloat)totalBytesRead)/((CGFloat)totalBytesExpectedToRead));
        }];

    if (uploadProgressBlock)
        [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            uploadProgressBlock(((CGFloat)totalBytesWritten)/((CGFloat)totalBytesExpectedToWrite));
        }];
    operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Private

- (void)setDefaultHeader {
    [self setDefaultHeader:@"Content-Type" value:@"text/xml"];
    [self setDefaultHeader:@"Accept" value:@"text/xml"];
}

#pragma mark - Overwride

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    
    if ([method isEqualToString:@"POST"]) {
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
        [request setValue:[NSString stringWithFormat:@"text/xml; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[parameters objectForKey:kBodyParamKey]];
    }
    
	return request;
}

@end
