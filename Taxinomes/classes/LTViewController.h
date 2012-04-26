//
//  LTViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup on 07/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIProgressDelegate.h"

@interface LTViewController : UIViewController <MBProgressHUDDelegate, ASIProgressDelegate> {
    MBProgressHUD *loaderView_;
}

@property (nonatomic, retain) MBProgressHUD* loaderView;

- (void) displayLoaderViewWithDetermination:(BOOL)determinate whileExecuting:(SEL)myTask;
- (void) displayLoader;
- (void) hideLoaderView;

@end
