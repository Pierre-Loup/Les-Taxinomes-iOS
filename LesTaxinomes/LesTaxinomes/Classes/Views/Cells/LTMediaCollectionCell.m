//
//  LTMediaCollectionCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMediaCollectionCell.h"
#import "UIImageView+AFNetworking.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private inteface

@interface LTMediaCollectionCell ()

@property (nonatomic, strong) UIImageView* imageView;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediaCollectionCell

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupCell];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)setupCell
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageView];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
#pragma mark Properties

- (void)setMedia:(Media *)media
{
    [self.imageView setImageWithURL:[NSURL URLWithString:media.mediaThumbnailUrl]
               placeholderImage:[UIImage imageNamed:@"Icon"]];
}

@end
