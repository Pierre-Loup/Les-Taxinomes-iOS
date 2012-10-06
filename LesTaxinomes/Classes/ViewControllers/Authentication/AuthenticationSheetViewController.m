//
//  AuthenticationSheetViewController.m
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

#import "AuthenticationSheetViewController.h"

#import "LTErrorManager.h"

@interface AuthenticationSheetViewController ()

@property (nonatomic, retain) IBOutlet UITextField* loginTextField;
@property (nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property (nonatomic, retain) IBOutlet UIGlossyButton* signinButton;

@end

@implementation AuthenticationSheetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [_loginTextField release];
    [_passwordTextField release];
    [_signinButton release];
    [super dealloc];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = TRANSLATE(@"common.signin");
        UIBarButtonItem * cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common.cancel") style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched:)];
        [self.navigationItem setRightBarButtonItem:cancelBarButton];
        [cancelBarButton release];

    self.signinButton.tintColor = kLightGreenColor;
    self.signinButton.buttonCornerRadius = 10.0;
    [self.signinButton setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    self.loginTextField = nil;
    self.passwordTextField = nil;
    self.signinButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
                                                                                                                                                                
#pragma mark Actions                                                                                                                                                            

- (IBAction)submitAuthentication:(id)sender {
    
    [self startLoadingAnimation];
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
        [cm authWithLogin:self.loginTextField.text
                 password:self.passwordTextField.text
            responseBlock:^(NSString *login, NSString *password, Author *authenticatedUser, NSError *error) {
                [self stopLoadingAnimation];
                if (authenticatedUser && !error) {
                    [self.delegate authenticationDidFinishWithSuccess:YES];
                } else {
                    [[LTErrorManager sharedErrorManager] manageError:error];
                }
            }];
}

- (IBAction)forgottenPasswordButtonTouched:(UIButton *)button {
    NSURL* forgottenPasswordURL = [NSURL URLWithString:kForgottenPasswordURL];
    [[UIApplication sharedApplication] openURL:forgottenPasswordURL];
}

- (IBAction)signupButtonTouched:(UIButton *)button {
    NSURL* signupURL = [NSURL URLWithString:kSignupURL];
    [[UIApplication sharedApplication] openURL:signupURL];
}

- (IBAction)cancelButtonTouched:(UIBarButtonItem *)barButton {
    [self.delegate authenticationDidFinishWithSuccess:NO];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.loginTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
    }
    return YES;
}

@end
