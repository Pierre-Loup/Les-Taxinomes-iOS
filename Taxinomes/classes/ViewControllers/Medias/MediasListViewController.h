//
//  MediasListViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 07/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
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
#import "LTDataManager.h"
#import "LTViewController.h"
#import "TCImageView.h"

typedef enum {
    FAILED = 0,
    PENDING,
    SUCCEED,
    NOMORETOLOAD,
} MediaLoadingStatus;

@interface MediasListViewController : LTViewController <UITableViewDataSource, UITableViewDelegate, TCImageViewDelegate, LTConnectionManagerDelegate> {
    Author * currentUser_;
    
    LTDataManager * dataManager_;
    LTConnectionManager * connectionManger_;
    NSMutableDictionary * mediaForIndexPath_;
    MediaLoadingStatus mediaLoadingStatus_;
    
    // UI
    UIBarButtonItem * reloadBarButton_;
    UITableView *tableView_;
    UITableViewCell * spinnerCell_;
    UITableViewCell * mediaTableViewCell_;
    UITableViewCell * retryCell_;
}

@property (nonatomic, retain) Author * currentUser;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSMutableDictionary * mediaForIndexPath;
@property (nonatomic, retain) IBOutlet UITableViewCell * spinnerCell;
@property (nonatomic, retain) IBOutlet UITableViewCell * mediaTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell * retryCell;

- (IBAction)loadSynchMedias:(id)sender;
- (IBAction)refreshButtonAction:(id)sender;

@end

