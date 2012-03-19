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
#import "NSMutableDictionary+ImageMetadata.h"
#import "LTDataManager.h"


@implementation MediaUploadFormViewController
@synthesize tableView = tableView_;
@synthesize mediaSnapshotView = mediaSnapshotView_;
@synthesize media = media_;
@synthesize titleCell = titleCell_;
@synthesize textCell = textCell_;
@synthesize licenseCell = licenseCell_;
@synthesize latitudeCell = latitudeCell_;
@synthesize longitudeCell = longitudeCell_;
@synthesize publishCell = publishCell_;
@synthesize titleInput = titleInput_;
@synthesize textInput = textInput_;
@synthesize licenseTypeChooser = licenseTypeChooser_;
@synthesize publishSwitch = publishSwitch_;
@synthesize latitudeInput = latitudeInput_;
@synthesize longitudeInput = longitudeInput_;
@synthesize shareButton = shareButton_;

@synthesize gis = gis_;

#pragma mark -



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"MediaUploadFormView" bundle:nil];
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

- (NSIndexPath*)indexPathForInputView:(UIView*)view{
    
    if (view == titleInput_) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    } else if (view == textInput_) {
        return [NSIndexPath indexPathForRow:0 inSection:1];
    } else if (view == licenseTypeChooser_) {
        return [NSIndexPath indexPathForRow:0 inSection:2];
    } else if (view == latitudeInput_) {
        return [NSIndexPath indexPathForRow:0 inSection:3];
    } else if (view == longitudeInput_) {
        return [NSIndexPath indexPathForRow:1 inSection:3];
    } else if (view == publishSwitch_) {
        return [NSIndexPath indexPathForRow:0 inSection:4];
    }
    
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Partage";
    
    //Setup Table View
    titleForSectionHeader_ = [[NSArray arrayWithObjects:@"Titre", 
                                                        @"Texte", 
                                                        @"Licence",
                                                        @"Localisation", 
                                                        @"Status", nil] retain];
    rowsInSection_ = [[NSArray arrayWithObjects:[NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:2],
                                                [NSNumber numberWithInt:1],
                                                nil] retain];
    cellForIndexPath_ = [[NSDictionary alloc] initWithObjectsAndKeys:   
                         titleCell_,
                         [NSIndexPath indexPathForRow:0 inSection:0],
                         textCell_,
                         [NSIndexPath indexPathForRow:0 inSection:1],
                         licenseCell_,
                         [NSIndexPath indexPathForRow:0 inSection:2],
                         latitudeCell_,
                         [NSIndexPath indexPathForRow:0 inSection:3],
                         longitudeCell_,
                         [NSIndexPath indexPathForRow:1 inSection:3],
                         publishCell_,
                         [NSIndexPath indexPathForRow:0 inSection:4],
                         nil];  
    
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
    
    if (self.gis != nil) {
        self.latitudeInput.text = [NSString stringWithFormat:@"%f", self.gis.coordinate.latitude];
        self.longitudeInput.text = [NSString stringWithFormat:@"%f", self.gis.coordinate.longitude];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - IBActions

- (IBAction)shareButtonPressed:(id)sender {
    [self displayLoaderViewWithDetermination:YES whileExecuting:@selector(uploadMedia:)]; 
}

- (IBAction)uploadMedia:(id)sender {
    //NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:[id_media intValue]],[NSNumber numberWithDouble:[UIScreen mainScreen].bounds.size.width ], nil] forKeys:[NSArray arrayWithObjects:@"id_media", @"document_largeur", nil]];
    //NSLog(@"%f",kScreenScale*MEDIA_MAX_WIDHT);
    
	NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(self.media, 1.0f)];//1.0f = 100% quality

    NSDictionary *document = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"000000000000000000000.jpg", @"image/jpeg", imageData, nil] forKeys:[NSArray arrayWithObjects:@"name", @"type", @"bits", nil]];    NSDictionary *gis = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: self.latitudeInput.text, self.longitudeInput.text, nil] forKeys:[NSArray arrayWithObjects:@"lat", @"lon",nil]];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:document, gis,  nil] forKeys:[NSArray arrayWithObjects: @"document",@"gis", nil]];
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
    LTConnectionManager* connectionManager = [LTConnectionManager sharedLTConnectionManager];
    connectionManager.progressDelegate = self;
    [connectionManager addmediaWithInformations:[NSDictionary dictionaryWithDictionary:info]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
        return [titleForSectionHeader_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber *rows = (NSNumber*)[rowsInSection_ objectAtIndex:section];
    return [rows intValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*)[cellForIndexPath_ objectForKey:indexPath];
    return cell.frame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [titleForSectionHeader_ objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCell*)[cellForIndexPath_ objectForKey:indexPath];
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    self.media = nil;
    self.media = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.mediaSnapshotView.image = self.media;
    
    NSLog(@"%@",info);
    /*
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
    _gis = [[metadata location] retain];
    
    _latitudeInput.text = [NSString stringWithFormat:@"%f",_gis.coordinate.latitude];
    _longitudeInput.text = [NSString stringWithFormat:@"%f",_gis.coordinate.longitude];
     */
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImageTextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField { //Keyboard becomes visible
    [UIView animateWithDuration:0.25 animations:^(void){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, 
                                      self.tableView.frame.size.width, self.tableView.frame.size.height - 215 + 50); //resize
    } completion:^(BOOL finished){
        [tableView_ scrollToRowAtIndexPath:[self indexPathForInputView: textField] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField { //keyboard will hide
    [UIView animateWithDuration:0.25 animations:^(void){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, 
                                  self.tableView.frame.size.width, self.tableView.frame.size.height + 215 - 50); //resize
    }];
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
