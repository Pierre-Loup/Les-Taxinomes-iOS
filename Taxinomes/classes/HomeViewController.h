//
//  HomeViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UIImagePickerControllerDelegate> {
    UIButton *_cameraButton;   
}

@property (retain,nonatomic) IBOutlet UIButton *cameraButton;

- (IBAction)infoButtonAction:(id) sender;
- (IBAction)cameraButtonAction:(id) sender;

@end
