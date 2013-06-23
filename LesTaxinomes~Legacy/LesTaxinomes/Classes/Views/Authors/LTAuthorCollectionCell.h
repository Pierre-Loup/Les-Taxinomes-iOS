//
//  LTAuthorCollectionCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "PSTCollectionView.h"

@class LTAuthor;

@interface LTAuthorCollectionCell : PSTCollectionViewCell

@property (nonatomic, strong) LTAuthor *author;

+ (NSString *)reuseIdentifier;

@end
