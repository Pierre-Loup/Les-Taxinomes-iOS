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
#import "LTMediasLoadMoreFooterView.h"

@interface LTMediasListViewController : LTTableViewController

@property (nonatomic, readonly) LTMediasLoadMoreFooterView* footerView;
@property (nonatomic, weak) id<LTMediasDataSource> dataSource;
@property (nonatomic, weak) id<LTMediasDelegate> delegate;

@end
