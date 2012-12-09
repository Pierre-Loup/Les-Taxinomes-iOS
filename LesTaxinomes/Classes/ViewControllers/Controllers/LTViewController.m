//
//  LTViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup on 07/03/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "LTViewController.h"

@interface LTViewController ()
@property (nonatomic, retain) LTiPhoneBackgroundView* bgView;
@end

@implementation LTViewController
@synthesize hud = _hud;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // background for iPhone screen
    if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect winFrame = [[UIApplication sharedApplication] keyWindow].frame;
        CGRect bgFrame = CGRectMake(0, -self.navigationController.navigationBar.frame.size.height,
                                    winFrame.size.width,
                                    winFrame.size.height);
        self.bgView = [[[LTiPhoneBackgroundView alloc] initWithFrame:bgFrame] autorelease];
        self.bgView.light = YES;
        [self.view addSubview:self.bgView];
        [self.view sendSubviewToBack:self.bgView];
        self.bgView.frame = bgFrame;
    }
    
    [self.navigationController.navigationBar setTintColor:kMainColor];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    [_hud release];
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

- (void)showDefaultHud {
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[self.hud removeFromSuperview];
    [_hud release];
    _hud = nil;
}


@end
