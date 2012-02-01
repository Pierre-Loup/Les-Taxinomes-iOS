//
//  MediasListViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 07/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

typedef enum {
    FAILED = 0,
    PENDING,
    SUCCEED
} MediaLoadingStatus;

@interface MediasListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView;
    NSMutableDictionary *articleForIndexPath;
    UITableViewCell *spinnerCell;
    MediaLoadingStatus mediaLoadingStatus;
    //BOOL isLoadingNewMedias;
    UIView *loadingTopVew;
    UITableViewCell* _mediaTableViewCell;
    UITableViewCell* _retryCell;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) NSMutableDictionary *articleForIndexPath;
@property (nonatomic, retain) IBOutlet UITableViewCell *spinnerCell;
@property (nonatomic, retain) UIView *loadingTopVew;
@property (nonatomic, retain) IBOutlet UITableViewCell* mediaTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* retryCell;

- (void) getNextArticles;
- (IBAction)reloadButtonAction:(id)sender;

@end

