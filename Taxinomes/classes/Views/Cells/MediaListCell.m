//
//  MediaListCell.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 18/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "MediaListCell.h"

@implementation MediaListCell
@synthesize  image = image_;
@synthesize  title = title_;
@synthesize author = author_;

+ (MediaListCell *)mediaListCell {
    return [[[self alloc] init] autorelease];
}

- (id)init {
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView* view = [views objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        self = (MediaListCell *)[view retain];
        return self;
    } else {
        return nil;
    }
}

@end
