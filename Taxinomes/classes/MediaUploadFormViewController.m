//
//  MediaUploadFormViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 30/01/12.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "MediaUploadFormViewController.h"
#import "NSData+Base64.h"
#import "DataManager.h"


@implementation MediaUploadFormViewController
@synthesize tableView = _tableView;
@synthesize mediaSnapshotView = _mediaSnapshotView;
@synthesize media =_media;
@synthesize titleCell = _titleCell;
@synthesize textCell = _textCell;
@synthesize publishCell = _publishCell;
@synthesize titleInput = _titleInput;
@synthesize textInput = _textInput;
@synthesize publishSwitch = _publishSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(self.media == nil){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;    
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        
        [self presentModalViewController:imagePicker animated:YES];
    } else {
        self.mediaSnapshotView.image = self.media;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.tabBarItem.title = @"Publier";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBActions

- (IBAction)uploadMedia:(id)sender {
    //NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_article intValue]],[NSNumber numberWithDouble:[UIScreen mainScreen].bounds.size.width ], nil] forKeys:[NSArray arrayWithObjects:@"id_article", @"document_largeur", nil]];
    //NSLog(@"%f",kScreenScale*MEDIA_MAX_WIDHT);
    
    NSDictionary *document = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"000000000000000000000.jpg", @"image/jpeg", self.media, nil] forKeys:[NSArray arrayWithObjects:@"name", @"type", @"bits", nil]];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:document,  nil] forKeys:[NSArray arrayWithObjects: @"document", nil]];
    // Title
    if (self.titleInput.text != @"") {
        [info setValue:self.titleInput.text forKey:@"titre"];
    }
    // Test
    if (self.textInput.text != @"") {
        [info setValue:self.textInput.text forKey:@"texte"];
    }
    // Publish
    if (self.publishSwitch.on) {
        [info setValue:@"publie" forKey:@"statut"];
    }
    DataManager *dataManager = [DataManager sharedDataManager];
    [dataManager addArticleWithInformations:[NSDictionary dictionaryWithDictionary:info]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat defaultHeight = 44.0;
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                return self.titleCell.frame.size.height;
                break;
            case 1:
                return self.textCell.frame.size.height;
                break;
            case 2:
                return self.publishCell.frame.size.height;
                break;
            default:
                return defaultHeight;
                break;
        }
    } else {
        return defaultHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *gridCellIdentifier = @"accountMenuCell";
    
    UITableViewCell *cell = nil;
    
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                return self.titleCell;
                break;
            case 1:
                return self.textCell;
                break;
            case 2:
                return self.publishCell;
                break;
            default:
                cell = [tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"accountMenuCell"];
                }
                return cell;
                break;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"accountMenuCell"];
        }
        cell.textLabel.text = @"Uploader";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:@selector(uploadMedia:)];    
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    self.media = nil;
    self.media = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.mediaSnapshotView.image = self.media;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImageTextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleInput) {
        [self.textInput becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIImageTextViewdDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
