//
//  LTTitleView.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 21/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTTitleView : UIView {
    UILabel * titleLabel_;
}

@property (nonatomic, retain) UILabel * titleLabel;

+ (LTTitleView *)titleViewWithOrigin:(CGPoint)origin;
- (id)initWithOrigin:(CGPoint)origin;

@end
