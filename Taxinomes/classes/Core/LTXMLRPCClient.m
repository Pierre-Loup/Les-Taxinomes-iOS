//
//  LTXMLRPCClient.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTXMLRPCClient.h"

#import "XMLRPCRequest.h"
#import "AFXMLRequestOperation.h"

#define kDataParamKey @"data"
#define kFaultCodeKey @"faultCode"
#define kFaultStringKey @"faultString"

@implementation LTXMLRPCClient

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
       withParameters:(NSDictionary *)parameters
     authCookieEnable:(BOOL)authCookieEnable
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [self setSMDefaultHeader];
    
    LogDebug(@"WS url: %@", self.baseURL);
    LogDebug(@"WS method: %@", method);
    
    XMLRPCRequest* xmlrpcRequest = [[[XMLRPCRequest alloc] initWithHost:self.baseURL] autorelease];
    [xmlrpcRequest setMethod:method withObject:parameters?parameters:[NSDictionary dictionary]];
    LogDebug(@"REQUEST: %@",[xmlrpcRequest source]);
    

    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self.baseURL absoluteURL]];
    NSString* cookieHeaderValue = @"";
    for (NSHTTPCookie * cookie in cookies) {
        if(cookie.value != nil &&
           ![cookie.value isEqualToString:@""] &&
           ![cookie.name isEqualToString: kSessionCookieName]) {
            if ([cookieHeaderValue isEqualToString:@""]) {
				cookieHeaderValue = [NSString stringWithFormat: @"%@=%@",cookie.name,cookie.value];
			} else {
				cookieHeaderValue = [NSString stringWithFormat: @"%@; %@=%@",cookieHeaderValue,cookie.name,cookie.value];
			}
        } else if ([cookie.name isEqualToString: kSessionCookieName] &&
                   authCookieEnable) {
            if ([cookieHeaderValue isEqualToString:@""]) {
				cookieHeaderValue = [NSString stringWithFormat: @"%@=%@",cookie.name,cookie.value];
			} else {
				cookieHeaderValue = [NSString stringWithFormat: @"%@; %@=%@",cookieHeaderValue,cookie.name,cookie.value];
			}
        }
    }
    [self setDefaultHeader:@"Cookie" value:cookieHeaderValue];
    
    [super postPath:@""
         parameters:[NSDictionary dictionaryWithObject:[[xmlrpcRequest source] dataUsingEncoding:self.stringEncoding] forKey:kDataParamKey]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id response = [[[[XMLRPCResponse alloc] initWithData:responseObject] autorelease] object];
                LogDebug(@"RESPONSE: %@",response);
                if (![response isKindOfClass:[NSError class]]) {
                    NSError* wsResponseError = nil;
                    if ([response isKindOfClass:[NSDictionary class]]) {
                        NSString* faultCode = [(NSDictionary *)response objectForKey:kFaultCodeKey];
                        NSString* faultString = [(NSDictionary *)response objectForKey:kFaultStringKey];
                        if (faultCode && faultString) {
                            wsResponseError = [NSError errorWithDomain:kLTWebServiceResponseErrorDomain
                                                                  code:[faultCode integerValue]
                                                              userInfo:[NSDictionary dictionaryWithObject:faultString forKey:NSLocalizedDescriptionKey]];
                        }
                    }
                    
                    if (!wsResponseError) {
                        success(operation,response);
                    } else {
                        failure(operation, wsResponseError);
                    }
                } else {
                    failure(operation, (NSError *)response);
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failure(operation,error);
            }];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    
    if ([method isEqualToString:@"POST"]) {
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
        [request setValue:[NSString stringWithFormat:@"text/xml; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[parameters objectForKey:kDataParamKey]];
    }
    
	return request;
}

- (void)setSMDefaultHeader
{
    [self setDefaultHeader:@"Content-Type" value:@"text/xml"];
    [self setDefaultHeader:@"Accept" value:@"text/xml"];
}

@end
