//
//  LTCollectionViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "PSTCollectionViewController.h"
#import "MBProgressHUD.h"

@interface LTCollectionViewController : PSTCollectionViewController <MBProgressHUDDelegate>
@property (nonatomic, readonly) MBProgressHUD* hud;

- (void)showDefaultHud;
- (void)showDeterminateHud;
- (void)showErrorHudWithText:(NSString *)text;
- (void)showConfirmHudWithText:(NSString *)text;
- (void)showHudWithTextOnly:(NSString *)text;

@end
