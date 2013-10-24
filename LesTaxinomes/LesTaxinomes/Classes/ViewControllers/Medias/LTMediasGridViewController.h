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
@class LTMedia;

@interface LTMediasGridViewController : LTCollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) LTLoadMoreFooterView* footerView;
@property (nonatomic, readonly) UIRefreshControl* refreshControl;
@property (nonatomic, weak) id<LTMediasDataSource> dataSource;
@property (nonatomic, weak) id<LTMediasDelegate> delegate;

@property (nonatomic, weak) LTMedia *firstVisibleMedia;

@end
