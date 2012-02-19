//
//  MediaManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 16/02/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MediaManager.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "Constants.h"
#import <AssetsLibrary/AssetsLibrary.h>

static MediaManager *instance = nil;

@implementation MediaManager
@synthesize locationManager = _locationManager;
@synthesize delegate;

+ (MediaManager *)sharedMediaManager {
	if(instance == nil) {
		instance = [[MediaManager alloc] init];
	}	
	return instance;
}

- (void) dealloc {
    self.locationManager = nil;
}

- (void)takePicture {
    
    if([CLLocationManager locationServicesEnabled]){
        NSLog(@"locationServicesEnabled");
        // Create the location manager
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        /*
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        // Set a movement threshold for new events.
        self.locationManager.distanceFilter = 500;
        */
        [self.locationManager startUpdatingLocation];
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        if(self.locationManager.location != nil){
            [metadata setLocation:self.locationManager.location];
        }
        NSLog(@"%@",metadata);
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        UIImage *photo = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        [assetsLibrary writeImageToSavedPhotosAlbum:photo.CGImage metadata:metadata completionBlock:nil];
        [assetsLibrary release];
    }
    [self.locationManager stopUpdatingLocation];
    
    
    /*
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    __block BOOL taxinomeGroup = NO;
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if( [group valueForProperty:ALAssetsGroupPropertyName] == kPhotoGroupName){
            taxinomeGroup = YES;
        }
        
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
     */
    
    
    
     
    [delegate didFinishTakingPicture];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [delegate didFinishTakingPicture];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Lat:%f Lon:%f Hacc:%f Vacc:%f",newLocation.coordinate.latitude ,newLocation.coordinate.longitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
}

@end
