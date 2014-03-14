//
//  LTLoadMoreFooterView.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTLoadMoreFooterView.h"

@interface LTLoadMoreFooterView ()

@property (nonatomic, strong) UIButton* loadMoreButton;
@property (nonatomic, strong) UIActivityIndicatorView* loadingIndicator;

@end

@implementation LTLoadMoreFooterView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loadMoreButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadMoreButton setTitle:@"+" forState:UIControlStateNormal];
        _loadMoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:34.0];
        [_loadMoreButton setTitleColor:[UIColor mainColor] forState:UIControlStateNormal];
        [_loadMoreButton sizeToFit];
        _loadMoreButton.center = CGPointMake(self.bounds.size.width/2,
                                             self.bounds.size.height/2);
        [self addSubview:_loadMoreButton];
        [self addConstraints:@[
        [NSLayoutConstraint constraintWithItem:_loadMoreButton
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_loadMoreButton.superview
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f constant:0.f],
        [NSLayoutConstraint constraintWithItem:_loadMoreButton
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_loadMoreButton.superview
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.f constant:0.f]]];
        
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        _loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _loadingIndicator.hidden = YES;
        _loadingIndicator.hidesWhenStopped = YES;
        _loadingIndicator.center = CGPointMake(self.bounds.size.width/2,
                                             self.bounds.size.height/2);
        [self addSubview:_loadingIndicator];
        [self addConstraints:@[
        [NSLayoutConstraint constraintWithItem:_loadingIndicator
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_loadingIndicator.superview
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f constant:0.f],
        [NSLayoutConstraint constraintWithItem:_loadingIndicator.superview
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_loadingIndicator.superview
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.f constant:0.f]]];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methos

#pragma mark Properties

- (NSString*)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setDisplayMode:(LTLoadMoreFooterViewDisplayMode)displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == LTLoadMoreFooterViewDisplayModeLoading) {
        [self.loadingIndicator startAnimating];
    } else {
        [self.loadingIndicator stopAnimating];
    }
    self.loadMoreButton.hidden = (displayMode == LTLoadMoreFooterViewDisplayModeLoading);
}

@end
