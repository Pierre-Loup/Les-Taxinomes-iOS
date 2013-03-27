//
//  LTMediasDelegate.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 21/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LTMediasDelegate <NSObject>
@required
- (void)refreshMedias;
- (void)loadMoreMedias;

@end
