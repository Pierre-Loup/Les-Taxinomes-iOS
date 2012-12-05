//
//  MediaListCell.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 18/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "MediaListCell.h"

#import "Author.h"
#import "UIImageView+AFNetworking.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface MediaListCell ()
@property (nonatomic, retain) IBOutlet UIImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* title;
@property (nonatomic, retain) IBOutlet UILabel* author;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation MediaListCell

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Supermethods overrides

- (id)init
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView* view = [views objectAtIndex:0];
    if ([view isKindOfClass:[self class]]) {
        self = (MediaListCell *)[view retain];
        return self;
    } else {
        return nil;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

+ (MediaListCell *)mediaListCell
{
    return [[[self alloc] init] autorelease];
}

#pragma mark Properties

- (void)setMedia:(Media *)media
{
    if (media.title.length) {
        self.title.text = media.title;
    } else {
        self.title.text = _T(@"media_upload_no_title");
    }
    
    self.author.text = media.author.name;
    
    [self.image setImageWithURL:[NSURL URLWithString:media.mediaThumbnailUrl]
               placeholderImage:[UIImage imageNamed:@"thumbnail_placeholder"]];
}

@end
