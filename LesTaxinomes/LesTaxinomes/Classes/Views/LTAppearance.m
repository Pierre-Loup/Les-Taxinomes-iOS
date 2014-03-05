//
//  LTAppearance.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 12/02/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAppearance.h"

@implementation LTAppearance

+ (void)setup
{
    if (IOS7_OR_GREATER)
    {
        [self setupiOS7Apprearance];
    }
    else
    {
        [self setupiOS6Apprearance];
    }
}

+ (void)setupiOS7Apprearance
{
    [UIApplication sharedApplication].keyWindow.tintColor = kLTColorMain;
    
    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       UITextAttributeTextColor:[UIColor blackColor],
       UITextAttributeTextShadowColor:[UIColor whiteColor],
       UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
       UITextAttributeFont:[UIFont fontWithName:@"Jesaya Free" size:20]
       }];
}

+ (void)setupiOS6Apprearance
{
    [[UINavigationBar appearance] setTintColor:kLTColorNavigationBar];
    
    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       UITextAttributeTextColor:[UIColor blackColor],
       UITextAttributeTextShadowColor:[UIColor whiteColor],
       UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
       UITextAttributeFont:[UIFont fontWithName:@"Jesaya Free" size:20]
       }];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UITabBar appearance] setTintColor:kLTColorNavigationBar];
    [[UITabBar appearance] setSelectedImageTintColor:kLTColorMain];
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        UITextAttributeTextColor: [UIColor lightGrayColor]
                                                        }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        UITextAttributeTextColor: kLTColorMain
                                                        }
                                             forState:UIControlStateSelected];
}

@end
