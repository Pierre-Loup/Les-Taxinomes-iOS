//
//  MediaLocalisationPickerViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 16/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LTViewController.h"

@class MediaLocalisationPickerViewController;

@protocol MediaLocationPickerDelegate <NSObject>

- (void)mediaLocationPicker:(MediaLocalisationPickerViewController *)mediaLocationPicker didPickLocation:(CLLocation *)location;

@end

@interface MediaLocalisationPickerViewController : LTViewController

@property (nonatomic, unsafe_unretained) id<MediaLocationPickerDelegate> delegate;
@property (nonatomic, strong) CLLocation* location;

@end
