//
//  LTTableViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 31/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "LTTableViewController.h"

@interface LTTableViewController ()

@end

@implementation LTTableViewController@synthesize loaderView = loaderView_;

#pragma mark - Loader

- (void) displayLoaderViewWithDetermination{
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

- (void) displayLoader {
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


- (void) hideLoader {
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
        loaderView_ = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    loaderView_ = nil;
    
    [self.navigationController.navigationBar setTintColor:kStandardGreenColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [loaderView_ removeFromSuperview];
    [loaderView_ release];
    loaderView_ = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)dealloc {
    // Remove HUD from screen when the HUD was hidden
	[loaderView_ removeFromSuperview];
	[loaderView_ release];
    loaderView_ = nil;
    [super dealloc];
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress {
#if DEBUG
    LogDebug(@"%f",newProgress);
#endif
    loaderView_.progress = newProgress;
}

@end
