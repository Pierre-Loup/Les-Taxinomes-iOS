//
//  LTViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup on 07/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
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
#import "MBProgressHUD.h"
#import "ASIProgressDelegate.h"

@interface LTViewController : UIViewController <MBProgressHUDDelegate, ASIProgressDelegate> {
    MBProgressHUD *loaderView_;
}

@property (nonatomic, retain) MBProgressHUD* loaderView;

- (void) displayLoaderViewWithDetermination;
- (void) displayLoader;
- (void) hideLoader;

@end
