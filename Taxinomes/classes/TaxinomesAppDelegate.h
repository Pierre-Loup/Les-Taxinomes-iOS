//
//  TaxinomesAppDelegate.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 13/10/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TaxinomesAppDelegate : UIResponder <UIApplicationDelegate>{
    SystemSoundID launchSoundID_;
    
}

@property (nonatomic, retain) IBOutlet IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController* tabBarController;
@property (nonatomic, retain) IBOutlet UISplitViewController* splitViewController;
@property (nonatomic, retain) UIImageView *launchScreenView;

- (void) dismissLaunchScreenView:(NSTimer*)timer;
- (void) playLaunchSound;

@end
