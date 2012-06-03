//
//  LTTitleView.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 21/04/12.
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

#import "LTTitleView.h"

@implementation LTTitleView
@synthesize titleLabel = titleLabel_;

+ (LTTitleView *)titleViewWithOrigin:(CGPoint)origin {
    return [[[LTTitleView alloc] initWithOrigin:origin] autorelease];
}

- (id)init {
    return [self initWithOrigin:CGPointMake(0.0, 0.0)];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithOrigin:frame.origin];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithOrigin:CGPointMake(0.0, 0.0)];
}

- (id)initWithOrigin:(CGPoint)origin {
    CGRect frame = CGRectMake(origin.x, origin.y, 310, 30);
    self = [super initWithFrame:frame];
    if (self) {
        CGRect backgroundFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:backgroundFrame];
        backgroundView.image = [UIImage imageNamed:@"bg_titre_left.png"];
        [self addSubview:backgroundView];
        [backgroundView release];
        CGFloat marginLeft = 5.0;
        CGFloat marginRight = 60.0;
        CGRect titleLabelFrame = CGRectMake(marginLeft, 0, frame.size.width -marginLeft -marginRight, frame.size.height);
        titleLabel_ = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel_.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel_.textColor = [UIColor whiteColor];
        titleLabel_.font = [UIFont boldSystemFontOfSize:20];
        titleLabel_.opaque = NO;
        titleLabel_.backgroundColor = [UIColor clearColor];
        
        [self addSubview:titleLabel_];
    }
    return self;
}

- (void)dealloc {
    [titleLabel_ release];
    [super dealloc];
}

@end
