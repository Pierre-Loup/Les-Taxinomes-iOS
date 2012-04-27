//
//  MediaDetailViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 28/11/11.
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
#import <MapKit/MapKit.h>
#import "LTDataManager.h"
#import "Media.h"

#import "LTViewController.h"
#import "LTTitleView.h"
#import "TCImageView.h"

@interface MediaDetailViewController : LTViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, TCImageViewDelegate,  LTDataManagerDelegate, MKMapViewDelegate>{
    NSNumber * mediaIdentifier_;
    Media * media_;
    
    UIScrollView * scrollView_;
    LTTitleView * mediaTitleView_;
    TCImageView * mediaImageView_;
    LTTitleView * authorTitleView_;
    TCImageView * authorAvatarView_;
    UILabel * authorNameLabel_;
    LTTitleView * descTitleView_;
    UITextView * descTextView_;
    LTTitleView * mapTitleView_;
    MKMapView * mapView_;
}

@property (nonatomic, retain) Media * media;
@property (nonatomic, retain) NSNumber * mediaIdentifier;
@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;
@property (nonatomic, retain) TCImageView * mediaImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mediaId:(NSNumber *)mediaIdentifier;
- (void)refreshView;
- (void)mediaImageTouched:(UIImage *)sender;

@end
