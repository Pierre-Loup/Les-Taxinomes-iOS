//
//  LTHTTPClient.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTHTTPClient.h"

@implementation LTHTTPClient

- (instancetype)init
{
    NSURL *baseUrl = [NSURL URLWithString:LTPWebServiceURL];
    self = [super initWithBaseURL:baseUrl];
    if (self) {

    }
    return self;
}

@end
