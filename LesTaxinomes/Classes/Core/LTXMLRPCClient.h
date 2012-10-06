//
//  LTXMLRPCClient.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "AFHTTPClient.h"
#import "XMLRPCResponse.h"

extern NSString* const LTXMLRPCServerErrorDomain;

@interface LTXMLRPCClient : AFHTTPClient

/**
 LTXMLRPCClient shared instance. 
 Should never be release.
 */
+ (LTXMLRPCClient *)sharedClient;

/**
 Creates and execute an XML-RPC request.
 
 @param method The XML-RPC method to be called.
 @param object The object to be serialized on the request body.
 @param success A block object to be executed when the request finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes two arguments:, the created request operation and the `NSError` object describing the network or parsing error that occurred.
 
 @see HTTPRequestOperationWithRequest:success:failure
 */
- (void)executeMethod:(NSString *)method
           withObject:(id)object
     authCookieEnable:(BOOL)authCookieEnable
              success:(void (^)(id response))success
              failure:(void (^)(NSError *error))failure;
@end
