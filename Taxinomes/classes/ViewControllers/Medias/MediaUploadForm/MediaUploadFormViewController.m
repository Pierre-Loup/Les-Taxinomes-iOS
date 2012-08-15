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
#import "NSData+Base64.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "LTDataManager.h"
#import "LTConnectionManager.h"
#import "MediaUploadFormViewController.h"
#import "MapCell.h"
#import "SingleLineInputCell.h"
#import "UIImageView+PhotoFrame.h"

#define kLocalisationPickerCellId @"localisationPickerCell"
#define kCityCellId @"CityCell"
#define kZipcodeCellId @"ZipcodeCell"
#define kCountryCellId @"CountryCell"

//SECTION 0
#define kTitleCellIndexPath [NSIndexPath indexPathForRow:0 inSection:0]
//SECTION 1
#define kTexteCellIndexPath [NSIndexPath indexPathForRow:0 inSection:1]
//SECTION 2
#define kLicenseCellIndexPath [NSIndexPath indexPathForRow:0 inSection:2]
//SECTION 3
#define kLocationSection 3
#define kLocationPickerCellIndexPath [NSIndexPath indexPathForRow:0 inSection:3]
//SECTION 4
#define kPublishCellIndexPath [NSIndexPath indexPathForRow:0 inSection:4]

#define kSectionsNumber 4

@interface MediaUploadFormViewController ()

@property (nonatomic, retain) IBOutlet UITableViewCell* textCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* licenseCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* publishCell;
@property (nonatomic, retain) IBOutlet UIImageView* mediaSnapshotView;
@property (nonatomic, retain) UITextField* titleInput;
@property (nonatomic, retain) IBOutlet UITextView* textInput;
@property (nonatomic, retain) UITextField* cityInput;
@property (nonatomic, retain) UITextField* zipcodeInput;
@property (nonatomic, retain) UITextField* countryInput;
@property (nonatomic, retain) IBOutlet UIGlossyButton* shareButton;
@property (nonatomic, retain) IBOutlet UISwitch* publishSwitch;

// Actions
- (IBAction)uploadMedia:(id)sender;
// Tools
- (void)refreshForm;
- (void)updateMediaLocation:(CLLocation *)location;
@end

@implementation MediaUploadFormViewController
@synthesize mediaSnapshotView = mediaSnapshotView_;
@synthesize mediaImage = mediaImage_;
@synthesize textCell = textCell_;
@synthesize licenseCell = licenseCell_;
@synthesize publishCell = publishCell_;
@synthesize titleInput = titleInput_;
@synthesize textInput = textInput_;
@synthesize cityInput = cityInput_;
@synthesize zipcodeInput = zipcodeInput_;
@synthesize countryInput = countryInput_;
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
    [reverseGeocoder_ release];
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
    
    // Load textCell, licenseCell and
    [[NSBundle mainBundle] loadNibNamed:@"MediaUploadFormCells" owner:self options:nil];
    CGRect tableViewFrame = self.tableView.frame;
    CGRect winFrame = [[UIApplication sharedApplication] keyWindow].frame;
    CGRect bgFrame = CGRectMake(0, -self.navigationController.navigationBar.frame.size.height,
                                winFrame.size.width,
                                winFrame.size.height);
    UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:bgFrame];
    bgImageView.image = [UIImage imageNamed:@"background"];
    bgImageView.contentMode = UIViewContentModeTop;
    bgImageView.clipsToBounds = YES;
    bgImageView.alpha = 0.3;
    UIView* bgView = [[UIView alloc] initWithFrame:tableViewFrame];
    [bgView addSubview:bgImageView];
    [self.tableView setBackgroundView:bgView];
    [bgImageView release];
    [bgView release];
    
    self.navigationItem.title = TRANSLATE(@"media_upload_view_title");
    
    shareButton_.tintColor = kLightGreenColor;
    shareButton_.buttonCornerRadius = 10.0;
    [shareButton_ setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
    
    [self refreshForm];
    
    [mediaSnapshotView_ applyPhotoFrameEffect];
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
    
    reverseGeocoder_ = [CLGeocoder new];
    [self updateMediaLocation:gis_];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    self.mediaSnapshotView = nil;
    self.textCell = nil;
    self.licenseCell = nil;
    self.publishCell = nil;
    self.shareButton = nil;
    [super viewDidUnload];
}

#pragma mark - IBActions

- (IBAction)shareButtonPressed:(id)sender {
    [self uploadMedia:sender]; 
}

