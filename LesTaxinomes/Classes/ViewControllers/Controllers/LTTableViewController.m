//
//  LTTableViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 31/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "LTTableViewController.h"
#import "LTiPhoneBackgroundView.h"

@interface LTTableViewController () {
    MBProgressHUD *loaderView_;
    LTiPhoneBackgroundView* bgView_;
}

@end

@implementation LTTableViewController@synthesize loaderView = loaderView_;

#pragma mark - Loader

- (void) startLoadingAnimationViewWithDetermination{
    if (loaderView_ != nil) {
        return;
    }
    
    loaderView_ = [[MBProgressHUD alloc] initWithView:self.view];
    
	// Add HUD to screen
	[self.view addSubview:loaderView_];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	loaderView_.delegate = self;
	loaderView_.labelText = TRANSLATE(@"common.loading");
    
    loaderView_.mode = MBProgressHUDModeDeterminate;
    
	// Show the HUD while the provided method executes in a new thread
	[loaderView_ show:YES];
}

- (void) startLoadingAnimation {
    if (loaderView_ != nil) {
        return;
    }
    
    loaderView_ = [[MBProgressHUD alloc] initWithView:self.view];
    
	// Add HUD to screen
	[self.view addSubview:loaderView_];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	loaderView_.delegate = self;
	loaderView_.labelText = TRANSLATE(@"common.loading");
    
	// Show the HUD while the provided method executes in a new thread
	[loaderView_ show:YES];
}


- (void) stopLoadingAnimation {
    // Remove HUD from screen when the HUD was hidden
    if(loaderView_) {
        [loaderView_ removeFromSuperview];
        [loaderView_ release];
        loaderView_ = nil;
    }
}

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidden
    if (loaderView_) {
        [loaderView_ removeFromSuperview];
        [loaderView_ release];
        loaderView_ = nil;
    }
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [loaderView_ release];
    [super dealloc];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // background for iPhone screen
    if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect winFrame = [[UIApplication sharedApplication] keyWindow].frame;
        CGRect bgFrame = CGRectMake(0, -self.navigationController.navigationBar.frame.size.height,
                                    winFrame.size.width,
                                    winFrame.size.height);
        bgView_ = [[LTiPhoneBackgroundView alloc] initWithFrame:bgFrame];
        bgView_.light = YES;
        [self.tableView setBackgroundView:bgView_];
    }
    
    [self.navigationController.navigationBar setTintColor:kStandardGreenColor];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    [loaderView_ release];
    loaderView_ = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setProgress:(float)newProgress {
    LogDebug(@"%f",newProgress);
    loaderView_.progress = newProgress;
}

@end
