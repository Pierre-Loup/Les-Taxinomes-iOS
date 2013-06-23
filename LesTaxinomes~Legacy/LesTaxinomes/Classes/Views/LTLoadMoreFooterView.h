//
//  LTLoadMoreFooterView.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIGlossyButton.h"

typedef enum {
    LTLoadMoreFooterViewDisplayModeNormal
    ,LTLoadMoreFooterViewDisplayModeLoading
    
} LTLoadMoreFooterViewDisplayMode;

@interface LTLoadMoreFooterView : PSTCollectionReusableView

@property (nonatomic, readonly) UIGlossyButton* loadMoreButton;
@property (nonatomic) LTLoadMoreFooterViewDisplayMode displayMode;

@end