- (IBAction)uploadMedia:(id)sender {
    
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
    // Text
    if (self.textInput.text 
        && self.textInput.text != nil) {
        [info setValue:[NSString stringWithFormat:@"%@\n\n%@",self.textInput.text,TRANSLATE(@"media_upload.text_prefix")] forKey:@"texte"];
    } else {
        [info setValue:[NSString stringWithFormat:@"%@",TRANSLATE(@"media_upload.text_prefix")] forKey:@"texte"];
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

#pragma mark - Tools


- (void)refreshForm {
   NSMutableDictionary* tmpCellsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            textCell_, kTexteCellIndexPath,
                                            licenseCell_, kLicenseCellIndexPath,
                                            publishCell_, kPublishCellIndexPath,
                                            nil];
    // Title cell
    SingleLineInputCell* titleCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!titleCell) {
        titleCell = [SingleLineInputCell singleLineInputCell];
    }
    [titleCell setTitle:TRANSLATE(@"common.title")];
    self.titleInput = titleCell.input;
    [titleInput_ setDelegate:self];
    [tmpCellsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:titleCell 
                                                                       forKey:kTitleCellIndexPath]];
    // Location picker cell
    UITableViewCell* localisationPickerCell = [self.tableView dequeueReusableCellWithIdentifier:kLocalisationPickerCellId];
    if (!localisationPickerCell) {
        localisationPickerCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                         reuseIdentifier:kLocalisationPickerCellId] autorelease];
    }
    [localisationPickerCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [localisationPickerCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    localisationPickerCell.textLabel.text = TRANSLATE(@"media_upload.location_picker_cell.text");
    [tmpCellsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:localisationPickerCell forKey:kLocationPickerCellIndexPath]];
    NSInteger rowNumberForSection = 1;
    
    // Map cell
    if (gis_) {
        MapCell* mapCell = [self.tableView dequeueReusableCellWithIdentifier:[MapCell reuseIdentifier]];
        if (!mapCell) {
            mapCell = [MapCell mapCell];
        }
        MKPlacemark* annotation = [[[MKPlacemark alloc] initWithCoordinate:gis_.coordinate addressDictionary:nil] autorelease];
        [mapCell.mapView removeAnnotations:mapCell.mapView.annotations];
        [mapCell.mapView addAnnotation:annotation];
        [mapCell.mapView setRegion:MKCoordinateRegionMake(gis_.coordinate, MKCoordinateSpanMake(0.1, 0.1))];
        NSIndexPath* mapCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
        [tmpCellsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:mapCell forKey:mapCellIndexPath]];
        rowNumberForSection++;
    }
    
    // City cell
    SingleLineInputCell* cityCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!cityCell) {
        cityCell = [SingleLineInputCell singleLineInputCell];
    }
    [cityCell setTitle:TRANSLATE(@"common.city")];
    self.cityInput = cityCell.input;
    [cityCell.input setDelegate:self];
    NSIndexPath* cityCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [tmpCellsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:cityCell
                                                                       forKey:cityCellIndexPath]];
    rowNumberForSection++;
    
    // Zipcode cell
    SingleLineInputCell* zipcodeCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!zipcodeCell ) {
        zipcodeCell  = [SingleLineInputCell singleLineInputCell];
    }
    [zipcodeCell setTitle:TRANSLATE(@"common.zipcode")];
    self.zipcodeInput = zipcodeCell.input;
    [zipcodeCell.input setDelegate:self];
    
    NSIndexPath* zipcodeCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [tmpCellsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:zipcodeCell
                                                                       forKey:zipcodeCellIndexPath]];
    rowNumberForSection++;
    
    // Country cell
    SingleLineInputCell* countryCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!countryCell) {
        countryCell = [SingleLineInputCell singleLineInputCell];
    }
    [countryCell setTitle:TRANSLATE(@"common.country")];
    self.countryInput = countryCell.input;
    [countryCell.input setDelegate:self];
    
    NSIndexPath* countryCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [tmpCellsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:countryCell
                                                                       forKey:countryCellIndexPath]];
    rowNumberForSection++;
    
    [cellForIndexPath_ release];
    cellForIndexPath_ = [[NSDictionary dictionaryWithDictionary:tmpCellsDict] retain];
    [tmpCellsDict release];
    [self.tableView reloadData];
}

- (void)updateMediaLocation:(CLLocation *)location {
    if (location
        && (location.coordinate.latitude || location.coordinate.longitude)) {
        [gis_ release];
        gis_ = [location retain];
        [reverseGeocoder_ reverseGeocodeLocation:gis_ completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = [placemarks objectAtIndex:0];
            if (placemark) {
                cityInput_.text = placemark.locality;
                zipcodeInput_.text = placemark.postalCode;
                countryInput_.text = placemark.country;
            }
        }];
        [self refreshForm];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return kSectionsNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSEnumerator* enumerator = [cellForIndexPath_ keyEnumerator];
    NSIndexPath* key;
    int rowCounter = 0;
    while ((key = (NSIndexPath *)[enumerator nextObject])) {
        if (key.section == section) {
            rowCounter ++;
        }
    }
    return rowCounter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = (UITableViewCell *)[cellForIndexPath_ objectForKey:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCell *)[cellForIndexPath_ objectForKey:indexPath];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:kLicenseCellIndexPath]) {
        MediaLicenseChooserViewController* mediaLicenseChooserVC = [[MediaLicenseChooserViewController alloc] init];
        mediaLicenseChooserVC.delegate = self;
        mediaLicenseChooserVC.currentLicense = license_;
        [self.navigationController pushViewController:mediaLicenseChooserVC animated:YES];
        [mediaLicenseChooserVC release];
    } else if ([indexPath isEqual:kLocationPickerCellIndexPath]){
        MediaLocalisationPickerViewController* mediaLocationPickerVC = [[MediaLocalisationPickerViewController alloc] init];
        [mediaLocationPickerVC setDelegate:self];
        if (gis_) {
            mediaLocationPickerVC.location = gis_;
        }
        [self.navigationController pushViewController:mediaLocationPickerVC animated:YES];
        [mediaLocationPickerVC release];
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
            CLLocation* mediaLocation = [imageMetadata location];
            [self updateMediaLocation:mediaLocation];
            
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

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

#pragma mark - UITextViewdDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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

#pragma mark MediaLocationPickerDelegate

- (void)mediaLocationPicker:(MediaLocalisationPickerViewController *)mediaLocationPicker didPickLocation:(CLLocation *)location {
    [self updateMediaLocation:location];
}

#pragma mark - LTConnextionManagerDelegate

- (void)didSuccessfullyUploadMedia:(Media *)media {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"media_upload_view_title") message:TRANSLATE(@"alert_upload_succeded") delegate:nil cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self hideLoader];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"media_upload_view_title") message:TRANSLATE(@"alert_upload_failed") delegate:nil cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self hideLoader];
}

@end
