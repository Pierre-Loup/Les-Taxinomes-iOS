//
//  TaxinomesAppDelegate.m
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

#import "TaxinomesAppDelegate.h"
#import "MediasListViewController.h"
#import "LTConnectionManager.h"
#import "LTDataManager.h"
#import "Constants.h"
#import "License.h"
#import "DCIntrospect.h"

@implementation TaxinomesAppDelegate

@synthesize window = window_; 
@synthesize tabBarController = tabBarController_;
@synthesize launchScreenView = launchScreenView_;

- (void)applicationDidFinishLaunching:(UIApplication *)application{
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    if ([[License allLicenses] count] == 0) {
        [connectionManager getLicenses];
    }
    
    UINavigationBar *bar = [self.tabBarController.navigationController navigationBar];
    [bar setTintColor:[UIColor colorWithRed:(95.0/255.0) green:(130.0/255) blue:(55.0/255.0) alpha:1.0]];
    [self.window addSubview: self.tabBarController.view];
    [self.window makeKeyAndVisible];
    
    // Press space in the simulator to start UI Introspection
    #if TARGET_IPHONE_SIMULATOR
        [[DCIntrospect sharedIntrospector] start];
    #endif
    
    NSString * launchSoundPath = [[NSBundle mainBundle] pathForResource:@"oiseau" ofType:@"aif"];
    if (launchSoundPath) {
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: launchSoundPath], &launchSoundID_);
    }
    [self playLaunchSound];
    
    launchScreenView_ = [[UIImageView alloc] initWithFrame: self.tabBarController.view.frame];
    launchScreenView_.image = [UIImage imageNamed:@"Default.png"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [launchScreenView_ removeFromSuperview];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self.window addSubview:launchScreenView_];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
    UIImageView *launchScreenView = [[UIImageView alloc] initWithFrame:navigationController.view.frame];
    launchScreenView.image = [UIImage imageNamed:@"Default.png"];
    [navigationController.view addSubview:launchScreenView];
     */
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissLaunchScreenView:) userInfo:nil repeats:NO];
    
    [self playLaunchSound];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(launchSoundID_);
    [launchScreenView_ release];
    self.tabBarController = nil;
    self.window = nil;
    [super dealloc];
}

#pragma mark Helpers

- (void) dismissLaunchScreenView:(NSTimer*)timer {
    [launchScreenView_ removeFromSuperview];
}

- (void) playLaunchSound {
    AudioServicesPlaySystemSound(launchSoundID_);
}

@end
