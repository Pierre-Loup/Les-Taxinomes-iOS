//
//  LTAppearance.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 12/02/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAppearance.h"

@implementation LTAppearance

+ (void)setup {

    [[UINavigationBar appearance] setTintColor:kLTColorNavigationBar];

    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
    @{
        UITextAttributeTextColor:[UIColor blackColor],
        UITextAttributeTextShadowColor:[UIColor whiteColor],
        UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
        UITextAttributeFont:[UIFont fontWithName:@"Jesaya Free" size:20]
    }];
    
    //[[UITabBar appearance] setTintColor:kLTColorNavigationBar];
    //[[UITabBar appearance] setSelectedImageTintColor:kLTColorMain];
    
}

@end
