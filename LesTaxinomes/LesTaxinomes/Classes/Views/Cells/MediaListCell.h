//
//  MediaListCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 18/08/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@interface MediaListCell : UITableViewCell
@property (nonatomic, assign) Media* media;
+ (MediaListCell *)mediaListCell;
@end
