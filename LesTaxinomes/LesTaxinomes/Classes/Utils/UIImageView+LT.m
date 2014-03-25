//
//  UIImageView+LT.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 25/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "UIImageView+LT.h"

#import "LTMedia+Business.h"
#import "UIImageView+AFNetworking.h"

static NSString* const LTMediaPlaceholderThumbnailSuffix = @"_thumbnail";

@implementation UIImageView (LT)

-(void)setImageWithMedia:(LTMedia*)media
{
    
    CGSize viewSize = self.frame.size;
    BOOL isTooBig = (viewSize.width > 320 || viewSize.width > 320);
    if (isTooBig)
    {
        return;
    }
    BOOL isThumbnail = (viewSize.width <= 110 || viewSize.width <= 110);
    
    NSString* placeholderImageName;
    LTMediaType  mediaType = [media.type integerValue];
    NSString* suffix = isThumbnail ? LTMediaPlaceholderThumbnailSuffix : @"";
    if (mediaType == LTMediaTypeImage)
    {
        placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_image", suffix];
        NSString* mediaURLString = isThumbnail ? media.mediaThumbnailUrl : media.mediaMediumURL;
        [self setImageWithURL:[NSURL URLWithString:mediaURLString]
             placeholderImage:[UIImage imageNamed:placeholderImageName]];
    }
    else if (mediaType == LTMediaTypeAudio)
    {
        placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_audio", suffix];
        self.image = [UIImage imageNamed:placeholderImageName];
    }
    else if (mediaType == LTMediaTypeVideo)
    {
        placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_video", suffix];
        self.image = [UIImage imageNamed:placeholderImageName];
    }
    else
    {
        placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_other", suffix];
        self.image = [UIImage imageNamed:placeholderImageName];
    }
}

@end
