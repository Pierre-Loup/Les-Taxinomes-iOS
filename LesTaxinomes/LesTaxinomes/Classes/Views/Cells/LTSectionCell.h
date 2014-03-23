//
//  LTSectionCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 23/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LTSection.h"

@interface LTSectionCell : UITableViewCell

@property (nonatomic, readonly) UIButton* infoButton;
@property (nonatomic, readonly) UILabel* sectionNameLabel;

@property (nonatomic, assign) LTSection* section;

@end
