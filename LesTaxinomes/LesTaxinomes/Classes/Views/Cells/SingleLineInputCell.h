//
//  SingleLineInputCell.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 12/07/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleLineInputCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField* input;

+ (SingleLineInputCell *)singleLineInputCell;
+ (SingleLineInputCell *)singleLineInputCellWithTitle:(NSString *)title;
+ (NSString *)reuseIdentifier;
- (NSString *)reuseIdentifier;
- (void)setTitle:(NSString *)title;

@end
