//
//  LTXMLRPCClient.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "AFHTTPClient.h"
#import "XMLRPCResponse.h"

@interface LTXMLRPCClient : AFHTTPClient
+ (LTXMLRPCClient *)sharedClient;
- (void)executeMethod:(NSString *)method
       withParameters:(NSDictionary *)parameters
     authCookieEnable:(BOOL)authCookieEnable
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
