//
//  LTAuthenticationSheetViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 27/04/12.
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

#import "LTAuthenticationSheetViewController.h"

@interface LTAuthenticationSheetViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem* cancelBarButton;
@property (nonatomic, strong) IBOutlet UILabel* loginLabel;
@property (nonatomic, strong) IBOutlet UITextField* loginTextField;
@property (nonatomic, strong) IBOutlet UILabel* passwordLabel;
@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;
@property (nonatomic, strong) IBOutlet UIButton* signupButton;
@property (nonatomic, strong) IBOutlet UITextField* passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton* signinButton;

@end

@implementation LTAuthenticationSheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _T(@"authentication.title");
    [self.cancelBarButton setTitle:_T(@"common.cancel")];
    
    self.loginLabel.text = _T(@"authentication.login_label.text");
    self.passwordLabel.text = _T(@"authentication.password_label.text");

    
    if (!IOS7_OR_GREATER)
    {
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        UIButton* signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        signinButton.frame = self.signinButton.frame;
        signinButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        signinButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [signinButton addTarget:self
                         action:@selector(submitAuthentication:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self.signinButton.superview addSubview:signinButton];
        [self.signinButton removeFromSuperview];
        self.signinButton = signinButton;
        [self.signinButton setTitleColor:[UIColor mainColor]
                                forState:UIControlStateNormal];
        [self.signinButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateHighlighted];
        
        UIButton* signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        signupButton.frame = self.signupButton.frame;
        signupButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        signupButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [signupButton addTarget:self
                         action:@selector(signupButtonTouched:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self.signupButton.superview addSubview:signupButton];
        [self.signupButton removeFromSuperview];
        self.signupButton = signupButton;
        [self.signupButton setTitleColor:[UIColor mainColor]
                                forState:UIControlStateNormal];
        [self.signupButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateHighlighted];
        
        
        UIButton* passwordForgottenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        passwordForgottenButton.frame = self.passwordForgottenButton.frame;
        passwordForgottenButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        passwordForgottenButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [passwordForgottenButton addTarget:self
                                    action:@selector(forgottenPasswordButtonTouched:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [self.passwordForgottenButton.superview addSubview:passwordForgottenButton];
        [self.passwordForgottenButton removeFromSuperview];
        self.passwordForgottenButton = passwordForgottenButton;
        [self.passwordForgottenButton setTitleColor:[UIColor mainColor]
                                           forState:UIControlStateNormal];
        [self.passwordForgottenButton setTitleColor:[UIColor whiteColor]
                                           forState:UIControlStateHighlighted];

    }
    
    
    [self.passwordForgottenButton setTitle:_T(@"authentication.forgotten_password_button.text")
                                  forState:UIControlStateNormal];
    [self.signupButton setTitle:_T(@"authentication.signup_button.text")
                       forState:UIControlStateNormal];
    [self.signinButton setTitle:_T(@"common.submit")
                       forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.loginTextField = nil;
    self.passwordTextField = nil;
    self.signinButton = nil;
}
                                                                                                                                                                
#pragma mark Actions                                                                                                                                                            

- (IBAction)submitAuthentication:(id)sender
{
    [SVProgressHUD show];
    LTConnectionManager* cm = [LTConnectionManager sharedManager];
        [cm authWithLogin:self.loginTextField.text
                 password:self.passwordTextField.text
            responseBlock:^(LTAuthor *authenticatedUser, NSError *error) {
                [SVProgressHUD dismiss];
                if (authenticatedUser && !error) {
                    [self.delegate authenticationDidFinishWithSuccess:YES];
                    [SVProgressHUD showSuccessWithStatus:nil];
                } else {
                    [SVProgressHUD showErrorWithStatus:nil];
                }
            }];
}

- (IBAction)forgottenPasswordButtonTouched:(UIButton *)button
{
    NSURL* forgottenPasswordURL = [NSURL URLWithString:LTForgottenPasswordURL];
    [[UIApplication sharedApplication] openURL:forgottenPasswordURL];
}

- (IBAction)signupButtonTouched:(UIButton *)button
{
    NSURL* signupURL = [NSURL URLWithString:LTSignupURL];
    [[UIApplication sharedApplication] openURL:signupURL];
}

- (IBAction)cancelButtonTouched:(UIBarButtonItem *)barButton
{
    [self.delegate authenticationDidFinishWithSuccess:NO];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.loginTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self submitAuthentication:textField];
    }
    return YES;
}

@end
