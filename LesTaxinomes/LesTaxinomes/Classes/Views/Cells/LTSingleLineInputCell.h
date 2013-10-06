//
//  LTSingleLineInputCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 12/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTSingleLineInputCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField* input;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

+ (NSString *)reuseIdentifier;
- (NSString *)reuseIdentifier;
- (void)setTitle:(NSString *)title;

@end
