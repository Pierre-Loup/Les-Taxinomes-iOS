//
//  MediaUploadFormViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 30/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <AssetsLibrary/ALAsset.h>
#import "MediaUploadFormViewController.h"
#import "NSData+Base64.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "LTDataManager.h"
#import "LTConnectionManager.h"

@interface MediaUploadFormViewController (Private)
// Actions
- (IBAction)uploadMedia:(id)sender;
// Tools
- (NSIndexPath*)indexPathForInputView:(UIView*)view;
- (UIResponder *)formFirstResponder;
- (void)dismissKeyboard;
- (void)refreshMapView;
- (void)refreshForm;
@end

@implementation MediaUploadFormViewController
@synthesize tableView = tableView_;
@synthesize mediaSnapshotView = mediaSnapshotView_;
@synthesize mediaImage = mediaImage_;
@synthesize titleCell = titleCell_;
@synthesize textCell = textCell_;
@synthesize licenseCell = licenseCell_;
@synthesize emptyLocalisationCell = emptyLocalisationCell_;
@synthesize mapLocalisationCell = mapLocalisationCell_;
@synthesize publishCell = publishCell_;
@synthesize titleInput = titleInput_;
@synthesize textInput = textInput_;
@synthesize mapView = mapView_;
@synthesize publishSwitch = publishSwitch_;
@synthesize shareButton = shareButton_;

@synthesize gis = gis_;

#pragma mark -

- (id)init
{
    self = [self initWithNibName:@"MediaUploadFormViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:@"MediaUploadFormViewController" bundle:nil];
    if (self) {
        
        rowsInSection_ = [[NSArray arrayWithObjects:[NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:1],
                           nil] retain];
        cellForIndexPath_ = [NSDictionary new];
        
        mediaImage_ = nil;
        gis_ = nil;
        license_ = [[License defaultLicense] retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [rowsInSection_ release];
    [cellForIndexPath_ release];
    [mediaImage_ release];
    [gis_ release];
    [license_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = TRANSLATE(@"media_upload_view_title");
    
    shareButton_.tintColor = kLightGreenColor;
    shareButton_.buttonCornerRadius = 10.0;
    [shareButton_ setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
    
    [self refreshForm];
    
    if(mediaImage_){
        self.mediaSnapshotView.image = mediaImage_;       
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;    
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil] autorelease];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release]; 
    }
    
    if (license_) {
        licenseCell_.detailTextLabel.text = license_.name;
    } else {
        licenseCell_.detailTextLabel.text = TRANSLATE(@"media_upload_no_license_text");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LTConnectionManager * cm = [LTConnectionManager sharedConnectionManager];
    if (![cm isAuthenticated]) {
        [self displayAuthenticationSheetAnimated:NO];
    }
}

- (void)viewDidUnload
{
    self.tableView = nil;
    self.mediaSnapshotView = nil;
    self.titleCell = nil;
    self.textCell = nil;
    self.licenseCell = nil;
    self.emptyLocalisationCell = nil;
    self.mapLocalisationCell= nil;
    self.publishCell = nil;
    self.titleInput = nil;
    self.textInput = nil;
    self.mapView = nil;
    self.publishSwitch = nil;
    self.shareButton = nil;
    [super viewDidUnload];
}

#pragma mark - IBActions

- (IBAction)shareButtonPressed:(id)sender {
    [self uploadMedia:sender]; 
}

- (IBAction)uploadMedia:(id)sender {
    
    [self dismissKeyboard];
    [self displayLoaderViewWithDetermination];
    UIImage * imageToUpload;
    if (mediaImage_.size.width > MEDIA_MAX_WIDHT) {
        CGFloat imageHeight = (MEDIA_MAX_WIDHT/mediaImage_.size.width)*mediaImage_.size.height;
        CGSize newSize = CGSizeMake(MEDIA_MAX_WIDHT, imageHeight);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [mediaImage_ drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
        UIGraphicsEndImageContext();
        imageToUpload = newImage;
    } else {
        imageToUpload = mediaImage_;
    }
    
	NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(imageToUpload, 1.0f)];//1.0f = 100% quality
    
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    // Title
    if (![self.titleInput.text isEqualToString:@""]
        && self.titleInput.text != nil) {
        [info setValue:self.titleInput.text forKey:@"titre"];
    } else {
        [info setValue:TRANSLATE(@"media_upload_no_title") forKey:@"titre"];
    }
    // Test
    if (self.textInput.text 
        && self.textInput.text != nil) {
        [info setValue:[NSString stringWithFormat:@"%@\n\n%@",self.textInput.text,kUploadMediaTextSignature] forKey:@"texte"];
    } else {
        [info setValue:[NSString stringWithFormat:@"%@",kUploadMediaTextSignature] forKey:@"texte"];
    }
    
    // Publish
    if (self.publishSwitch.on) {
        [info setValue:@"publie" forKey:@"statut"];
    } else {
        [info setValue:@"prepa" forKey:@"statut"];
    }
    
    // License
    if (license_) {
        [info setValue:[NSString stringWithFormat:@"%@",[license_.identifier stringValue]] forKey:@"id_licence"];
    }
    
    // Media
    NSDictionary *document = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: [NSString stringWithFormat:@"%@.jpg",[info objectForKey:@"title"]], @"image/jpeg", imageData, nil] forKeys:[NSArray arrayWithObjects:@"name", @"type", @"bits", nil]];
    [info setValue:document forKey:@"document"];
    
    // Media location (GIS)
    NSString* latitudeStr = [NSString stringWithFormat:@"%f", self.gis.coordinate.latitude];
    NSString* longitudeStr = [NSString stringWithFormat:@"%f", self.gis.coordinate.longitude];
    NSDictionary *gis = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:latitudeStr, longitudeStr, nil] forKeys:[NSArray arrayWithObjects:@"lat", @"lon",nil]];
    [info setValue:gis forKey:@"gis"];
    
    
    LTConnectionManager* connectionManager = [LTConnectionManager sharedConnectionManager];
    connectionManager.uploadProgressDelegate = self;
    [connectionManager addMediaWithInformations:info delegate:self];
}

