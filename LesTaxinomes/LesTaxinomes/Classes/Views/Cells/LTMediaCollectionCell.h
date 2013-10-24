//
//  LTMediaCollectionCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LTMedia.h"

@interface LTMediaCollectionCell : UICollectionViewCell

@property (nonatomic, strong) LTMedia *media;

+ (NSString *)reuseIdentifier;

@end
