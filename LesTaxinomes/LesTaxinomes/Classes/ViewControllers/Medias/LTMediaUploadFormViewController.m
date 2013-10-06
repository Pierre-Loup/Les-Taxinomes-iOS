//
//  LTMediaUploadFormViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 30/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

// Core
#import "LTMapCell.h"
#import "LTConnectionManager.h"
// View
#import "LTButtonCell.h"
#import "LTSingleLineInputCell.h"
#import "LTTextViewCell.h"
#import "UIImageView+PhotoFrame.h"
// ViewController
#import "LTMediaUploadFormViewController.h"
// Model
#import "LTLicense+Business.h"
// NSFoncation Categories
#import "NSData+Base64.h"
#import "NSMutableDictionary+ImageMetadata.h"

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
#define kSubmitCellIndexPath [NSIndexPath indexPathForRow:0 inSection:4]

#define kSectionsNumber 5

@interface LTMediaUploadFormViewController ()<UITableViewDelegate,
                                            UITableViewDataSource,
                                            UITextFieldDelegate,
                                            UITextViewDelegate,
                                            UIImagePickerControllerDelegate,
                                            LTMediaLicenseChooserDelegate,
                                            MediaLocationPickerDelegate,
                                            LTConnectionManagerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView* mediaSnapshotView;

@property (nonatomic, strong) LTSingleLineInputCell* titleCell;
@property (nonatomic, strong) UITableViewCell* licenseCell;
@property (nonatomic, strong) LTSingleLineInputCell* cityCell;
@property (nonatomic, strong) LTSingleLineInputCell* zipcodeCell;
@property (nonatomic, strong) LTSingleLineInputCell* countryCell;

@property (nonatomic, strong) UITextField* titleInput;
@property (nonatomic, strong) UITextField* cityInput;
@property (nonatomic, strong) UITextField* zipcodeInput;
@property (nonatomic, strong) UITextField* countryInput;
@property (nonatomic, strong) UITextView* textInput;
@property (nonatomic, strong) UIButton* shareButton;

@property (nonatomic, strong) LTLicense *license;
@property (nonatomic, strong) CLLocation* mediaLocation;
@property (unsafe_unretained, nonatomic, readonly) NSArray* rowsInSection;
@property (nonatomic, readonly) NSMutableDictionary* cellForIndexPath;
@property (nonatomic, readonly) CLGeocoder* reverseGeocoder;

- (IBAction)uploadMedia:(id)sender;
- (void)refreshForm;
@end

@implementation LTMediaUploadFormViewController
@synthesize cellForIndexPath = _cellForIndexPath;
@synthesize reverseGeocoder = _reverseGeocoder;

#pragma mark - Super methodes override

