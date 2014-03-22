//
//  LTSection+Business.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTSection.h"

@interface LTSection (Business)

+ (LTSection *)sectonWithJSONResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
