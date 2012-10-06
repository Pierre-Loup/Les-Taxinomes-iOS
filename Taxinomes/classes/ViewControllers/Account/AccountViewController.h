//
//  AccountViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
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
#import "LTConnectionManager.h"
#import "AuthenticationSheetViewController.h"
#import "LTPhotoPickerViewController.h"
#import "Author.h"
#import "TCImageView.h"

@interface AccountViewController : LTPhotoPickerViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LTConnectionManagerAuthDelegate> {
    
    NSArray* accountMenuLabels_;
    Author * authenticatedUser_;
    
    UIBarButtonItem* rightBarButton_;
    TCImageView* avatarView_;
}

@end
