//
//  SpinnerCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 19/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinnerCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
+ (SpinnerCell *)spinnerCell;
@end
