//
//  LTTableViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 31/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "LTTableViewController.h"
#import "LTiPhoneBackgroundView.h"

@interface LTTableViewController ()
@end

@implementation LTTableViewController
@synthesize hud = _hud;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass Overrides


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:kNavigationBarColor];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    _hud = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
#pragma mark Properties

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = YES;
    }
    return _hud;
}

#pragma mark - Public methods

- (void)showDefaultHud {
    [self.view.window addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
}

- (void)showDeterminateHud {
    [self.view.window addSubview:self.hud];
	self.hud.mode = MBProgressHUDModeDeterminate;
    [self.hud show:YES];
}

- (void)showErrorHudWithText:(NSString *)text {
    [self.view.window addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeCustomView;
	self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_hudicon.png"]];
	if (text)
        self.hud.labelText = text;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

- (void)showConfirmHudWithText:(NSString *)text {
    [self.view.window addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeCustomView;
	self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_hudicon.png"]];
	if (text)
        self.hud.labelText = text;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

- (void)showHudWithTextOnly:(NSString *)text {
    [self.view.window addSubview:self.hud];
	self.hud.mode = MBProgressHUDModeText;
	self.hud.labelText = text;
	self.hud.margin = 10.f;
	self.hud.yOffset = 150.f;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[self.hud removeFromSuperview];
    _hud = nil;
}

@end
