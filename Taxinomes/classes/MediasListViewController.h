//
//  MediasListViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 07/11/11.
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
#import "LTDataManager.h"

typedef enum {
    FAILED = 0,
    PENDING,
    SUCCEED
} MediaLoadingStatus;

@interface MediasListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView_;
    NSMutableDictionary *mediaForIndexPath;
    UITableViewCell *spinnerCell;
    MediaLoadingStatus mediaLoadingStatus;
    //BOOL isLoadingNewMedias;
    UIView *loadingTopVew;
    UITableViewCell* _mediaTableViewCell;
    UITableViewCell* _retryCell;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) NSMutableDictionary *mediaForIndexPath;
@property (nonatomic, retain) IBOutlet UITableViewCell *spinnerCell;
@property (nonatomic, retain) UIView *loadingTopVew;
@property (nonatomic, retain) IBOutlet UITableViewCell* mediaTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* retryCell;

- (void) getNextmedias;
- (IBAction)reloadButtonAction:(id)sender;

@end

