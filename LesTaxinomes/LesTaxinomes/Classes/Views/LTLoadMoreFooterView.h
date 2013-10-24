//
//  LTLoadMoreFooterView.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LTLoadMoreFooterViewDisplayModeNormal
    ,LTLoadMoreFooterViewDisplayModeLoading
    
} LTLoadMoreFooterViewDisplayMode;

@interface LTLoadMoreFooterView : UICollectionReusableView

@property (nonatomic, readonly) UIButton* loadMoreButton;
@property (nonatomic) LTLoadMoreFooterViewDisplayMode displayMode;

@end
