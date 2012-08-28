//
//  MediaManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 16/02/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//



#import "LTPhotoPickerViewController.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "Constants.h"
#import "MediaUploadFormViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface LTPhotoPickerViewController () <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, LTConnectionManagerAuthDelegate> {
    CLLocationManager* locationManager_;
    CLLocation* photoLocation_;
    UIImage* photo_;
}
- (void)presentAuthenticationSheetAnimated;
- (void)pushMediaUploadFormVCAnnimated:(BOOL)animated;
@end

@implementation LTPhotoPickerViewController


- (void) dealloc {
    [locationManager_ release];
    [photoLocation_ release];
    [photo_ release];
    [super dealloc];
}

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIBarButtonItem* cameraBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonAction:)];
        [self.navigationItem setRightBarButtonItem:cameraBarButton animated:YES];
        [cameraBarButton release];
    }
}

#pragma mark - Actions

- (void)cameraButtonAction:(UIBarButtonItem*)cameraBarButton {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [[[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil] autorelease];
    imagePicker.allowsEditing = NO;
    
    [self presentModalViewController:imagePicker animated:YES];
    if([CLLocationManager locationServicesEnabled]){
        // Create the location manager
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
        [locationManager_ startUpdatingLocation];
    }
    [imagePicker release];
    
}

- (void)pushMediaUploadFormVCAnnimated:(BOOL)animated {
    MediaUploadFormViewController *mediaUploadFormViewController = [MediaUploadFormViewController new];
    mediaUploadFormViewController.gis = photoLocation_;
    mediaUploadFormViewController.mediaImage = photo_;
    [self.navigationController pushViewController:mediaUploadFormViewController animated:animated];
    [mediaUploadFormViewController release];
}

- (void)presentAuthenticationSheetAnimated {
    AuthenticationSheetViewController * authenticationSheetViewController = [[AuthenticationSheetViewController alloc] initWithNibName:@"AuthenticationSheetViewController" bundle:nil];
    authenticationSheetViewController.authDelegate = self;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationSheetViewController];
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    [authenticationSheetViewController release];
    [navigationController release];
}

#pragma mark - UIImagePikerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        if(locationManager_.location != nil){
            [metadata setLocation:locationManager_.location];
            photoLocation_ = [locationManager_.location retain];
        }
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [photo_ release];
        photo_ = [(UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage] retain];
        [assetsLibrary writeImageToSavedPhotosAlbum:photo_.CGImage metadata:metadata completionBlock:nil];
        [assetsLibrary release];
    }
    [locationManager_ stopUpdatingLocation];
     
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:TRANSLATE(@"common.finish") destructiveButtonTitle:TRANSLATE(@"common.share") otherButtonTitles: nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
    if (buttonIndex == 0) {
        
        LTConnectionManager * cm = [LTConnectionManager sharedConnectionManager];
        if (!cm.authenticatedUser) {
            [cm checkUserAuthStatusWithDelegate:self];
        } else {
            [self pushMediaUploadFormVCAnnimated:NO];
        }
    }
}

#pragma mark - LTConnectionManagerAuthDelegate

- (void)authDidEndWithLogin:(NSString *)login
                   password:(NSString *)password
                     author:(Author *)author
                      error:(NSError *)error {
    
    [self hideLoader];
    if ([self.modalViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)self.modalViewController;
        if ([navigationController.topViewController isKindOfClass:[AuthenticationSheetViewController class]]) {
            [(AuthenticationSheetViewController *)navigationController.topViewController hideLoader];
        }
    }
    
    if (author) {
        [self dismissModalViewControllerAnimated:YES];
        [self pushMediaUploadFormVCAnnimated:YES];
    } else if (error && login && password) {
        UIAlertView *authFailedAlert = nil;
        if ([error.domain isEqualToString:kNetworkRequestErrorDomain]) {
            authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
        } else if ([error.domain isEqualToString:kLTAuthenticationFailedError]) {
            authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_auth_failed_title") message:TRANSLATE(@"alert_auth_failed_text") delegate:self cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
        }
        
        
        [authFailedAlert show];
        [authFailedAlert release];
    } else {
        [self performSelector:@selector(presentAuthenticationSheetAnimated)
                   withObject:self afterDelay:0.5];
    }
}

@end
