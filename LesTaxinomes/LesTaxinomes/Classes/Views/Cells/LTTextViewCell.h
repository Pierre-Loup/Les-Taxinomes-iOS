//
//  LTTextViewCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/10/13.
//  Copyright (c) 2013 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTTextViewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel* infoLabel;
@property (nonatomic, retain) IBOutlet UITextView* textView;
@end
