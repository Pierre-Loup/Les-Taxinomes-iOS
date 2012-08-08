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


@interface LTPhotoPickerViewController ()
- (void)presentAuthenticationSheetAnimated;
- (void)pushMediaUploadFormVCAnnimated:(BOOL)animated;
@end

@implementation LTPhotoPickerViewController


- (void) dealloc {
    [_locationManager release];
    [_photoLocation release];
    [_photo release];
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
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    
}

- (void)pushMediaUploadFormVCAnnimated:(BOOL)animated {
    MediaUploadFormViewController *mediaUploadFormViewController = [MediaUploadFormViewController new];
    mediaUploadFormViewController.gis = _photoLocation;
    mediaUploadFormViewController.mediaImage = _photo;
    [self.navigationController pushViewController:mediaUploadFormViewController animated:animated];
    [_photo release];
    [_photoLocation release];
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
        if(_locationManager.location != nil){
            [metadata setLocation:_locationManager.location];
            _photoLocation = [_locationManager.location retain];
        }
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        _photo = [(UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage] retain];
        [assetsLibrary writeImageToSavedPhotosAlbum:_photo.CGImage metadata:metadata completionBlock:nil];
        [assetsLibrary release];
    }
    [_locationManager stopUpdatingLocation];
     
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Terminer" destructiveButtonTitle:@"Partager la photo" otherButtonTitles: nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

<<<<<<< HEAD
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //LogDebug(@"Lat:%f Lon:%f Hacc:%f Vacc:%f",newLocation.coordinate.latitude ,newLocation.coordinate.longitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
}

=======
>>>>>>> 4233cdd6da6e0b88eeb4e1e515a043bed919dbf7
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
    if (buttonIndex == 0) {
        
        LTConnectionManager * cm = [LTConnectionManager sharedConnectionManager];
        if (!cm.authenticatedUser) {
            [cm checkUserAuthStatusWithDelegate:self];
            [self displayLoader];
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
            authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
        } else if ([error.domain isEqualToString:kLTAuthenticationFailedError]) {
            authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_auth_failed_title") message:TRANSLATE(@"alert_auth_failed_text") delegate:self cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
        }
        
        
        [authFailedAlert show];
        [authFailedAlert release];
    } else {
        [self performSelector:@selector(presentAuthenticationSheetAnimated)
                   withObject:self afterDelay:0.5];
    }
}

@end
