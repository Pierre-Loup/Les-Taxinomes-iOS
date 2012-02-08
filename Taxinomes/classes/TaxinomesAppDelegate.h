//
//  TaxinomesAppDelegate.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 13/10/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>
 
 */

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