//
//  AuthenticationSheetViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "AuthenticationSheetViewController.h"

@interface AuthenticationSheetViewController ()

@end

@implementation AuthenticationSheetViewController
@synthesize delegate = delegate_;
@synthesize loginTextField = loginTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize signinButton = signinButton_;
@synthesize shouldDisplayCancelButton = shouldDisplayCancelButton_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        shouldDisplayCancelButton_ = YES;
    }
    return self;
}

- (void)dealloc {
    connectionManager_.authDelegate = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Connexion";
    if (shouldDisplayCancelButton_) {
        UIBarButtonItem * cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common_cancel") style:UIBarButtonSystemItemCancel target:self action:@selector(dismissAuthenticationSheet:)];
        [self.navigationItem setRightBarButtonItem:cancelBarButton];
        [cancelBarButton release];
    }

    signinButton_.tintColor = kLightGreenColor;
    signinButton_.buttonCornerRadius = 10.0;
    [signinButton_ setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
                                                                                                                                                                
#pragma mark Actions
                                                                                                                                                                
- (IBAction)dismissAuthenticationSheet:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    if ([delegate_ respondsToSelector:@selector(didDismissAuthenticationSheet)]) {
        [delegate_ didDismissAuthenticationSheet];
    }
    
}

- (IBAction)submitAuthentication:(id)sender {
    [self displayLoader];
    connectionManager_ = [LTConnectionManager sharedConnectionManager];
    connectionManager_.authDelegate = self;
#if DEBUG
    [connectionManager_ authWithLogin:@"pierre" password:@"crLu2Vzi" delegate:self];
#else
    [connectionManager_ authWithLogin:self.loginTextField.text password:self.passwordTextField.text delegate:self];
#endif
}

- (IBAction)forgottenPasswordButtonTouched:(id)sender {
    NSURL* forgottenPasswordURL = [NSURL URLWithString:kForgottenPasswordURL];
    [[UIApplication sharedApplication] openURL:forgottenPasswordURL];
}

- (IBAction)signupButtonTouched:(id)sender {
    NSURL* signupURL = [NSURL URLWithString:kSignupURL];
    [[UIApplication sharedApplication] openURL:signupURL];
}

#pragma mark - LTConnectionManagerDelegate

- (void)didAuthenticateWithAuthor:(Author *)author {
    [self hideLoader];
    if ([delegate_ respondsToSelector:@selector(didAuthenticateWithAuthor:)]) {
        [delegate_ didAuthenticateWithAuthor:author];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didFailToAuthenticateWithError:(NSError *)error {
    [self hideLoader];
    UIAlertView *authFailedAlert = nil;
    if ([error.domain isEqualToString:kNetworkRequestErrorDomain]) {
        authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    } else if ([error.domain isEqualToString:kLTAuthenticationFailedError]) {
        authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_auth_failed_title") message:TRANSLATE(@"alert_auth_failed_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    }
    
    [authFailedAlert show];
    [authFailedAlert release];
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
