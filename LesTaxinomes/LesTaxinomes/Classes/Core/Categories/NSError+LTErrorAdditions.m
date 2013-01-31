//
//  NSError+LTErrorAdditions.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 03/11/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "NSError+LTErrorAdditions.h"

@implementation NSError (LTErrorAdditions)

- (BOOL)shouldBeDisplayed {
    return [self localizedDescription] || [self localizedRecoverySuggestion];
}

@end