- (void)displayAuthenticationSheetAnimated:(BOOL)animated {
    AuthenticationSheetViewController * authenticationSheetViewController = [[AuthenticationSheetViewController alloc] initWithNibName:@"AuthenticationSheetViewController" bundle:nil];
    authenticationSheetViewController.delegate = self;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationSheetViewController];
    self.hidesBottomBarWhenPushed = NO;
    [self.navigationController presentModalViewController:navigationController animated:animated];
    [authenticationSheetViewController release];
    [navigationController release];
}

#pragma mark - Tools

- (NSIndexPath*)indexPathForInputView:(UIView*)view{
    
    if (view == titleInput_) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    } else if (view == textInput_) {
        return [NSIndexPath indexPathForRow:0 inSection:1];
    }
    
    return nil;
}

- (UIResponder *)formFirstResponder {
    
    if ([titleInput_ isFirstResponder]) {
        return titleInput_;
    } else if ([textInput_ isFirstResponder]) {
        return textInput_;
    } else if ([publishSwitch_ isFirstResponder]) {
        return publishSwitch_;
    }
    return nil;
}

- (void)dismissKeyboard {
    [[self formFirstResponder] resignFirstResponder];
}

- (void)refreshMapView {
    MKPlacemark* annotation = [[[MKPlacemark alloc] initWithCoordinate:gis_.coordinate addressDictionary:nil] autorelease];
    [mapView_ addAnnotation:annotation];
    [mapView_ setRegion:MKCoordinateRegionMake(gis_.coordinate, MKCoordinateSpanMake(0.1, 0.1))];
}

- (void)refreshForm {
    UITableViewCell* localisationCell = nil;
    if (gis_) {
        localisationCell = mapLocalisationCell_;
        [self refreshMapView];
    } else {
        localisationCell = emptyLocalisationCell_;
    }
    
    [cellForIndexPath_ release];
    cellForIndexPath_ = [[NSDictionary alloc] initWithObjectsAndKeys:   
                         titleCell_,
                         [NSIndexPath indexPathForRow:0 inSection:0],
                         textCell_,
                         [NSIndexPath indexPathForRow:0 inSection:1],
                         licenseCell_,
                         [NSIndexPath indexPathForRow:0 inSection:2],
                         localisationCell,
                         [NSIndexPath indexPathForRow:0 inSection:3],
                         publishCell_,
                         [NSIndexPath indexPathForRow:0 inSection:4],
                         nil];
    [tableView_ reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCell*)[cellForIndexPath_ objectForKey:indexPath];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] isEqual:licenseCell_]) {
        MediaLicenseChooserViewController * mediaChooserVC = [[MediaLicenseChooserViewController alloc] init];
        mediaChooserVC.delegate = self;
        mediaChooserVC.currentLicense = license_;
        [self.navigationController pushViewController:mediaChooserVC animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    self.mediaImage = nil;
    self.mediaImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.mediaSnapshotView.image = self.mediaImage;
    
    NSURL* asserURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    // Get the assets library
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:asserURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSMutableDictionary *imageMetadata = [NSMutableDictionary dictionaryWithDictionary:[representation metadata]];
            [gis_ release];
            gis_ = [[imageMetadata location] retain];
            if (gis_) {
                [self refreshForm];
            }
            
        }
    } failureBlock:^(NSError *error) {
        
    }];
    
    [library release];
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

#pragma mark - UITextViewdDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didDismissAuthenticationSheet {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MediaLicenseChooserDelegate

- (void)didChooseLicense:(License *)license {
    [license release];
    if (license) {
        license_ = [license retain];
        licenseCell_.detailTextLabel.text = license.name;
    } else {
        license = nil;
        licenseCell_.detailTextLabel.text = TRANSLATE(@"media_upload_no_license_text");
    }
    
}

#pragma mark - LTConnextionManagerDelegate

- (void)didSuccessfullyUploadMedia:(Media *)media {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"media_upload_view_title") message:TRANSLATE(@"alert_upload_succeded") delegate:nil cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self hideLoader];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"media_upload_view_title") message:TRANSLATE(@"alert_upload_failed") delegate:nil cancelButtonTitle:TRANSLATE(@"common_OK") otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self hideLoader];
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
