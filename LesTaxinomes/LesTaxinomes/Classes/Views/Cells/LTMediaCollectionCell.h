//
//  LTMediaCollectionCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Media.h"

@interface LTMediaCollectionCell : PSTCollectionViewCell

@property (nonatomic, weak) Media* media;

+ (NSString *)reuseIdentifier;

@end
