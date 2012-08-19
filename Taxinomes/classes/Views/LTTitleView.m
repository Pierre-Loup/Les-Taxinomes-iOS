//
//  LTTitleView.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 21/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import "LTTitleView.h"

@interface LTTitleView ()
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@end

@implementation LTTitleView
@synthesize titleLabel = titleLabel_;
@synthesize backgroundImageView = backgroundImageView_;

+ (LTTitleView *)titleViewWithFrame:(CGRect)frame {
    return [[[self alloc] initWithFrame:frame] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView* view = [views objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        self = (LTTitleView *)[view retain];
        CGRect backgroundFrame = CGRectMake(frame.origin.x,
                                            frame.origin.y,
                                            frame.size.width,
                                            30);
        self.frame = backgroundFrame;
        [backgroundImageView_.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 60.0)];
        return self;
    } else {
        return nil;
    }
}

- (void)setTitle:(NSString *)title {
    titleLabel_.text = title;
}

- (NSString *)title {
    return titleLabel_.text;
}

- (void)dealloc {
    [titleLabel_ release];
    [super dealloc];
}

@end
