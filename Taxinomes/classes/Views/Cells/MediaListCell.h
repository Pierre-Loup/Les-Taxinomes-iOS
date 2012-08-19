//
//  MediaListCell.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 18/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaListCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* title;
@property (nonatomic, retain) IBOutlet UILabel* author;
@end