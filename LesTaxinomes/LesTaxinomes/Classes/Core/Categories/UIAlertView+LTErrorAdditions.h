//
//  UIAlertView+LTErrorAdditions.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 03/11/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (LTErrorAdditions)

+(UIAlertView*) showWithError:(NSError*) error;

@end
