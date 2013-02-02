//
//  UIActionSheet+PhotoAssetPickerAddition.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 02/11/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <AssetsLibrary/ALAsset.h>

#import "UIActionSheet+PhotoAssetPickerAddition.h"

static CancelBlock _cancelBlock;
static PhotoAssetPickedBlock _photoAssetPickedBlock;
static UIViewController *_presentVC;

@implementation UIActionSheet (PhotoAssetPickerAddition)

+ (void) photoAssetPickerWithTitle:(NSString*) title
                        showInView:(UIView*) view
                         presentVC:(UIViewController*) presentVC
                     onPhotoPicked:(PhotoAssetPickedBlock) photoAssetPicked
                          onCancel:(CancelBlock) cancelled;
{
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
    
    [_photoAssetPickedBlock release];
    _photoAssetPickedBlock  = [photoAssetPicked copy];
    
    [_presentVC release];
    _presentVC = [presentVC retain];
    
    int cancelButtonIndex = -1;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:(id)[self class]
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
    
    [actionSheet release];
}


+ (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* assertURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    if (assertURL) {
        _photoAssetPickedBlock(assertURL, nil);
    } else {
        
        UIImage *editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerEditedImage];
        if(!editedImage)
            editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
        NSMutableDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
        
        ALAssetsLibrary *assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        
        // Retrieve the image orientation from the ALAsset

        
        [assetsLibrary writeImageToSavedPhotosAlbum:editedImage.CGImage
                                           metadata:metadata
                                    completionBlock:^(NSURL *recAssertURL, NSError *error) {
                                        _photoAssetPickedBlock(recAssertURL, error);
                                    }];
    }
    [picker dismissModalViewControllerAnimated:YES];
    [picker autorelease];
}


+ (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [_presentVC dismissModalViewControllerAnimated:YES];
    [picker autorelease];
    [_presentVC release];
    _cancelBlock();
}

+(void)actionSheet:(UIActionSheet*) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if(buttonIndex == [actionSheet cancelButtonIndex])
    {
        _cancelBlock();
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
        picker.delegate = (id)[self class];
        //picker.allowsEditing = YES;
        
        if(buttonIndex == 1)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        else if(buttonIndex == 2)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;;
        }
        
        [_presentVC presentModalViewController:picker animated:YES];
    }
}


@end
