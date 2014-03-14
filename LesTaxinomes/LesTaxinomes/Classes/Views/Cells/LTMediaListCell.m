//
//  MediaListCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 18/08/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "LTMediaListCell.h"

#import "LTAuthor.h"
#import "UIImageView+AFNetworking.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTMediaListCell ()
@property (nonatomic, strong) IBOutlet UIImageView* image;
@property (nonatomic, strong) IBOutlet UILabel* title;
@property (nonatomic, strong) IBOutlet UILabel* author;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTMediaListCell

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Supermethods overrides

- (id)init
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView* view = [views objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        self = (LTMediaListCell *)view;
        self.author.textColor = [UIColor mainColor];
        return self;
    } else {
        return nil;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

+ (LTMediaListCell *)mediaListCell
{
    return [[self alloc] init];
}

#pragma mark Properties

- (void)setMedia:(LTMedia *)media
{
    _media = media;
    if (media.mediaTitle.length) {
        self.title.text = media.mediaTitle;
    } else {
        self.title.text = _T(@"media_upload_no_title");
    }
    
    self.author.text = media.author.name;
    
    [self.image setImageWithURL:[NSURL URLWithString:media.mediaThumbnailUrl]
               placeholderImage:[UIImage imageNamed:@"Icon"]];
}

@end
