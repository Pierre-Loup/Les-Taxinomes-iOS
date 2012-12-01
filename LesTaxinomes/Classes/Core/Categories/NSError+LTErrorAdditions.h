//
//  NSError+LTErrorAdditions.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 03/11/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* LTXMLRPCMethodKey;

@interface NSError (LTErrorAdditions)
- (BOOL)shouldBeDisplayed;
@end
