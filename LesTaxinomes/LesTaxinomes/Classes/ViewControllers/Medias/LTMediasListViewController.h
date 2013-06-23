//
//  LTMediasListViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTTableViewController.h"

#import "LTMediasDataSource.h"
#import "LTMediasDelegate.h"
#import "LTLoadMoreFooterView.h"

@class LTMedia;
@class SRRefreshView;

@interface LTMediasListViewController : LTTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) LTLoadMoreFooterView* footerView;
@property (nonatomic, readonly) SRRefreshView* slimeView;
@property (nonatomic, weak) id<LTMediasDataSource> dataSource;
@property (nonatomic, weak) id<LTMediasDelegate> delegate;

@property (nonatomic, weak) LTMedia *firstVisibleMedia;

@end
