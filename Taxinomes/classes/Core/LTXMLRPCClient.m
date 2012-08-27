//
//  LTXMLRPCClient.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTXMLRPCClient.h"

#import "XMLRPCRequest.h"

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
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    [self setSMDefaultHeader];
    
    LogDebug(@"WS url: %@", self.baseURL);
    LogDebug(@"WS method: %@", method);
    
    XMLRPCRequest* xmlrpcRequest = [[[XMLRPCRequest alloc] initWithHost:self.baseURL] autorelease];
    [xmlrpcRequest setMethod:method withObject:parameters?parameters:[NSDictionary dictionary]];
    LogDebug(@"REQUEST: %@",[xmlrpcRequest source]);
    [super postPath:@""
         parameters:[NSDictionary dictionaryWithObject:[xmlrpcRequest source] forKey:@"body"]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               if ([responseObject isKindOfClass:[NSData class]]) {
                   id response = [[[[XMLRPCResponse alloc] initWithData:responseObject] autorelease] object];
                   LogDebug(@"RESPONSE: %@",response);
                   if (![response isKindOfClass:[NSError class]]) {
                       success(operation,response);
                   } else {
                       failure(operation, nil);
                   }
               } else {
                   failure(operation, nil);
               }
                   
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               // erreur technique
               failure(operation,error);
           }];
}

- (void)setSMDefaultHeader
{
}

@end
