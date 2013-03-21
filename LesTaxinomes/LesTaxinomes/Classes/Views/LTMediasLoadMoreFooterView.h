//
//  LTMediasLoadMoreFooterView.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIGlossyButton.h"

typedef enum {
    LTMediasLoadMoreFooterViewDisplayModeNormal
    ,LTMediasLoadMoreFooterViewDisplayModeLoading
    
} LTMediasLoadMoreFooterViewDisplayMode;

@interface LTMediasLoadMoreFooterView : PSTCollectionReusableView

@property (nonatomic, readonly) UIGlossyButton* loadMoreButton;
@property (nonatomic) LTMediasLoadMoreFooterViewDisplayMode displayMode;

@end
