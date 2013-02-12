//
//  LTTableViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 31/07/12.
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

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "LTiPhoneBackgroundView.h"

@interface LTTableViewController : UITableViewController <MBProgressHUDDelegate>
@property (nonatomic, readonly) MBProgressHUD* hud;

- (void)showDefaultHud;
- (void)showDeterminateHud;
- (void)showErrorHudWithText:(NSString *)text;
- (void)showConfirmHudWithText:(NSString *)text;
- (void)showHudWithTextOnly:(NSString *)text;

@end