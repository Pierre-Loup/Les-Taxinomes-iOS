//
//  UIImageView+LT.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 25/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTMedia;

@interface UIImageView (LT)

-(void)setImageWithMedia:(LTMedia*)media completion:(void(^)())completion;

@end
