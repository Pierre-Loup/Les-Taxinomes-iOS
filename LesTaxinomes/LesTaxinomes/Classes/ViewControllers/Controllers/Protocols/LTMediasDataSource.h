//
//  LTMediasDataSource.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LTMediasDataSource <NSObject>
@required
@property (nonatomic, readonly) NSFetchedResultsController* mediasResultController;

- (void)loadMoreMedias;

@end
