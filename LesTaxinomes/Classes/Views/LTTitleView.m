//
//  LTTitleView.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 21/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "LTTitleView.h"

#define kTitleLabelMarginLeft 5.0
#define kTitleLabelMarginRight 60.0

@interface LTTitleView ()
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
- (void)setupWithFrame:(CGRect)frame;
@end

@implementation LTTitleView
@synthesize titleLabel = titleLabel_;
@synthesize backgroundImageView = backgroundImageView_;

+ (LTTitleView *)titleViewWithFrame:(CGRect)frame {
    return [[[self alloc] initWithFrame:frame] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithFrame:frame];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupWithFrame:self.bounds];
}

- (void)dealloc {
    [titleLabel_ release];
    [backgroundImageView_ release];
    [super dealloc];
}

#pragma mark - Properties

- (void)setTitle:(NSString *)title {
    titleLabel_.text = title;
}

- (NSString *)title {
    return titleLabel_.text;
}

#pragma mark Private methodes

- (void)setupWithFrame:(CGRect)frame {
    backgroundImageView_ = [[UIImageView alloc] initWithFrame:frame];
    backgroundImageView_.image = [[UIImage imageNamed:@"bg_title"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    backgroundImageView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundImageView_.opaque = NO;
    backgroundImageView_.backgroundColor = [UIColor clearColor];
    [self addSubview:backgroundImageView_];
    
    CGRect titleLabelFrame = CGRectMake(kTitleLabelMarginLeft, 0, frame.size.width-kTitleLabelMarginLeft-kTitleLabelMarginRight, frame.size.height);
    titleLabel_ = [[UILabel alloc] initWithFrame:titleLabelFrame];
    titleLabel_.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel_.minimumFontSize = 10.0;
    titleLabel_.textColor = [UIColor whiteColor];
    titleLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel_.opaque = NO;
    titleLabel_.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel_];
}

@end
