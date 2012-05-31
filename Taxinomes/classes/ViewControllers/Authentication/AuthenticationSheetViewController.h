//
//  AuthentiationSheetViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AuthentiationSheetViewControllerDelegate <NSObject>

- (void)didAuthenticate;
- (void)didFailToAuthenticateWithError:(NSError *)error;

@end

@interface AuthentiationSheetViewController : UIViewController {
    UITextField * loginTextField_;
    UITextField * passwordTextField_;
    UIButton * signinButton_;
    UIButton * signupButton_;
}

@property (nonatomic, retain) IBOutlet UITextField * loginTextField;
@property (nonatomic, retain) IBOutlet UITextField * passwordTextField;
@property (nonatomic, retain) IBOutlet UIButton * signinButton;
@property (nonatomic, retain) IBOutlet UIButton * signupButton;

@end
