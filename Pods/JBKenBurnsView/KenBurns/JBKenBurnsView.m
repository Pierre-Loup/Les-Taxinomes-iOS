//
//  KenBurnsView.m
//  KenBurns
//
//  Created by Javier Berlana on 9/23/11.
//  Copyright (c) 2011, Javier Berlana
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this 
//  software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, 
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies 
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//  IN THE SOFTWARE.
//

#import "JBKenBurnsView.h"
#include <stdlib.h>

#define enlargeRatio 1.1
#define imageBufer 3

enum JBSourceMode {
    JBSourceModeImages,
//    JBSourceModeURLs,
    JBSourceModePaths,
    JBSourceModeDatasource
};

// Private interface
@interface JBKenBurnsView ()

@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (assign, nonatomic) CGFloat showImageDuration;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) BOOL shouldLoop;
@property (assign, nonatomic) BOOL isLandscape;
@property (assign, nonatomic) NSTimer *nextImageTimer;
@property (assign, nonatomic) enum JBSourceMode sourceMode;
@property (assign, nonatomic) BOOL rotates;

@property (assign, nonatomic) BOOL startImmediatelyWithoutFadeIn;

@end


@implementation JBKenBurnsView

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
}

- (void)animateWithImagePaths:(NSArray *)imagePaths transitionDuration:(CGFloat)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape
{
    self.sourceMode = JBSourceModePaths;
    [self _startAnimationsWithData:imagePaths transitionDuration:duration loop:shouldLoop isLandscape:isLandscape];
}

- (void)animateWithImages:(NSArray *)images transitionDuration:(CGFloat)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape {
    self.sourceMode = JBSourceModeImages;
    [self _startAnimationsWithData:images transitionDuration:duration loop:shouldLoop isLandscape:isLandscape];
}

- (void)startAnimationWithDatasource:(id<JBKenBurnsViewDatasource>)datasource loop:(BOOL)isLoop rotates:(BOOL)rotates isLandscape:(BOOL)isLandscape
{
    self.sourceMode = JBSourceModeDatasource;
    self.datasource = datasource;
    
    // start at 0
    self.currentIndex       = -1;
   
    self.showImageDuration  = [self.datasource kenBurnsView:self transitionDurationForImageAtIndex:self.currentIndex+1];
    self.shouldLoop         = isLoop;
    self.isLandscape        = isLandscape;
    self.rotates            = rotates;
    self.startImmediatelyWithoutFadeIn  = YES;

    [self nextImage];
}

- (void)stopAnimation {
    
    if (self.sourceMode == JBSourceModeDatasource) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextImage) object:nil];
    }
    else {
        if (self.nextImageTimer && [self.nextImageTimer isValid]) {
            [self.nextImageTimer invalidate];
            self.nextImageTimer = nil;
        }
    }
    
    
}

- (void)pauseAnimation {

    _paused = YES;
    
    // stop timer
    [self stopAnimation];
    
    // Find the current view
    if ([[self subviews] count] > 0){
        UIView *imageView = [[self subviews] objectAtIndex:0];

        CALayer *layer = imageView.layer;
        CFTimeInterval paused_time = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0f;
        layer.timeOffset = paused_time;
    }
}

- (void)resumeAnimation {
    
    _paused = NO;
    
    // Find the current view
    if ([[self subviews] count] > 0){
        UIView *imageView = [[self subviews] objectAtIndex:0];
        
        CALayer *layer = imageView.layer;
        CFTimeInterval paused_time = [layer timeOffset];
        layer.speed = 1.0f;
        layer.timeOffset = 0.0f;
        layer.beginTime = 0.0f;
        CFTimeInterval time_since_pause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - paused_time;
        layer.beginTime = time_since_pause;
        
        // restart timer
        CGFloat durationLeft = self.showImageDuration - time_since_pause;

        [self performSelector:@selector(nextImage) withObject:nil afterDelay:durationLeft];
//        self.nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:durationLeft target:self selector:@selector(nextImage) userInfo:nil repeats:NO];
    }
}

- (void)_startAnimationsWithData:(NSArray *)data transitionDuration:(CGFloat)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape
{
    self.imagesArray        = [data mutableCopy];
    self.showImageDuration  = duration;
    self.shouldLoop         = shouldLoop;
    self.isLandscape        = isLandscape;

    // start at 0
    self.currentIndex       = -1;
    
    [self stopAnimation];

    self.nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [self.nextImageTimer fire];
}

