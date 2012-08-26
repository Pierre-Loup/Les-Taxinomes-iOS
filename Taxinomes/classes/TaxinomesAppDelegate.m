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
    
    // Get the licenses list if not present
    if ([[License allLicenses] count] == 0) {
        [[LTConnectionManager sharedConnectionManager] getLicenses];
    }
    
    
    // iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.window addSubview:self.splitViewController.view];
    } else { // iPhone
        UINavigationBar *bar = [self.tabBarController.navigationController navigationBar];
        [bar setTintColor:[UIColor colorWithRed:(95.0/255.0) green:(130.0/255) blue:(55.0/255.0) alpha:1.0]];
        [self.window addSubview: self.tabBarController.view];
    }
    
    
    
    [self.window makeKeyAndVisible];
    
    // Press space in the simulator to start UI Introspection
    #if TARGET_IPHONE_SIMULATOR
        [[DCIntrospect sharedIntrospector] start];
    #endif
    
    // Setup launch sound and play it
    NSString * launchSoundPath = [[NSBundle mainBundle] pathForResource:@"oiseau" ofType:@"aif"];
    if (launchSoundPath) {
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: launchSoundPath], &launchSoundID_);
    }
    [self playLaunchSound];
    // Setup fack spash screen
    launchScreenView_ = [[UIImageView alloc] initWithFrame: self.tabBarController.view.frame];
    launchScreenView_.image = [UIImage imageNamed:@"Default.png"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [launchScreenView_ removeFromSuperview];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Prepare fake splash screen to be displayed when application enter foreground
    [self.window addSubview:launchScreenView_];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Display splash screen, and dismiss it 2 sec later
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissLaunchScreenView:) userInfo:nil repeats:NO];
    [self playLaunchSound];
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
    [window_ release];
    [launchScreenView_ release];
    [tabBarController_ release];
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
