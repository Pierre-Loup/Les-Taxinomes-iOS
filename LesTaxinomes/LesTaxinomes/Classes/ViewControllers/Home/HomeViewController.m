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

#import "AuthenticationSheetViewController.h"
#import "LegalInformationsViewController.h"
#import "MediaUploadFormViewController.h"
#import "UIActionSheet+PhotoAssetPickerAddition.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface HomeViewController () <LTAuthenticationSheetDelegate>
@property (nonatomic, retain) IBOutlet UILabel* welcomLabel;
@property (nonatomic, retain) NSURL* mediaToShareAssetURL;
@property (nonatomic, assign) BOOL shouldPresentAuthenticationSheet;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - View implementation

@implementation HomeViewController
;
////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _shouldPresentAuthenticationSheet = NO;
    }
    return self;
}

- (void)dealloc {
    [_welcomLabel release];
    [super dealloc];
}

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if(self.shouldPresentAuthenticationSheet) {
        self.shouldPresentAuthenticationSheet = NO;
        [self displayAuthenticationSheetAnimated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.welcomLabel = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)displayAuthenticationSheetAnimated:(BOOL)animated {
    AuthenticationSheetViewController * authenticationSheetViewController =
    [[AuthenticationSheetViewController alloc] initWithNibName:@"AuthenticationSheetViewController"
                                                        bundle:nil];
    authenticationSheetViewController.delegate = self;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationSheetViewController];
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:animated];
    [authenticationSheetViewController release];
    [navigationController release];
}

#pragma mark Actions

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
                                  LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
                                  if (!cm.authenticatedUser) {
                                      [self showDefaultHud];
                                      [cm authWithLogin:nil
                                               password:nil
                                          responseBlock:^(Author *authenticatedUser, NSError *error) {
                                              [self.hud hide:YES];
                                              if (!authenticatedUser) {
                                                  self.mediaToShareAssetURL = chosenImageAssetURL;
                                                  if(self.presentedViewController) {
                                                      self.shouldPresentAuthenticationSheet = YES;
                                                  } else {
                                                      [self displayAuthenticationSheetAnimated:YES];
                                                  }
                                              } else {
                                                  [self dismissModalViewControllerAnimated:YES];
                                                  MediaUploadFormViewController* mediaUploadVC = [[MediaUploadFormViewController alloc] initWithAssetURL:chosenImageAssetURL];
                                                  [self.navigationController pushViewController:mediaUploadVC animated:YES];
                                                  [mediaUploadVC release];
                                              }
                                        }];
                                  } else {
                                      [self dismissModalViewControllerAnimated:YES];
                                      MediaUploadFormViewController* mediaUploadVC = [[MediaUploadFormViewController alloc] initWithAssetURL:chosenImageAssetURL];
                                      [self.navigationController pushViewController:mediaUploadVC animated:YES];
                                      [mediaUploadVC release];
                                  }
                              }
                          } onCancel:^{}];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTAuthenticationSheetDelegate

- (void)authenticationDidFinishWithSuccess:(BOOL)success {
    Author* authenticatedUser = [LTConnectionManager sharedConnectionManager].authenticatedUser;
    if (success && authenticatedUser) {
        [self dismissModalViewControllerAnimated:YES];
        MediaUploadFormViewController* mediaUploadVC = [[MediaUploadFormViewController alloc] initWithAssetURL:self.mediaToShareAssetURL];
        self.mediaToShareAssetURL = nil;
        [self.navigationController pushViewController:mediaUploadVC animated:YES];
        [mediaUploadVC release];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

@end
