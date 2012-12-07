//
//  LTiPhoneBackgroundView.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 25/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTiPhoneBackgroundView.h"

@interface LTiPhoneBackgroundView () {
    UIImageView* bgImageView_;
}
- (void)setup;
@end

@implementation LTiPhoneBackgroundView

#pragma mark - Rewrite super methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc {
    [bgImageView_ release];
    [super dealloc];
}

#pragma mark - Properties
   
- (void)setLight:(BOOL)light {
    _light = light;
    if (light) {
        bgImageView_.alpha = 0.3;
    } else {
        bgImageView_.alpha = 1.0;
    }
}

#pragma mark - Private methodes

- (void)setup {
    bgImageView_ = [[UIImageView alloc] initWithFrame:self.bounds];
    bgImageView_.image = [UIImage imageNamed:@"background-568h"];
    bgImageView_.contentMode = UIViewContentModeTop;
    bgImageView_.clipsToBounds = YES;
    [bgImageView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:bgImageView_];
    self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 1.0;
}

@end
