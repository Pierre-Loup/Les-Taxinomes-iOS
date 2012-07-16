//
//  MediaUploadFormViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 30/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "License.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import "LTConnectionManager.h"
#import "LTViewController.h"
#import "AuthenticationSheetViewController.h"
#import "MediaLicenseChooserViewController.h"
#import "MediaLocalisationPickerViewController.h"
#import "UIGlossyButton.h"

@interface MediaUploadFormViewController : LTViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, LTConnectionManagerDelegate, AuthenticationSheetViewControllerDelegate, MediaLicenseChooserDelegate, MediaLocationPickerDelegate> {
    CLGeocoder* reverseGeocoder_;
    
    NSArray* rowsInSection_;
    NSDictionary* cellForIndexPath_;
    NSDictionary* indexPathForInputView_;
    CLLocation* gis_;
    License* license_;
    
}

@property (retain, nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIImageView* mediaSnapshotView;
@property (nonatomic, retain) IBOutlet UIImage* mediaImage;
@property (nonatomic, retain) IBOutlet UITableViewCell* textCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* licenseCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* publishCell;
@property (nonatomic, retain) IBOutlet UITextField* titleInput;
@property (nonatomic, retain) IBOutlet UITextView* textInput;
@property (nonatomic, retain) IBOutlet UITextField* cityInput;
@property (nonatomic, retain) IBOutlet UITextField* zipcodeInput;
@property (nonatomic, retain) IBOutlet UITextField* countryInput;
@property (nonatomic, retain) IBOutlet UISwitch* publishSwitch;
@property (nonatomic, retain) IBOutlet UIGlossyButton* shareButton;

@property (nonatomic, retain) CLLocation* gis;

@end
