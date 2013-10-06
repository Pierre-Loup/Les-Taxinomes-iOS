//
//  SingleLineInputCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 12/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "LTSingleLineInputCell.h"

@interface LTSingleLineInputCell ()
@end

@implementation LTSingleLineInputCell
@synthesize titleLabel = titleLabel_;
@synthesize input = input_;

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)setTitle:(NSString *)title {
    CGRect labelFrame = self.titleLabel.frame;
    labelFrame.size.width = [title sizeWithFont:self.titleLabel.font].width;
    labelFrame.size.height = 44.f;
    self.frame = labelFrame;
    self.titleLabel.text = title;
}

@end
