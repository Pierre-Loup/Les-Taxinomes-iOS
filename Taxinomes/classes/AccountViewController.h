//
//  AccountViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate> {
    UITableView *_tableView;
    UITableViewCell *_gridCell;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UITableViewCell *gridCell;

-(IBAction)signinButtonAction:(id)sender;
- (IBAction)cameraButtonAction:(id) sender;

@end
