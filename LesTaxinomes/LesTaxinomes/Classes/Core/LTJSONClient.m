//
//  LTJSONClient.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTJSONClient.h"

@implementation LTJSONClient

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (LTJSONClient *)sharedClient
{
    static LTJSONClient*    _sharedClient = nil;
    static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      _sharedClient = [[self alloc] init];
                  });
    
    return _sharedClient;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)setDefaultHeader
{
    [self setDefaultHeader:@"Accept" value:@"text/json"];
}

@end
