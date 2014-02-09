//
//  LTPhotoAssetManager.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 07/09/13.
//  Copyright (c) 2013 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "LTPhotoAssetManager.h"

@interface LTPhotoAssetManager () <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

@end

@implementation LTPhotoAssetManager

+ (LTPhotoAssetManager *)sharedManager
{
    static LTPhotoAssetManager* sharedManager = nil;
    static dispatch_once_t  sharedManagerOnceToken;
    
    dispatch_once(&sharedManagerOnceToken, ^{
        sharedManager = [[LTPhotoAssetManager alloc] init];
    });
    
    return sharedManager;
}

- (void) photoAssetPickerWithTitle:(NSString*) title
                        showInView:(UIView*) view
                         presentVC:(UIViewController*) presentVC
                     onPhotoPicked:(PhotoAssetPickedBlock) photoAssetPicked
                          onCancel:(CancelBlock) cancelled;
{
    
    self.cancelBlock  = cancelled;
    self.photoAssetPickedBlock  = photoAssetPicked;
    self.presentVC = presentVC;
    
    int cancelButtonIndex = -1;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
    
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		[actionSheet addButtonWithTitle:_T(@"photo_action_sheet.camera")];
		cancelButtonIndex ++;
	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		[actionSheet addButtonWithTitle:_T(@"photo_action_sheet.photo_library")];
		cancelButtonIndex ++;
	}
    
	[actionSheet addButtonWithTitle:_T(@"common.cancel")];
	cancelButtonIndex ++;
	
	actionSheet.cancelButtonIndex = cancelButtonIndex;
    
	if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* assertURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    if (assertURL) {
        self.photoAssetPickedBlock(assertURL, nil);
    } else {
        
        UIImage *editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerEditedImage];
        if(!editedImage)
            editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
        NSMutableDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
        
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
        
        // Retrieve the image orientation from the ALAsset
        
        
        [assetsLibrary writeImageToSavedPhotosAlbum:editedImage.CGImage
                                           metadata:metadata
                                    completionBlock:^(NSURL *recAssertURL, NSError *error) {
                                        self.photoAssetPickedBlock(recAssertURL, error);
                                    }];
    }
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [self.presentVC dismissViewControllerAnimated:YES completion:^{}];
    self.cancelBlock();
}

- (void)actionSheet:(UIActionSheet*) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if(buttonIndex == [actionSheet cancelButtonIndex])
    {
        self.cancelBlock();
    }
    else
    {
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            buttonIndex ++;
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            buttonIndex ++;
        }
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        
        if(buttonIndex == 1)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        else if(buttonIndex == 2)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        [self.presentVC presentViewController:picker animated:YES completion:^{}];
    }
}

@end
