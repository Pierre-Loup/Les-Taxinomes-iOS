//
//  LTJSONClient.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTHTTPClient.h"

@interface LTJSONClient : LTHTTPClient

/**
 LTJSONClient shared instance.
 Should never be release.
 */
+ (LTJSONClient *)sharedClient;

@end
