//
//  MediaFullSizeViewContoller.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 24/01/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaFullSizeViewContoller : UIViewController <UIScrollViewDelegate>{
    UIScrollView* _scrollView;
    UIActivityIndicatorView* _spinner;
    UIImageView *_mediaView;
}

@property(retain,nonatomic) IBOutlet UIScrollView* scrollView;
@property(retain,nonatomic) UIActivityIndicatorView* spinner;
@property(retain,nonatomic) UIImageView *mediaView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil media:(UIImage *)media;

@end
