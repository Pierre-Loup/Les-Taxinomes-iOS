//
//  LTSectionCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 23/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTSectionCell.h"

@interface LTSectionCell ()

@property (nonatomic, strong) UIButton* infoButton;
@property (nonatomic, strong) UILabel* sectionNameLabel;

@end

@implementation LTSectionCell

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

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

#pragma mark - Public method
#pragma mark Properties

- (void)setSection:(LTSection *)section
{
    self.sectionNameLabel.text = section.title;
    
    if ([section.children count] > 0)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)setup
{
    UILabel* sectionNameLabel = [UILabel new];
    sectionNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:sectionNameLabel];
    
    UIButton* infoButton;
    if (IOS7_OR_GREATER)
    {
        infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else
    {
        infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    }
    infoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:infoButton];

    
    NSDictionary* views = NSDictionaryOfVariableBindings(sectionNameLabel, infoButton);
    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[sectionNameLabel]-[infoButton]-8-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [self.contentView addConstraints:constraints];
    
    NSLayoutConstraint* yCenterConstraint;
    yCenterConstraint = [NSLayoutConstraint constraintWithItem:sectionNameLabel
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.contentView
                                                    attribute:NSLayoutAttributeCenterY
                                                   multiplier:1.f constant:0.f];
    [self.contentView addConstraint:yCenterConstraint];
    yCenterConstraint = [NSLayoutConstraint constraintWithItem:infoButton
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.contentView
                                                    attribute:NSLayoutAttributeCenterY
                                                   multiplier:1.f constant:0.f];
    [self.contentView addConstraint:yCenterConstraint];
    
    self.sectionNameLabel   = sectionNameLabel;
    self.infoButton         = infoButton;
    
}

@end
