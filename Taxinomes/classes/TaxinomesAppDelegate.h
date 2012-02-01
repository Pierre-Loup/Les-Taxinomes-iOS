//
//  TaxinomesAppDelegate.h
//  Taxinomes
//
//  Created by mac adam on 13/10/11.
//  Copyright 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaViewController;
@class SiteTaxinomes;

@interface TaxinomesAppDelegate : NSObject <UIApplicationDelegate>{
    UIWindow *_window;
    UITabBarController *_tabBarController;
    UIImageView *_launchScreenView;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UIImageView *launchScreenView;

-(void) dismissLaunchScreenView:(NSTimer*)timer;

@end
