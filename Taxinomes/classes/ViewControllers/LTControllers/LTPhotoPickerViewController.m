//
//  MediaManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 16/02/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//



#import "LTPhotoPickerViewController.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "Constants.h"
#import "MediaUploadFormViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation LTPhotoPickerViewController


- (void) dealloc {
    [_locationManager release];
    [_photoLocation release];
    [_photo release];
    [super dealloc];
}

#pragma mark View lifecycle

- (void)viewDidLoad {
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"Lat:%f Lon:%f Hacc:%f Vacc:%f",newLocation.coordinate.latitude ,newLocation.coordinate.longitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
    if (buttonIndex == 0) {
        MediaUploadFormViewController *mediaUploadFormViewController = [MediaUploadFormViewController new];
        mediaUploadFormViewController.gis = _photoLocation;
        mediaUploadFormViewController.media = _photo;
        [self.navigationController pushViewController:mediaUploadFormViewController animated:YES];
        [_photo release];
        [_photoLocation release];
        [mediaUploadFormViewController release];
    }
}

@end
