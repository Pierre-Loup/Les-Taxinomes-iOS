//
//  LTMediasGridViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTCollectionViewController.h"

#import "LTMediasRootViewController.h"

@class LTMedia;

@interface LTMediasGridViewController : LTCollectionViewController

@property (nonatomic, weak) LTMediasRootViewController* mediasRootViewController;

@property (nonatomic, weak) LTMedia *firstVisibleMedia;
@property (nonatomic, assign) CGFloat topBarOffset;
@property (nonatomic, assign) CGFloat bottomBarOffset;

@end
