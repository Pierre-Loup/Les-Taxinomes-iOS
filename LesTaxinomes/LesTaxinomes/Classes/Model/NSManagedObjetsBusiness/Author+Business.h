//
//  Author+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "Author.h"

@interface Author (Business)

+ (Author *)authorWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (Author *)authorWithIdentifier: (NSNumber *)identifier;
+ (NSArray *)allAuthors;

@end
