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

-(void)setImageWithMedia:(LTMedia*)media completion:(void(^)())completion
{
    
    CGSize viewSize = self.frame.size;
    BOOL isTooBig = (viewSize.width > 320 || viewSize.width > 320);
    if (isTooBig)
    {
        return;
    }
    BOOL isThumbnail = (viewSize.width <= 110 || viewSize.width <= 110);
    
    LTMediaType  mediaType = [media.type integerValue];
    NSString* suffix = isThumbnail ? LTMediaPlaceholderThumbnailSuffix : @"";
    if (mediaType == LTMediaTypeImage)
    {
        NSString* placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_image", suffix];
        UIImage* placeholderImage = [UIImage imageNamed:placeholderImageName];
        NSString* imageURLString = isThumbnail ? media.mediaThumbnailUrl : media.mediaMediumURL;
        NSURL* imageURL = [NSURL URLWithString:imageURLString];
        NSURLRequest* request = [NSURLRequest requestWithURL:imageURL];
        
         __weak UIImageView* weakSelf = self;
        [self setImageWithURLRequest:request
                    placeholderImage:placeholderImage
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            weakSelf.image = image;
            if (completion) completion();
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
        {
            if (completion) completion();
        }];
    }
    else if (mediaType == LTMediaTypeAudio)
    {
        NSString* placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_audio", suffix];
        self.image = [UIImage imageNamed:placeholderImageName];
        if (completion) completion();
    }
    else if (mediaType == LTMediaTypeVideo)
    {
        NSString* placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_video", suffix];
        self.image = [UIImage imageNamed:placeholderImageName];
        if (completion) completion();
    }
    else
    {
        NSString* placeholderImageName = [NSString stringWithFormat:@"%@%@", @"placeholder_other", suffix];
        self.image = [UIImage imageNamed:placeholderImageName];
        if (completion) completion();
    }
}

@end
