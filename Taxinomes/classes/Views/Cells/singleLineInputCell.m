//
//  SingleLineInputCell.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 12/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "SingleLineInputCell.h"

@implementation SingleLineInputCell
@synthesize titleLabel = titleLabel_;
@synthesize input = input_;

+ (SingleLineInputCell *)singleLineInputCell {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        SingleLineInputCell* cell = (SingleLineInputCell *)view;
        return cell;
    }
    return nil;
}

+ (SingleLineInputCell *)singleLineInputCellWithTitle:(NSString *)title {
    SingleLineInputCell* cell = [SingleLineInputCell singleLineInputCell];
    [cell setTitle:title];
    return cell;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title {
    CGFloat titleLabelWidth = MIN(0.75*self.frame.size.width, [title sizeWithFont:self.titleLabel.font].width);
    NSLog(@"titleLabelWidth:%f",titleLabelWidth);
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, 
                                       self.titleLabel.frame.origin.y, 
                                       titleLabelWidth, 
                                       self.titleLabel.frame.size.height)];
    self.titleLabel.text = title;
    
    CGFloat inputOriginX = 2*self.titleLabel.frame.origin.x + titleLabelWidth;
    CGFloat inputWidth = self.frame.size.width - self.titleLabel.frame.origin.x - inputOriginX;
    NSLog(@"%@ - inputOriginX:%f inputWidth:%f",title, inputOriginX, inputWidth);
    [self.input setFrame:CGRectMake(inputOriginX, 
                                  self.input.frame.origin.y, 
                                  inputWidth,
                                  self.input.frame.size.height)];
}

@end
