//
//  LTMediasGridViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTCollectionViewController.h"

#import "LTMediasDataSource.h"
#import "LTMediasDelegate.h"
#import "LTLoadMoreFooterView.h"

@class LTLoadMoreFooterView;
@class Media;
@class SRRefreshView;

@interface LTMediasGridViewController : LTCollectionViewController

@property (nonatomic, readonly) LTLoadMoreFooterView* footerView;
@property (nonatomic, readonly) SRRefreshView* slimeView;
@property (nonatomic, weak) id<LTMediasDataSource> dataSource;
@property (nonatomic, weak) id<LTMediasDelegate> delegate;

@property (nonatomic, weak) Media* firstVisibleMedia;

@end
