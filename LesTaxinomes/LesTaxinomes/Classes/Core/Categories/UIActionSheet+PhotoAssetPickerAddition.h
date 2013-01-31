//
//  UIActionSheet+PhotoAssetPickerAddition.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 02/11/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PhotoAssetPickedBlock)(NSURL* chosenImageAssetURL, NSError* error);

@interface UIActionSheet (PhotoAssetPickerAddition)

+ (void) photoAssetPickerWithTitle:(NSString*) title
                        showInView:(UIView*) view
                         presentVC:(UIViewController*) presentVC
                     onPhotoPicked:(PhotoAssetPickedBlock) photoAssetPicked
                          onCancel:(CancelBlock) cancelled;

@end
