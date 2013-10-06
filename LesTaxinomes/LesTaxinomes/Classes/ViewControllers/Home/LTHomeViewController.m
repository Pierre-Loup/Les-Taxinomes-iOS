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

#import "LTHomeViewController.h"

#import "LTAuthenticationSheetViewController.h"
#import "LTLegalNoticeViewController.h"
#import "LTMediaUploadFormViewController.h"
#import "LTPhotoAssetManager.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTHomeViewController () <LTAuthenticationSheetDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *infoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cameraBarButton;
@property (nonatomic, strong) IBOutlet UILabel* welcomLabel;

@property (nonatomic, strong) NSURL* mediaToShareAssetURL;
@property (nonatomic, assign) BOOL shouldPresentAuthenticationSheet;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - View implementation

@implementation LTHomeViewController
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.welcomLabel setNumberOfLines:0];
    [self.welcomLabel setLineBreakMode:UILineBreakModeTailTruncation];
    [self.welcomLabel setContentMode:UIViewContentModeCenter];
    [self.welcomLabel setTextAlignment:UITextAlignmentCenter];
    [self.welcomLabel setFont:[UIFont fontWithName:@"Jesaya Free" size:17.0]];
    self.welcomLabel.text = _T(@"home.welcom_text");
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:self.infoButton animated:YES];
    
    [self.navigationItem setRightBarButtonItem:self.cameraBarButton animated:YES];
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

- (void)displayAuthenticationSheetAnimated:(BOOL)animated
{
    UINavigationController* authenticationSheetNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthenticationSheet"];
    LTAuthenticationSheetViewController* authenticationSheetViewController = (LTAuthenticationSheetViewController*)authenticationSheetNavigationController.viewControllers[0];
    authenticationSheetViewController.delegate = self;
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:authenticationSheetNavigationController
                       animated:animated
                     completion:^{}];
}

#pragma mark Actions

- (IBAction)infoButtonAction:(id) sender
{
    LTLegalNoticeViewController *legalInformationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LTLegalNoticeViewController"];
    [self.navigationController pushViewController:legalInformationsViewController animated:YES];
}

- (IBAction)cameraButtonAction:(id) sender
{
    [[LTPhotoAssetManager sharedManager] photoAssetPickerWithTitle:nil
                                                        showInView:self.view.window
                                                         presentVC:self
    onPhotoPicked:^(NSURL* chosenImageAssetURL, NSError* error) {
        if (chosenImageAssetURL && !error) {
            LTConnectionManager* cm = [LTConnectionManager sharedManager];
            if (!cm.authenticatedUser) {
                [SVProgressHUD show];
                [cm authWithLogin:nil
                         password:nil
                    responseBlock:^(LTAuthor *authenticatedUser, NSError *error) {
                        [SVProgressHUD dismiss];
                        if (!authenticatedUser) {
                            self.mediaToShareAssetURL = chosenImageAssetURL;
                            if(self.presentedViewController) {
                                self.shouldPresentAuthenticationSheet = YES;
                            } else {
                                [self displayAuthenticationSheetAnimated:YES];
                            }
                        } else {
                            [self dismissViewControllerAnimated:YES
                                                     completion:^{}];
                            LTMediaUploadFormViewController* mediaUploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LTMediaUploadFormViewController"];
                            mediaUploadVC.mediaAssetURL = chosenImageAssetURL;
                            [self.navigationController pushViewController:mediaUploadVC animated:YES];
                        }
                    }];
            } else {
                [self dismissViewControllerAnimated:YES
                                         completion:^{}];
                LTMediaUploadFormViewController* mediaUploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LTMediaUploadFormViewController"];
                mediaUploadVC.mediaAssetURL = chosenImageAssetURL;
                [self.navigationController pushViewController:mediaUploadVC animated:YES];
            }
        }
    } onCancel:^{}];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTAuthenticationSheetDelegate

- (void)authenticationDidFinishWithSuccess:(BOOL)success {
    LTAuthor *authenticatedUser = [LTConnectionManager sharedManager].authenticatedUser;
    if (success && authenticatedUser) {
        [self dismissViewControllerAnimated:YES
                                 completion:^{}];
        LTMediaUploadFormViewController* mediaUploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LTMediaUploadFormViewController"];
        mediaUploadVC.mediaAssetURL = self.mediaToShareAssetURL;
        [self.navigationController pushViewController:mediaUploadVC animated:YES];
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:^{}];;
    }
}

@end
