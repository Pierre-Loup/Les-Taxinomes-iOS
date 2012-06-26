//
//  AuthenticationSheetViewController.h
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

#import <UIKit/UIKit.h>
#import "LTViewController.h"
#import "LTConnectionManager.h"

@protocol AuthenticationSheetViewControllerDelegate <NSObject>
@optional
- (void)didAuthenticateWithAuthor:(Author *)author;
- (void)willDismissAuthenticationSheet;
- (void)didDismissAuthenticationSheet;
@end

@interface AuthenticationSheetViewController :LTViewController <LTConnectionManagerAuthDelegate> {
    id<AuthenticationSheetViewControllerDelegate> delegate_;
    
    UITextField * loginTextField_;
    UITextField * passwordTextField_;
    UIButton * signinButton_;
    UIButton * signupButton_;
    
    BOOL shouldDisplayCancelButton_;
}

@property (nonatomic, assign) id<AuthenticationSheetViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField * loginTextField;
@property (nonatomic, retain) IBOutlet UITextField * passwordTextField;
@property (nonatomic, retain) IBOutlet UIButton * signinButton;
@property (nonatomic, retain) IBOutlet UIButton * signupButton;
@property (nonatomic, assign) BOOL shouldDisplayCancelButton;

- (IBAction)dismissAuthenticationSheet:(id)sender;
- (IBAction)submitAuthentication:(id)sender;

@end
