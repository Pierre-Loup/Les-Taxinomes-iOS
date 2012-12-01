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
    LTiPhoneBackgroundView* bgView_;
}
@end

@implementation LTTableViewController
@synthesize hud = _hud;

#pragma mark - View lifecycle

- (void)dealloc {
    [_hud release];
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
    [_hud release];
    _hud = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Properties

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = YES;
    }
    return _hud;
}

#pragma mark - Public methods

- (void)showHudForLoading {
    [self.view addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
}

- (void)showDeterminateHud {
    [self.view addSubview:self.hud];
	self.hud.mode = MBProgressHUDModeDeterminate;
    [self.hud show:YES];
}

- (void)showErrorHudWithText:(NSString *)text {
    [self.view addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeCustomView;
	self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_hudicon.png"]] autorelease];
	if (text)
        self.hud.labelText = text;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

- (void)showConfirmHudWithText:(NSString *)text {
    [self.view addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeCustomView;
	self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_hudicon.png"]] autorelease];
	if (text)
        self.hud.labelText = text;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

- (void)showHudWithTextOnly:(NSString *)text {
    [self.view addSubview:self.hud];
	self.hud.mode = MBProgressHUDModeText;
	self.hud.labelText = text;
	self.hud.margin = 10.f;
	self.hud.yOffset = 150.f;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

- (void)updateProgress:(float)newProgress {
    LogDebug(@"%f",newProgress);
    self.hud.progress = newProgress;
}

@end
