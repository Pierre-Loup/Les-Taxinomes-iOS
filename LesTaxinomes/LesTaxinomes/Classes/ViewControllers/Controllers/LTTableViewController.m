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
@property (nonatomic, retain) LTiPhoneBackgroundView* bgView;
@end

@implementation LTTableViewController
@synthesize hud = _hud;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass Overrides

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
        self.bgView = [[[LTiPhoneBackgroundView alloc] initWithFrame:bgFrame] autorelease];
        self.bgView.light = YES;
        self.bgView.frame = bgFrame;
        UIView* tableViewBackgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
        [tableViewBackgroundView addSubview:self.bgView];
        self.tableView.backgroundView = tableViewBackgroundView;
        [tableViewBackgroundView release];
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
	self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_hudicon.png"]] autorelease];
	if (text)
        self.hud.labelText = text;
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
}

- (void)showConfirmHudWithText:(NSString *)text {
    [self.view.window addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeCustomView;
	self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_hudicon.png"]] autorelease];
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
    [_hud release];
    _hud = nil;
}

@end
