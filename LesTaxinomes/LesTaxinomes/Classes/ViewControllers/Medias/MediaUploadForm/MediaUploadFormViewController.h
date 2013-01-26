//
//  MediaUploadFormViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 30/01/12.
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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "License.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import "LTTableViewController.h"
#import "AuthenticationSheetViewController.h"
#import "MediaLicenseChooserViewController.h"
#import "MediaLocalisationPickerViewController.h"
#import "UIGlossyButton.h"

@interface MediaUploadFormViewController : LTTableViewController
- (id)initWithAssetURL:(NSURL*)assetURL;
@end