- (id)initWithAssetURL:(NSURL*)assetURL
{
    self = [self initWithNibName:@"LTMediaUploadFormViewController" bundle:nil];
    if (self) {
        self.mediaAssetURL = assetURL;
        _rowsInSection = @[@1, @1, @1, @1, @1];
        _license = [LTLicense defaultLicense];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load textCell, licenseCell and
    self.navigationItem.title = _T(@"media_upload_view_title");
    
    self.shareButton.tintColor = kLTColorSecondary;
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:self.mediaAssetURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
        
        // Media location (GIS)
        NSMutableDictionary* imageMetadata = [NSMutableDictionary dictionaryWithDictionary:[assetRepresentation metadata]];
        self.mediaLocation = [imageMetadata location];
        
        // Retrieve the image orientation from the ALAsset
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        // Media
        CGImageRef iref = [assetRepresentation fullResolutionImage];
        if (iref) {
            self.mediaSnapshotView.image = [UIImage imageWithCGImage:iref scale:1 orientation:orientation];
        }
    } failureBlock:^(NSError *error) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.mediaSnapshotView applyPhotoFrameEffect];
    
    self.licenseCell = [self.tableView dequeueReusableCellWithIdentifier:@"LTLicenceCell"];
    if ([[UIApplication sharedApplication].keyWindow respondsToSelector:@selector(tintColor)]) {
        self.licenseCell.detailTextLabel.textColor = [UIApplication sharedApplication].keyWindow.tintColor;
    }
    
    if (self.license) {
        self.licenseCell.detailTextLabel.text = self.license.name;
    } else {
        self.licenseCell.detailTextLabel.text = _T(@"media_upload_no_license_text");
    }
    
    [self refreshForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mediaSnapshotView = nil;
    self.titleInput = nil;
    self.textInput = nil;
    self.cityInput = nil;
    self.zipcodeInput = nil;
    self.countryInput = nil;
    self.shareButton = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)refreshForm
{
    [self.cellForIndexPath removeAllObjects];
    LTTextViewCell* textViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"LTTextViewCell"];
    self.textInput = textViewCell.textView;
    [self.cellForIndexPath setObject:textViewCell
                              forKey:kTexteCellIndexPath];
    
    LTButtonCell* buttonCell = [self.tableView dequeueReusableCellWithIdentifier:@"LTButtonCell"];
    [buttonCell.button addTarget:self
                          action:@selector(uploadMedia:)
                forControlEvents:UIControlEventTouchUpInside];
    [buttonCell.button setTitle:_T(@"common.submit")
                       forState:UIControlStateNormal];
    [self.cellForIndexPath setObject:buttonCell
                              forKey:kSubmitCellIndexPath];
    
    if (self.licenseCell) {
        [self.cellForIndexPath setObject:self.licenseCell
                                  forKey:kLicenseCellIndexPath];
    }
    
    // Title cell
    if (!self.titleCell) {
        self.titleCell = [self.tableView dequeueReusableCellWithIdentifier:[LTSingleLineInputCell reuseIdentifier]];
        [self.titleCell setTitle:_T(@"common.title")];
        self.titleInput = self.titleCell.input;
        self.titleCell.input.text = @"";
        [self.titleInput setDelegate:self];
    }
    [self.cellForIndexPath setObject:self.titleCell
                              forKey:kTitleCellIndexPath];
    
    // Location picker cell
    UITableViewCell* localisationPickerCell = [self.tableView dequeueReusableCellWithIdentifier:kLocalisationPickerCellId];
    if (!localisationPickerCell) {
        localisationPickerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:kLocalisationPickerCellId];
    }
    [localisationPickerCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [localisationPickerCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    localisationPickerCell.textLabel.text = _T(@"media_upload.location_picker_cell.text");
    [self.cellForIndexPath setObject:localisationPickerCell forKey:kLocationPickerCellIndexPath];
    NSInteger rowNumberForSection = 1;
    
    // Map cell
    if (self.mediaLocation) {
        LTMapCell* mapCell = [self.tableView dequeueReusableCellWithIdentifier:[LTMapCell reuseIdentifier]];

        MKPlacemark* annotation = [[MKPlacemark alloc] initWithCoordinate:self.mediaLocation.coordinate addressDictionary:nil];
        [mapCell.mapView removeAnnotations:mapCell.mapView.annotations];
        [mapCell.mapView addAnnotation:annotation];
        [mapCell.mapView setRegion:MKCoordinateRegionMake(self.mediaLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1))];
        NSIndexPath* mapCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection
                                                           inSection:kLocationSection];
        [self.cellForIndexPath setObject:mapCell forKey:mapCellIndexPath];
        rowNumberForSection++;
    }
    
    // City cell
    if (!self.cityCell) {
        self.cityCell = [self.tableView dequeueReusableCellWithIdentifier:[LTSingleLineInputCell reuseIdentifier]];
        [self.cityCell setTitle:_T(@"common.city")];
        self.cityInput = self.cityCell.input;
        self.cityCell.input.text = @"";
        [self.cityCell.input setDelegate:self];
    }
    
    NSIndexPath* cityCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [self.cellForIndexPath setObject:self.cityCell
                              forKey:cityCellIndexPath];
    rowNumberForSection++;
    
    // Zipcode cell
    if(!self.zipcodeCell) {
        self.zipcodeCell = [self.tableView dequeueReusableCellWithIdentifier:[LTSingleLineInputCell reuseIdentifier]];
        [self.zipcodeCell setTitle:_T(@"common.zipcode")];
        self.zipcodeInput = self.zipcodeCell.input;
        [self.zipcodeCell.input setDelegate:self];
        self.zipcodeCell.input.text = @"";
    }
    
    NSIndexPath* zipcodeCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [self.cellForIndexPath setObject:self.zipcodeCell
                              forKey:zipcodeCellIndexPath];
    rowNumberForSection++;
    
    // Country cell
    if (!self.countryCell)
    {
        self.countryCell = [self.tableView dequeueReusableCellWithIdentifier:[LTSingleLineInputCell reuseIdentifier]];
        
        [self.countryCell setTitle:_T(@"common.country")];
        self.countryInput = self.countryCell.input;
        [self.countryCell.input setDelegate:self];
        self.countryCell.input.text = @"";
    }
    
    NSIndexPath* countryCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [self.cellForIndexPath setObject:self.countryCell forKey:countryCellIndexPath];
    rowNumberForSection++;
    
    [self.tableView reloadData];
}

