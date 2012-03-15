//
//  LTViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup on 07/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "LTViewController.h"

@implementation LTViewController
@synthesize loaderView = loaderView_;

#pragma mark - Loader

- (void) displayLoaderViewWithDetermination:(BOOL)determinate whileExecuting:(SEL)myTask {
    // Should be initialized with the windows frame so the HUD disables all user input by covering the entire screen
	loaderView_ = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    
	// Add HUD to screen
	[self.view.window addSubview:loaderView_];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	loaderView_.delegate = self;
    
	loaderView_.labelText = @"Loading";
    
    if (determinate) {
        loaderView_.mode = MBProgressHUDModeDeterminate;
    }
    
	// Show the HUD while the provided method executes in a new thread
	[loaderView_ showWhileExecuting:myTask onTarget:self withObject:nil animated:YES];
}


- (void) hideLoaderView {
    // Remove HUD from screen when the HUD was hidden
	[loaderView_ removeFromSuperview];
	[loaderView_ release];
}

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidden
	[loaderView_ removeFromSuperview];
	[loaderView_ release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    NSLog(@"%f",newProgress);
    loaderView_.progress = newProgress;
}

@end
