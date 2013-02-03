//
//  MediaLicenseChooserViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 27/05/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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
#import "License.h"
#import "LTTableViewController.h"

@protocol MediaLicenseChooserDelegate <NSObject>

- (void)didChooseLicense:(License *)license;

@end

@interface MediaLicenseChooserViewController : LTTableViewController {
    NSArray * licenses_;
    NSIndexPath * currentLicenseIndexPath_;
    UIBarButtonItem * rightBarButton_;
    
}

@property (nonatomic, unsafe_unretained) id<MediaLicenseChooserDelegate> delegate;
@property (nonatomic, strong) License * currentLicense;

@end
