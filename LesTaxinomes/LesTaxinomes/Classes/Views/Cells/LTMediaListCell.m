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
#import "UIImageView+LT.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTMediaListCell ()
@property (nonatomic, strong) IBOutlet UIImageView* image;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* authorLabel;
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
    if (media.mediaTitle.length)
    {
        self.titleLabel.text = media.mediaTitle;
    }
    else
    {
        self.titleLabel.text = _T(@"media_upload_no_title");
    }
    
    if (media.author)
    {
        NSString* from = _T(@"common.from");
        NSString* text = [NSString stringWithFormat:@"%@ %@", from, media.author.name];
        NSRange authorNameRange = {[from length], [text length]-[from length]};
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor mainColor]
                                 range:authorNameRange];
        self.authorLabel.attributedText = attributedString;
        
    }
    else
    {
        self.authorLabel.attributedText = nil;
    }
    
    
    [self.image setImageWithMedia:media];
}

@end
