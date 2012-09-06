//
//  MapCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 11/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MapCell.h"

@implementation MapCell
@synthesize mapView = mapView_;

+ (MapCell *)mapCell {
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        return (MapCell *)view;
    }
    return nil;
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

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
