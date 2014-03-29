//
//  LTButtonCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/10/13.
//  Copyright (c) 2013 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTButtonCell.h"

@interface LTButtonCell ()

@property (nonatomic, strong) IBOutlet UIButton* button;

@end

@implementation LTButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)setup
{
    if (IOS7_OR_GREATER)
    {
        self.button.tintColor = [UIColor mainColor];
    }
    else
    {
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.button.frame;
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [self.button.superview addSubview:button];
        [self.button removeFromSuperview];
        self.button = button;
        [self.button setTitleColor:[UIColor mainColor]
                               forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor]
                               forState:UIControlStateHighlighted];
    }
}

@end
