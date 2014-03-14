//
//  LTAuthorCollectionCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAuthorCollectionCell.h"
// UI
#import "UIImageView+AFNetworking.h"
// MODEL
#import "LTAuthor.h"

@interface LTAuthorCollectionCell ()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* visitsLabel;

@end

@implementation LTAuthorCollectionCell

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
    
    CGRect imageFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageView];
    
    CGRect authorNameFrame = CGRectMake(0, self.bounds.size.width, self.bounds.size.width, 20);
    self.nameLabel = [[UILabel alloc] initWithFrame:authorNameFrame];
    self.nameLabel.font = [UIFont systemFontOfSize:14.0];
    self.nameLabel.textColor = [UIColor mainColor];
    [self addSubview:self.nameLabel];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
#pragma mark Properties

- (void)setAuthor:(LTAuthor *)author
{
    _author = author;
    [self.imageView setImageWithURL:[NSURL URLWithString:author.avatarURL]
                   placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.nameLabel.text = author.name;
}

@end
