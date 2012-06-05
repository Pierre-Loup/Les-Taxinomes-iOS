//
//  HomeViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
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

#import "HomeViewController.h"
#import "LegalInformationsViewController.h"
#import "MediaUploadFormViewController.h"


@implementation HomeViewController
@synthesize welcomLabel = welcomLabel_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //welcomLabel_ = [[UILabel alloc] initWithFrame:self.view.frame];
    [welcomLabel_ setNumberOfLines:0];
    [welcomLabel_ setLineBreakMode:UILineBreakModeTailTruncation];
    [welcomLabel_ setContentMode:UIViewContentModeCenter];
    [welcomLabel_ setTextAlignment:UITextAlignmentCenter];
    [welcomLabel_ setFont:[UIFont fontWithName:@"Jesaya Free" size:17.0]];
    welcomLabel_.text = TRANSLATE(@"home.welcom_text");
    //[self.view addSubview:welcomLabel_];
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    [leftButton release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[welcomLabel_ setFont:[UIFont fontWithName:@"jesaya_free" size:17.0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [welcomLabel_ release];
    welcomLabel_ = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)infoButtonAction:(id) sender {
    LegalInformationsViewController *legalInformationsViewController = [[LegalInformationsViewController alloc] initWithNibName:@"LegalInformationsViewController" bundle:nil];
    [self.navigationController pushViewController:legalInformationsViewController animated:YES];    
    [legalInformationsViewController release];
}

@end
