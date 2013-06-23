//
//  SpinnerCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 19/08/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "SpinnerCell.h"

@implementation SpinnerCell

+ (SpinnerCell *)spinnerCell {
    return [[self alloc] init];
}

- (id)init {
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView* view = [views objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        self = (SpinnerCell *)view;
        [self.spinner startAnimating];
        return self;
    } else {
        return nil;
    }
}


@end
