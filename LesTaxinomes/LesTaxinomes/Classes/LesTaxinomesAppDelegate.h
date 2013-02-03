//
//  LesTaxinomesAppDelegate.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 13/10/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface LesTaxinomesAppDelegate : UIResponder <UIApplicationDelegate>{
    SystemSoundID launchSoundID_;
    
}

@property (nonatomic, strong) IBOutlet IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController* tabBarController;
@property (nonatomic, strong) IBOutlet UISplitViewController* splitViewController;
@property (nonatomic, strong) UIImageView *launchScreenView;

- (void) dismissLaunchScreenView:(NSTimer*)timer;
- (void) playLaunchSound;

@end
