//
//  TaxinomesAppDelegate.m
//  Taxinomes
//
//  Created by mac adam on 13/10/11.
//  Copyright 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import "TaxinomesAppDelegate.h"
#import "MediasListViewController.h"
#import "ConnectionManager.h"
#import "DataManager.h"
#import "Constants.h"

@implementation TaxinomesAppDelegate

@synthesize window = _window; 
@synthesize tabBarController =_tabBarController;
@synthesize launchScreenView = _launchScreenView;

/*- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    return YES;
}*/

- (void)applicationDidFinishLaunching:(UIApplication *)application{
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        kScreenScale = [UIScreen mainScreen].scale;
    } else {
        // non-Retina display
        kScreenScale = 1.0;
    }
    
    /*
    // on déclare le tabbar :
    tabBarController = [[UITabBarController alloc] init];
    //on initialise media et on l'implémente en mettant dans un controlleur
    site = [[SiteTaxinomes alloc] init];
    UINavigationController *tableNavController = [[[UINavigationController alloc] initWithRootViewController:site] autorelease];
    tableNavController.tabBarItem.image = [UIImage imageNamed:@"naviguer.png"];
    [site release];
    [tableNavController setNavigationBarHidden:TRUE];
    //pareil pour caméra
    media = [[MediaViewController alloc] init];
    UINavigationController *table2NavController = [[[UINavigationController alloc] initWithRootViewController:media] autorelease];
    table2NavController.tabBarItem.image = [UIImage imageNamed:@"media.png"];
    [media release];
    [table2NavController setNavigationBarHidden:TRUE];
    //on implemente le tabbar
    tabBarController.viewControllers = [NSArray arrayWithObjects:tableNavController,table2NavController,nil];
    */
    
    //MediasListViewController *mediasListViewController = [[MediasListViewController alloc] initWithNibName:@"MediasListView" bundle:nil];
    //navigationController = [[UINavigationController alloc] initWithRootViewController:mediasListViewController];
    //[mediasListViewController release];
    //DataManager *dataManager = [DataManager sharedDataManager];    
    //Article *article = [dataManager getArticleWithId:@"27"];
    //[dataManager getArticles];
    //ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    //connectionManager getArticlesByDateWithLimit:5 startingAtRecord:5];
    //[connectionManager getAuthorWithId:@"207"];
    UINavigationBar *bar = [self.tabBarController.navigationController navigationBar];
    [bar setTintColor:[UIColor colorWithRed:(95.0/255.0) green:(130.0/255) blue:(55.0/255.0) alpha:1.0]];
    [self.window addSubview: self.tabBarController.view];
    //[mediasListViewController release];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    self.launchScreenView = [[UIImageView alloc] initWithFrame: self.tabBarController.view.frame];
    self.launchScreenView.image = [UIImage imageNamed:@"Default.png"];
    [self.tabBarController.view addSubview:self.launchScreenView];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
    UIImageView *launchScreenView = [[UIImageView alloc] initWithFrame:navigationController.view.frame];
    launchScreenView.image = [UIImage imageNamed:@"Default.png"];
    [navigationController.view addSubview:launchScreenView];
     */
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissLaunchScreenView:) userInfo:nil repeats:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    self.tabBarController = nil;
    self.window = nil;
    [super dealloc];
}

-(void) dismissLaunchScreenView:(NSTimer*)timer {
    [self.launchScreenView removeFromSuperview];
    self.launchScreenView = nil;
}

@end
