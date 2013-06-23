//
//  UIGlossyButton+LT.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 21/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "UIGlossyButton+LT.h"

@implementation UIGlossyButton (LT)

- (void)setupStandardMainColorButton
{
    self.tintColor = kLTColorMain;
    self.buttonCornerRadius = 10;
    [self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitle:_T(@"medias.loadmorebutton.title") forState:UIControlStateNormal];
}

@end
