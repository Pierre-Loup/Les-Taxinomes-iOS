//
//  LTPhotoAssetManager.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 07/09/13.
//  Copyright (c) 2013 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PhotoAssetPickedBlock)(NSURL* chosenImageAssetURL, NSError* error);

@interface LTPhotoAssetManager : NSObject

@property (nonatomic, strong) UIViewController *presentVC;

@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) PhotoAssetPickedBlock photoAssetPickedBlock;

+ (LTPhotoAssetManager *)sharedManager;

- (void) photoAssetPickerWithTitle:(NSString*) title
                        showInView:(UIView*) view
                         presentVC:(UIViewController*) presentVC
                     onPhotoPicked:(PhotoAssetPickedBlock) photoAssetPicked
                          onCancel:(CancelBlock) cancelled;

@end
