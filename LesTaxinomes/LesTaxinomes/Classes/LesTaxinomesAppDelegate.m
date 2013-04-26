//
//  LesTaxinomesAppDelegate.m
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

#import "LesTaxinomesAppDelegate.h"

#import "DCIntrospect.h"
#import "License.h"
#import "LTAppearance.h"
#import "LTConnectionManager.h"

@implementation LesTaxinomesAppDelegate
@synthesize window = window_;
@synthesize tabBarController = tabBarController_;
@synthesize launchScreenView = launchScreenView_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Taxinomes.sqlite"];
    
    // Retreive licenses
    [[LTConnectionManager sharedConnectionManager] getLicensesWithResponseBlock:^(NSArray *licenses, NSError *error) {
    }];
    
    // Setup tabbar names
    NSArray* tabItemsTitles = @[_T(@"tabbar.home"),
                                _T(@"tabbar.medias"),
                                _T(@"tabbar.explore"),
                                _T(@"tabbar.myaccount"),
                                _T(@"tabbar.authors")];
    
    for (NSInteger i = 0;
         i < self.tabBarController.tabBar.items.count;
         i++) {
        UINavigationController* navigationController = self.tabBarController.viewControllers[i];
        ((UIViewController*)navigationController.viewControllers[0]).title = tabItemsTitles[i];
        ((UITabBarItem*)self.tabBarController.tabBar.items[i]).title = tabItemsTitles[i];
    }
    
    // iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.window.rootViewController = self.splitViewController;
    } else { // iPhone
        self.window.rootViewController = self.tabBarController;
    }
    
    [self.window makeKeyAndVisible];
    
    // Press space in the simulator to start UI Introspection
    #if TARGET_IPHONE_SIMULATOR
        [[DCIntrospect sharedIntrospector] start];
    #endif
    
    
    // Setup launch sound and play it application were not woken up by location event
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSString * launchSoundPath = [[NSBundle mainBundle] pathForResource:@"oiseau" ofType:@"aif"];
        if (launchSoundPath) {
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: launchSoundPath], &launchSoundID_);
        }
        [self playLaunchSound];
    }
    
    // Setup fack spash screen
    launchScreenView_ = [[UIImageView alloc] initWithFrame: self.tabBarController.view.frame];
    launchScreenView_.image = [UIImage imageNamed:@"Default.png"];
    
    [LTAppearance setup];
    
    return YES;
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
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(launchSoundID_);
}

#pragma mark Helpers

- (void) dismissLaunchScreenView:(NSTimer*)timer {
    [launchScreenView_ removeFromSuperview];
}

- (void) playLaunchSound {
    AudioServicesPlaySystemSound(launchSoundID_);
}

@end
