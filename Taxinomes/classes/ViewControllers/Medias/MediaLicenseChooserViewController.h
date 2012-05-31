//
//  MediaLicenseChooserViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/05/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "License.h"
#import "LTViewController.h"

@protocol MediaLicenseChooserDelegate <NSObject>

- (void)didSelectLicense:(License *)license;

@end

@interface MediaLicenseChooserViewController : LTViewController <UITableViewDataSource, UITableViewDelegate> {
    
    id<MediaLicenseDelegate> delegate_;
    
    UITableView * tableView_;
    NSMutableArray * licenses_;
    
    
}

@property (nonatomic, retain) id<MediaLicenseDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain)NSMutableArray * licenses;

@end
