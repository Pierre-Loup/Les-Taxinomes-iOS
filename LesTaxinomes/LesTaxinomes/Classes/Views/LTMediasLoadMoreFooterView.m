//
//  LTMediasLoadMoreFooterView.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTMediasLoadMoreFooterView.h"
#import "UIGlossyButton+LT.h"

@interface LTMediasLoadMoreFooterView ()

@property (nonatomic, strong) UIGlossyButton* loadMoreButton;
@property (nonatomic, strong) UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) UILabel* loadingLabel;

@end

@implementation LTMediasLoadMoreFooterView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _loadMoreButton = [[UIGlossyButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 120.f, 40.f)];
        [_loadMoreButton setupStandardMainColorButton];
        [self addSubview:_loadMoreButton];
        
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingIndicator.hidden = YES;
        _loadingIndicator.hidesWhenStopped = YES;
        [self addSubview:_loadingIndicator];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGPoint viewCenter = CGPointMake(self.bounds.size.width/2,
                                     self.bounds.size.height/2);
    self.loadMoreButton.center = viewCenter;
    self.loadingIndicator.center = viewCenter;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methos

#pragma mark Properties

- (NSString*)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setDisplayMode:(LTMediasLoadMoreFooterViewDisplayMode)displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == LTMediasLoadMoreFooterViewDisplayModeLoading) {
        [self.loadingIndicator startAnimating];
    } else {
        [self.loadingIndicator stopAnimating];
    }
    self.loadMoreButton.hidden = (displayMode == LTMediasLoadMoreFooterViewDisplayModeLoading);
    self.loadingLabel.hidden = (displayMode == LTMediasLoadMoreFooterViewDisplayModeNormal);
}

@end
