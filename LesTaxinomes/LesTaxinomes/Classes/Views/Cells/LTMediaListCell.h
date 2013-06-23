//
//  MediaListCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 18/08/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTMedia.h"

@interface LTMediaListCell : UITableViewCell

@property (nonatomic, strong) LTMedia *media;

+ (LTMediaListCell *)mediaListCell;

@end
