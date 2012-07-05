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

#define kLoadingLabel @"Chargement"

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
	loaderView_.labelText = kLoadingLabel;
    
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
	loaderView_.labelText = kLoadingLabel;
    
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
    /*
     UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
     backgroundView.image = [UIImage imageNamed:@"fond.png"];
     CGRect backgroundSubviewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     UIView *backgroundSubview = [[UIView alloc] initWithFrame:backgroundSubviewFrame];
     backgroundSubview.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.90];
     [backgroundView addSubview:backgroundSubview];
     [self.view addSubview:backgroundView];
     */
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
    NSLog(@"%f",newProgress);
#endif
    loaderView_.progress = newProgress;
}

@end
