//
//  LTViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup on 07/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#define kLoadingLabel @"Chargement"

#import "LTViewController.h"

@implementation LTViewController
@synthesize loaderView = loaderView_;

#pragma mark - Loader

- (void) displayLoaderViewWithDetermination:(BOOL)determinate whileExecuting:(SEL)myTask {
    if (loaderView_ != nil) {
        [loaderView_ removeFromSuperview];
        [loaderView_ release];
    }
    
    loaderView_ = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    
	// Add HUD to screen
	[[[UIApplication sharedApplication] keyWindow] addSubview:loaderView_];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	loaderView_.delegate = self;
	loaderView_.labelText = kLoadingLabel;
    
    if (determinate) {
        loaderView_.mode = MBProgressHUDModeDeterminate;
    }
    
	// Show the HUD while the provided method executes in a new thread
	[loaderView_ showWhileExecuting:myTask onTarget:self withObject:nil animated:YES];
}

- (void) displayLoader {
    if (loaderView_ != nil) {
        [loaderView_ removeFromSuperview];
        [loaderView_ release];
    }
    
    loaderView_ = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    
	// Add HUD to screen
	[[[UIApplication sharedApplication] keyWindow] addSubview:loaderView_];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	loaderView_.delegate = self;
	loaderView_.labelText = kLoadingLabel;
    
	// Show the HUD while the provided method executes in a new thread
	[loaderView_ show:YES];
}


- (void) hideLoaderView {
    // Remove HUD from screen when the HUD was hidden
	[loaderView_ removeFromSuperview];
	[loaderView_ release];
    loaderView_ = nil;
}

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidden
	[loaderView_ removeFromSuperview];
	[loaderView_ release];
    loaderView_ = nil;
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
    loaderView_ = nil;
    [super viewDidLoad];
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
    [super dealloc];
    // Remove HUD from screen when the HUD was hidden
	[loaderView_ removeFromSuperview];
	[loaderView_ release];
    loaderView_ = nil;
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    NSLog(@"%f",newProgress);
    loaderView_.progress = newProgress;
}

@end
