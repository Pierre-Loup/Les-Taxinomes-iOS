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

@interface AuthenticationSheetViewController ()

@property (nonatomic, retain) IBOutlet UITextField* loginTextField;
@property (nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property (nonatomic, retain) IBOutlet UIGlossyButton* signinButton;

- (IBAction)dismissAuthenticationSheet:(id)sender;
- (IBAction)submitAuthentication:(id)sender;
- (IBAction)forgottenPasswordButtonTouched:(id)sender;
- (IBAction)signupButtonTouched:(id)sender;
@end

@implementation AuthenticationSheetViewController
@synthesize authDelegate = authDelegate_;
@synthesize loginTextField = loginTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize signinButton = signinButton_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [loginTextField_ release];
    [passwordTextField_ release];
    [signinButton_ release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TRANSLATE(@"common.signin");
        UIBarButtonItem * cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common.cancel") style:UIBarButtonSystemItemCancel target:self action:@selector(dismissAuthenticationSheet:)];
        [self.navigationItem setRightBarButtonItem:cancelBarButton];
        [cancelBarButton release];

    signinButton_.tintColor = kLightGreenColor;
    signinButton_.buttonCornerRadius = 10.0;
    [signinButton_ setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.loginTextField = nil;
    self.passwordTextField = nil;
    self.signinButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
                                                                                                                                                                
#pragma mark Actions                                                                                                                                                            

- (IBAction)submitAuthentication:(id)sender {
    
    if (authDelegate_) {
        [self displayLoader];
        [[LTConnectionManager sharedConnectionManager] authWithLogin:self.loginTextField.text
                                 password:self.passwordTextField.text
                                 delegate:authDelegate_];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)forgottenPasswordButtonTouched:(id)sender {
    NSURL* forgottenPasswordURL = [NSURL URLWithString:kForgottenPasswordURL];
    [[UIApplication sharedApplication] openURL:forgottenPasswordURL];
}

- (IBAction)signupButtonTouched:(id)sender {
    NSURL* signupURL = [NSURL URLWithString:kSignupURL];
    [[UIApplication sharedApplication] openURL:signupURL];
}

- (IBAction)dismissAuthenticationSheet:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == loginTextField_) {
        [passwordTextField_ becomeFirstResponder];
    } else if (textField == passwordTextField_) {
        [passwordTextField_ resignFirstResponder];
    }
    return YES;
}

@end