#pragma mark Properties

- (NSMutableDictionary *)cellForIndexPath {
    if (!_cellForIndexPath) {
        _cellForIndexPath = [NSMutableDictionary new];
    }
    return _cellForIndexPath;
}

- (CLGeocoder *)reverseGeocoder {
    if (!_reverseGeocoder) {
        _reverseGeocoder = [[CLGeocoder alloc] init];
    }    return _reverseGeocoder;
}

- (UIImage *)mediaImage {
    return self.mediaSnapshotView.image;
}

- (void)setMediaLocation:(CLLocation *)mediaLocation {
    if (mediaLocation &&
        ![self.mediaLocation isEqual:mediaLocation] &&
        (mediaLocation.coordinate.latitude || mediaLocation.coordinate.longitude)) {
        _mediaLocation = mediaLocation;
        [self.reverseGeocoder reverseGeocodeLocation:self.mediaLocation
                                   completionHandler:^(NSArray *placemarks, NSError *error) {
                                       CLPlacemark* placemark = [placemarks objectAtIndex:0];
                                       if (placemark) {
                                           self.cityInput.text = placemark.locality;
                                           self.zipcodeInput.text = placemark.postalCode;
                                           self.countryInput.text = placemark.country;
                                       }
                                   }];
        [self refreshForm];
    }
}

#pragma mark Actions

- (IBAction)uploadMedia:(id)sender {
    
    [SVProgressHUD show];
    
    LTConnectionManager* connectionManager = [LTConnectionManager sharedManager];
    connectionManager.delegate = self;
    [connectionManager addMediaWithTitle:self.titleInput.text
                                    text:self.textInput.text
                                 license:self.license
                                location:self.mediaLocation
                                assetURL:self.mediaAssetURL
                           responseBlock:^(LTMedia *media, NSError *error) {
                               if (media && !error) {
                                   [SVProgressHUD showSuccessWithStatus:_T(@"media_upload.confirm.title")];
                                   [self.navigationController popViewControllerAnimated:YES];
                               } else {
                                   [SVProgressHUD showErrorWithStatus:_T(@"error.upload_failed.title")];
                               }
                           }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return kSectionsNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSEnumerator* enumerator = [self.cellForIndexPath keyEnumerator];
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
    // Fix issue : http://stackoverflow.com/questions/18919459
    NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                       inSection:indexPath.section];
    UITableViewCell* cell = (UITableViewCell *)[self.cellForIndexPath objectForKey:currentIndexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UITableViewCell *)[self.cellForIndexPath objectForKey:indexPath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:kLicenseCellIndexPath]) {
        LTMediaLicenseChooserViewController* mediaLicenseChooserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LTMediaLicenseChooser"];
        mediaLicenseChooserVC.delegate = self;
        mediaLicenseChooserVC.currentLicense = self.license;
        [self.navigationController pushViewController:mediaLicenseChooserVC animated:YES];
    } else if ([indexPath isEqual:kLocationPickerCellIndexPath]){
        MediaLocalisationPickerViewController* mediaLocationPickerVC = [[MediaLocalisationPickerViewController alloc] init];
        mediaLocationPickerVC.delegate = self;
        if (self.mediaLocation) {
            mediaLocationPickerVC.location = self.mediaLocation;
        }
        [self.navigationController pushViewController:mediaLocationPickerVC animated:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.mediaSnapshotView.image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSURL* asserURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    // Get the assets library
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:asserURL resultBlock:^(ALAsset *asset) {
        
        if (asset) { 
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSMutableDictionary *imageMetadata = [NSMutableDictionary dictionaryWithDictionary:[representation metadata]];
            CLLocation* mediaLocation = [imageMetadata location];
            self.mediaLocation = mediaLocation;
            
        }
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIImageTextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewdDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MediaLicenseChooserDelegate

- (void)mediaLicenseViewController:(LTMediaLicenseChooserViewController*)controller
                  didChooseLicense:(LTLicense*)license
{
    if (license) {
        self.license = license;
        self.licenseCell.detailTextLabel.text = license.name;
    } else {
        self.license = nil;
        self.licenseCell.detailTextLabel.text = _T(@"media_upload_no_license_text");
    }
    
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MediaLocationPickerDelegate

- (void)mediaLocationPicker:(MediaLocalisationPickerViewController *)mediaLocationPicker didPickLocation:(CLLocation *)location
{
    self.mediaLocation = location;
    [self refreshForm];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MediaLocationPickerDelegate 

- (void)uploadDeterminationDidUpdate:(CGFloat)determination {
    [SVProgressHUD showProgress:determination];
}

@end
