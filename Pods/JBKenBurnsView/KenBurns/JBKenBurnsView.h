//
//  KenBurnsView.h
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


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class JBKenBurnsView;

#pragma mark - KenBurnsViewDatasource 

@protocol JBKenBurnsViewDatasource <NSObject>

/**
 * Tells the data source to return number of images to show
 * in \c kenBurnsView. (required)
 *
 * @param kenBurnsView The JBKenBurnsView requesting this information
 */
- (NSInteger)numberOfImagesInKenBurnsView:(JBKenBurnsView*)kenBurnsView;


/**
 * Asks the data source for duration to animate an image
 * in \c kenBurnsView. (required)
 *
 * @param kenBurnsView The JBKenBurnsView requesting this information
 * @param imageIndex Index of the UIImage being requested
 */
- (CGFloat)kenBurnsView:(JBKenBurnsView*)kenBurnsView transitionDurationForImageAtIndex:(NSInteger)imageIndex;

@optional;

/**
 * Asks the data source for a UIImage for display synchronously
 * in \c kenBurnsView. Only one of the image request method (synchronous or asynchronous) is required.
 *
 * @param kenBurnsView The JBKenBurnsView requesting this information
 * @param imageIndex Index of the UIImage being requested
 */
- (UIImage*)kenBurnsView:(JBKenBurnsView*)kenBurnsView imageAtIndex:(NSInteger)imageIndex;

/**
 * Asks the data source for a UIImage for display asynchronously
 * in \c kenBurnsView. Only one of the image request method (synchronous or asynchronous) is required.
 *
 * @param kenBurnsView The JBKenBurnsView requesting this information
 * @param imageIndex Index of the UIImage being requested
 * @param completed The completion block that returns the requested image
 */
- (void)kenBurnsView:(JBKenBurnsView*)kenBurnsView loadImageAtIndex:(NSInteger)imageIndex completed:(void(^)(UIImage *image))completed;

@end

#pragma mark - KenBurnsViewDelegate

@protocol JBKenBurnsViewDelegate <NSObject>
@optional
- (void)didShowImageAtIndex:(NSUInteger)index;
- (void)didFinishAllAnimations;
@end

@interface JBKenBurnsView : UIView

@property (weak, nonatomic) id<JBKenBurnsViewDelegate> delegate;
@property (weak, nonatomic) id<JBKenBurnsViewDatasource> datasource;
@property (assign, readonly, nonatomic, getter = isPaused) BOOL paused;

- (void)animateWithImagePaths:(NSArray *)imagePaths transitionDuration:(CGFloat)time loop:(BOOL)isLoop isLandscape:(BOOL)isLandscape;
- (void)animateWithImages:(NSArray *)images transitionDuration:(CGFloat)time loop:(BOOL)isLoop isLandscape:(BOOL)isLandscape;

/**
 * Starts animation. Images are requested from \c datasource
 *
 * @param datasource A protocol to request for images
 * @param isLoop The animation will start again when ended.
 * @param isLandscape If true optimized to show in Landscape mode.
 */
- (void)startAnimationWithDatasource:(id<JBKenBurnsViewDatasource>)datasource loop:(BOOL)isLoop rotates:(BOOL)rotates isLandscape:(BOOL)isLandscape;

/**
 * Stops animation. But animation in the same cycle continues
 *
 */
- (void)stopAnimation;

/**
 * Pause animation
 *
 */
- (void)pauseAnimation;

/**
 * Resumes a paused animation
 *
 */
- (void)resumeAnimation;

/**
 * Clear images and animation from the view
 *
 */
- (void)clear;

@end


