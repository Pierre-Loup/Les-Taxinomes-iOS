//
//  HomeViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import "HomeViewController.h"
#import "LegalInformationsViewController.h"
#import "MediaUploadFormViewController.h"
#import "UIActionSheet+PhotoAssetPickerAddition.h"

@interface HomeViewController ()
@property (nonatomic, retain) IBOutlet UILabel* welcomLabel;
- (IBAction)infoButtonAction:(id) sender;
@end

@implementation HomeViewController

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

- (void)dealloc {
    [_welcomLabel release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.welcomLabel setNumberOfLines:0];
    [self.welcomLabel setLineBreakMode:UILineBreakModeTailTruncation];
    [self.welcomLabel setContentMode:UIViewContentModeCenter];
    [self.welcomLabel setTextAlignment:UITextAlignmentCenter];
    [self.welcomLabel setFont:[UIFont fontWithName:@"Jesaya Free" size:17.0]];
    self.welcomLabel.text = _T(@"home.welcom_text");
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    [leftButton release];
    
    UIBarButtonItem* cameraBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonAction:)];
    [self.navigationItem setRightBarButtonItem:cameraBarButton animated:YES];
    [cameraBarButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.welcomLabel = nil;
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

- (void)cameraButtonAction:(id) sender {
    [UIActionSheet photoAssetPickerWithTitle:nil
                             showInView:self.view.window
                              presentVC:self
                          onPhotoPicked:^(NSURL* chosenImageAssetURL, NSError* error) {
                              if (chosenImageAssetURL && !error) {
                                  MediaUploadFormViewController* mediaUploadVC = [[MediaUploadFormViewController alloc] initWithAssetURL:chosenImageAssetURL];
                                  [self.navigationController pushViewController:mediaUploadVC animated:YES];
                                  [mediaUploadVC release];
                              }
                          } onCancel:^{}];
}

@end
