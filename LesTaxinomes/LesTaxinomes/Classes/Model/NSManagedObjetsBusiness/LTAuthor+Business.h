//
//  Author+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAuthor.h"

@interface LTAuthor (Business)

+ (LTAuthor *)authorWithXMLRPCResponse:(NSDictionary *)response inContext:(NSManagedObjectContext*)context error:(NSError **)error;
+ (LTAuthor *)authorWithIdentifier:(NSNumber*)identifier inContext:(NSManagedObjectContext*)context;

@end