- (void)clear {
    
    [self stopAnimation];
    
    // Remove the previous view
    if ([[self subviews] count] > 0){
        UIView *oldImageView = [[self subviews] objectAtIndex:0];
        [oldImageView removeFromSuperview];
        oldImageView = nil;
    }
    
    self.datasource = nil;
    self.imagesArray = nil;
    self.showImageDuration = 0;
    self.shouldLoop = NO;
    self.isLandscape = NO;
    self.currentIndex = -1;
}

- (void)nextImage {
    
    BOOL isSynchronous = YES;
    
    self.currentIndex++;
    
    UIImage *image = nil;
    switch (self.sourceMode) {
        case JBSourceModeImages:
            image = self.imagesArray[self.currentIndex];
            break;
            
        case JBSourceModePaths:
            image = [UIImage imageWithContentsOfFile:self.imagesArray[self.currentIndex]];
            break;
            
        case JBSourceModeDatasource:
            
//            NSAssert(self.datasource, @"Datasource for JBKenBurnsView cannot be nil");
            if (!self.datasource)
            {
                return;
            }
            else if ([self.datasource respondsToSelector:@selector(kenBurnsView:imageAtIndex:)]) {
                
                image = [self.datasource kenBurnsView:self imageAtIndex:self.currentIndex];
                NSAssert(image, @"Image requested for JBKenBurnsView cannot be nil");
            }
            else if ([self.datasource respondsToSelector:@selector(kenBurnsView:loadImageAtIndex:completed:)]) {
                
                isSynchronous = NO;
                
                [self.datasource kenBurnsView:self loadImageAtIndex:self.currentIndex completed:^(UIImage *image) {
                    
                    if (image) {
                        [self animateToImage:image];
                    }
                }];
            }
            else {
                NSAssert(1, @"No method to request for image is supplied to datasource");
            }
            break;
    }
    
    if (isSynchronous) {
        [self animateToImage:image];
    }
}

- (void)animateToImage:(UIImage*)image
{
    CGFloat rotation = 0.0f;
    if (self.rotates) {
        rotation = (arc4random() % 9) / 100.0f;
    }
    NSInteger random = arc4random() % 4;
    
    [self animateToImage:image rotation:rotation random:random];
}

- (void)animateToImage:(UIImage*)image rotation:(CGFloat)rotation random:(NSInteger)random {
    
    
    CGFloat imageDurationForCurrentIndex = self.showImageDuration;

    NSInteger imageArrayCount = 0;
    switch (self.sourceMode) {
        case JBSourceModeImages:
            imageArrayCount = self.imagesArray.count;
            break;

        case JBSourceModePaths:
            imageArrayCount = self.imagesArray.count;
            break;
            
        case JBSourceModeDatasource:
            
            NSAssert(self.datasource, @"Datasource for JBKenBurnsView cannot be nil");
            
            imageArrayCount = [self.datasource numberOfImagesInKenBurnsView:self];
            imageDurationForCurrentIndex = [self.datasource kenBurnsView:self transitionDurationForImageAtIndex:self.currentIndex];

            [self performSelector:@selector(nextImage) withObject:nil afterDelay:imageDurationForCurrentIndex];
//            self.nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:imageDurationForCurrentIndex target:self selector:@selector(nextImage) userInfo:nil repeats:NO];
            
            break;
    }

    UIImageView *imageView = nil;
    
    CGFloat resizeRatio   = -1;
    CGFloat widthDiff     = -1;
    CGFloat heightDiff    = -1;
    CGFloat originX       = -1;
    CGFloat originY       = -1;
    CGFloat zoomInX       = -1;
    CGFloat zoomInY       = -1;
    CGFloat moveX         = -1;
    CGFloat moveY         = -1;
    CGFloat frameWidth    = self.isLandscape ? self.bounds.size.width: self.bounds.size.height;
    CGFloat frameHeight   = self.isLandscape ? self.bounds.size.height: self.bounds.size.width;
    
    // Wider than screen 
    if (image.size.width > frameWidth)
    {
        widthDiff  = image.size.width - frameWidth;
        
        // Higher than screen
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff) 
                resizeRatio = frameHeight / image.size.height;
            else
                resizeRatio = frameWidth / image.size.width;
            
        // No higher than screen [OK]
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            
            if (widthDiff > heightDiff) 
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = self.bounds.size.height / image.size.height;
        }
        
    // No wider than screen
    }
    else
    {
        widthDiff  = frameWidth - image.size.width;
        
        // Higher than screen [OK]
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff) 
                resizeRatio = image.size.height / frameHeight;
            else
                resizeRatio = frameWidth / image.size.width;
            
        // No higher than screen [OK]
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            
            if (widthDiff > heightDiff) 
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = frameHeight / image.size.height;
        }
    }
    
    // Resize the image.
    CGFloat optimusWidth  = (image.size.width * resizeRatio) * enlargeRatio;
    CGFloat optimusHeight = (image.size.height * resizeRatio) * enlargeRatio;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, optimusWidth, optimusHeight)];
    imageView.backgroundColor = [UIColor blackColor];
    
    // Calcule the maximum move allowed.
    CGFloat maxMoveX = optimusWidth - frameWidth;
    CGFloat maxMoveY = optimusHeight - frameHeight;
    
    switch (random) {
        case 0:
            originX = 0;
            originY = 0;
            zoomInX = 1.25;
            zoomInY = 1.25;
            moveX   = -maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 1:
            originX = 0;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.10;
            zoomInY = 1.10;
            moveX   = -maxMoveX;
            moveY   = maxMoveY;
            break;
            
        case 2:
            originX = frameWidth - optimusWidth;
            originY = 0;
            zoomInX = 1.30;
            zoomInY = 1.30;
            moveX   = maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 3:
            originX = frameWidth - optimusWidth;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.20;
            zoomInY = 1.20;
            moveX   = maxMoveX;
            moveY   = maxMoveY;
            break;
            
        default:
            NSLog(@"Unknown random number found in JBKenBurnsView _animate");
            break;
    }
    
