//
//  MediaLicenseChooserViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/05/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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
#import "License.h"
#import "LTViewController.h"

@protocol MediaLicenseChooserDelegate <NSObject>

- (void)didChooseLicense:(License *)license;

@end

@interface MediaLicenseChooserViewController : LTViewController <UITableViewDataSource, UITableViewDelegate> {
    
    id<MediaLicenseChooserDelegate> delegate_;
    
    UITableView * tableView_;
    NSMutableArray * licenses_;
    License * currentLicense_;
    NSIndexPath * currentLicenseIndexPath_;
    
    UIBarButtonItem * rightBarButton_;
    
}

@property (nonatomic, assign) id<MediaLicenseChooserDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSMutableArray * licenses;
@property (nonatomic, retain) License * currentLicense;

@end
