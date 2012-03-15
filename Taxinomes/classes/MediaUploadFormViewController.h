//
//  MediaUploadFormViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 30/01/12.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import "LTPhotoPickerViewController.h"

@interface MediaUploadFormViewController : LTPhotoPickerViewController <UITextFieldDelegate, UITextViewDelegate> {
    
    NSArray* titleForSectionHeader_;
    NSArray* rowsInSection_;
    NSDictionary* cellForIndexPath_;
    NSDictionary* indexPathForInputView_;
    CLLocation* gis_;
    UIImage* media_;
    
    UITableView* tableView_;
    UIImageView* mediaSnapshotView_;
    //Cells
    UITableViewCell* titleCell_;
    UITableViewCell* textCell_;
    UITableViewCell* licenseCell_;
    UITableViewCell* latitudeCell_;
    UITableViewCell* longitudeCell_;
    UITableViewCell* publishCell_;
    
    UITextField* titleInput_;
    UITextView* textInput_;
    UIButton* licenseTypeChooser_;
    UITextField* latitudeInput_;
    UITextField* longitudeInput_;
    UISwitch* publishSwitch_;
    UIButton* shareButton_;
    
}

@property (retain, nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIImageView* mediaSnapshotView;
@property (nonatomic, retain) IBOutlet UIImage* media;
@property (nonatomic, retain) IBOutlet UITableViewCell* titleCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* textCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* licenseCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* latitudeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* longitudeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* publishCell;
@property (nonatomic, retain) IBOutlet UITextField* titleInput;
@property (nonatomic, retain) IBOutlet UITextView* textInput;
@property (nonatomic, retain) IBOutlet UIButton* licenseTypeChooser;
@property (nonatomic, retain) IBOutlet UITextField* latitudeInput;
@property (nonatomic, retain) IBOutlet UITextField* longitudeInput;
@property (nonatomic, retain) IBOutlet UISwitch* publishSwitch;
@property (nonatomic, retain) IBOutlet UIButton* shareButton;

@property (nonatomic, retain) CLLocation* gis;

- (IBAction)uploadMedia:(id)sender;

@end
