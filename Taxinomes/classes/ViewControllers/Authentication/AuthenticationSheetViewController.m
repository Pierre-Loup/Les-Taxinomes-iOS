//
//  AuthentiationSheetViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "AuthentiationSheetViewController.h"

@interface AuthentiationSheetViewController ()

@end

@implementation AuthentiationSheetViewController
@synthesize loginTextField = loginTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize signinButton = signinButton_;
@synthesize signupButton = signupButton_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