//    NSLog(@"W: IW:%f OW:%f FW:%f MX:%f",image.size.width, optimusWidth, frameWidth, maxMoveX);
//    NSLog(@"H: IH:%f OH:%f FH:%f MY:%f\n",image.size.height, optimusHeight, frameHeight, maxMoveY);
    
    CALayer *picLayer    = [CALayer layer];
    picLayer.contents    = (id)image.CGImage;
    picLayer.anchorPoint = CGPointMake(0, 0); 
    picLayer.bounds      = CGRectMake(0, 0, optimusWidth, optimusHeight);
    picLayer.position    = CGPointMake(originX, originY);
    
    [imageView.layer addSublayer:picLayer];
    
    CFTimeInterval fadeDuration = 1.0f;
    if (self.startImmediatelyWithoutFadeIn)
    {
        fadeDuration = 0.0001f;
        self.startImmediatelyWithoutFadeIn = NO;
    }
    CATransition *animation = [CATransition animation];
    [animation setDuration:fadeDuration];
    [animation setType:kCATransitionFade];
    [[self layer] addAnimation:animation forKey:nil];
    
    // Remove the previous view
    if ([[self subviews] count] > 0){
        UIView *oldImageView = [[self subviews] objectAtIndex:0];
        [oldImageView removeFromSuperview];
        oldImageView = nil;
    }
    
    [self addSubview:imageView];
    
    // Generates the animation
    [UIView animateWithDuration:imageDurationForCurrentIndex + 2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
    {
        CGAffineTransform rotate    = CGAffineTransformMakeRotation(rotation);
        CGAffineTransform moveRight = CGAffineTransformMakeTranslation(moveX, moveY);
        CGAffineTransform combo1    = CGAffineTransformConcat(rotate, moveRight);
        CGAffineTransform zoomIn    = CGAffineTransformMakeScale(zoomInX, zoomInY);
        CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
        imageView.transform = transform;
        
    } completion:^(BOOL finished) {
        
    }];

    [self _notifyDelegate];

    if (self.currentIndex == imageArrayCount - 1) {
        if (self.shouldLoop) {
            self.currentIndex = -1;
        }else {
            [self.nextImageTimer invalidate];
            self.nextImageTimer = nil;
        }
    }
}

- (void)_notifyDelegate
{
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(didShowImageAtIndex:)])
        {
            [self.delegate didShowImageAtIndex:self.currentIndex];
        }      
        
        if (self.currentIndex == ((long) [self.imagesArray count] - 1) && !self.shouldLoop && [self.delegate respondsToSelector:@selector(didFinishAllAnimations)]) {
            [self.delegate didFinishAllAnimations];
        } 
    }
    
}

@end
