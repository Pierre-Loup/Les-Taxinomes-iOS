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

@end
