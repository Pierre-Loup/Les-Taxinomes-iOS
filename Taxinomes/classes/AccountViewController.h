//
//  AccountViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <UIKit/UIKit.h>
#import "LTConnectionManager.h"
#import "LTPhotoPickerViewController.h"
#import "Author.h"

@interface AccountViewController : LTPhotoPickerViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LTConnectionManagerDelegate> {
    UITableView *_tableView;
    UIImageView *_avatarView;
    UILabel *_nameLabel;
    UIView *_signinSubview;
    UIView *_loadingSubview;
    UITextField *_userTextField;
    UITextField *_passwordTextField;  
    NSArray *_accountMenuLabels;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIView *signinSubview;
@property (retain, nonatomic) IBOutlet UIView *loadingSubview;
@property (retain, nonatomic) IBOutlet UITextField *userTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField; 
@property (retain, nonatomic) NSArray *accountMenuLabels;


- (IBAction)forgotenPasswordButtonAction:(id)sender;
- (IBAction)submitSigninButtonAction:(id)sender;
- (IBAction)signupButtonAction:(id)sender;
- (IBAction)presentSigninSubview:(id)sender;
- (IBAction)dismissSigninSubview:(id)sender;
- (IBAction)presentLoadingSubview:(id)sender;
- (IBAction)dismissLoadingSubview:(id)sender;
- (IBAction)dismissKeyboardSubview:(id)sender;

- (void) setLoadingSubviewHidden:(BOOL)hidden animated:(BOOL)animated;
- (void) setSigninSubviewHidden:(BOOL)hidden animated:(BOOL)animated;
- (void) setViewComponentsHidden:(BOOL)hidden;

@end
