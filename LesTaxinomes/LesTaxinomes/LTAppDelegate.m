//
//  LTAppDelegate.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 23/06/13.
//  Copyright (c) 2013 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAppDelegate.h"

#import "LTAppearance.h"
#import "LTConnectionManager.h"

#ifdef DEBUG
#import <PonyDebugger/PonyDebugger.h>
#endif

@implementation LTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"LesTaxinomes.sqlite"];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    [self.window makeKeyAndVisible];
    
    [LTAppearance setup];

    
    // Setup tabBar titles
    UITabBarController* tabBarController = (UITabBarController*)self.window.rootViewController;
    NSArray* tabItemsTitles = @[_T(@"tabbar.home")
                                ,_T(@"tabbar.medias")
                                ,_T(@"tabbar.explore")
                                ,_T(@"tabbar.authors")
                                ,_T(@"tabbar.tree")
                                ];
    NSArray* tabItemsImagesBaseNames = @[_T(@"tabbar_home")
                                         ,_T(@"tabbar_medias")
                                         ,_T(@"tabbar_map")
                                         ,_T(@"tabbar_authors")
                                         ,_T(@"tabbar_tree")
                                         ];
    
    NSString* imageNormalSuffix = @"_white";
    NSString* imageSelectedSuffix = @"_gold";
    for (NSInteger i = 0;
         i < tabBarController.tabBar.items.count;
         i++)
    {
        UINavigationController* navigationController = tabBarController.viewControllers[i];
        ((UIViewController*)navigationController.viewControllers[0]).title = tabItemsTitles[i];
         UITabBarItem* tabbarItem = tabBarController.tabBar.items[i];
         tabbarItem.title = tabItemsTitles[i];
        
        NSString* imageBaseName = tabItemsImagesBaseNames[i];
        NSString* normalImageName = [NSString stringWithFormat:@"%@%@", imageBaseName, imageNormalSuffix];
        NSString* selectedImageName = [NSString stringWithFormat:@"%@%@", imageBaseName, imageSelectedSuffix];
        if (IOS7_OR_GREATER)
        {
            tabbarItem.image = [UIImage imageNamed:selectedImageName];
        }
        else
        {
            [tabbarItem setFinishedSelectedImage:[UIImage imageNamed:selectedImageName]
               withFinishedUnselectedImage:[UIImage imageNamed:normalImageName]];
        }
        
    }
    
    // Retreive licenses
    [[LTConnectionManager sharedManager] getLicensesWithResponseBlock:^(NSArray *licenses, NSError *error) {
    }];
    
    // Retrieve Tree
//    [[LTConnectionManager sharedManager] fetchFullTreeWithCompletion:^(NSError *error)
//     {
//         if (error)
//         {
//             LogError(@"%@", error);
//         }
//     }];
    
#ifdef DEBUG
#if TARGET_IPHONE_SIMULATOR
    PDDebugger *debugger = [PDDebugger defaultInstance];
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    [debugger enableViewHierarchyDebugging];
    [debugger enableCoreDataDebugging];
    [debugger addManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]
                             withName:@"Main context"];
#endif
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
