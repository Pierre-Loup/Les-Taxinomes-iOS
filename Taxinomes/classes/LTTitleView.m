//
//  LTTitleView.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 21/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

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
