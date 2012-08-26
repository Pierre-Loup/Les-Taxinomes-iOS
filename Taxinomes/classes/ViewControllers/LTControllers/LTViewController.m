//
//  LTViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup on 07/03/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import "LTViewController.h"

@implementation LTViewController
@synthesize loaderView = loaderView_;

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
    // background for iPhone screen
    if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect winFrame = [[UIApplication sharedApplication] keyWindow].frame;
        CGRect bgFrame = CGRectMake(0, -self.navigationController.navigationBar.frame.size.height,
                                    winFrame.size.width,
                                    winFrame.size.height);
        bgView_ = [[LTiPhoneBackgroundView alloc] initWithFrame:bgFrame];
        bgView_.light = YES;
        [self.view addSubview:bgView_];
        [self.view sendSubviewToBack:bgView_];
    }
    [self.navigationController.navigationBar setTintColor:kStandardGreenColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [loaderView_ removeFromSuperview];
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

- (void)dealloc {
	[loaderView_ release];
    [super dealloc];
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    LogDebug(@"%f",newProgress);
    loaderView_.progress = newProgress;
}

@end
