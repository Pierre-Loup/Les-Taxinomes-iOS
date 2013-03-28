//
//  MediaUploadFormViewController.m
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

#import "LTConnectionManager.h"
#import "MapCell.h"
#import "MediaUploadFormViewController.h"
#import "NSData+Base64.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "SingleLineInputCell.h"
#import "UIImageView+PhotoFrame.h"

// MODEL
#import "License+Business.h"

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

#define kSectionsNumber 4

@interface MediaUploadFormViewController ()<UITableViewDelegate,
                                            UITableViewDataSource,
                                            UITextFieldDelegate,
                                            UITextViewDelegate,
                                            UIImagePickerControllerDelegate,
                                            MediaLicenseChooserDelegate,
                                            MediaLocationPickerDelegate,
                                            LTConnectionManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableViewCell* textCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* licenseCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* publishCell;
@property (nonatomic, strong) IBOutlet UIImageView* mediaSnapshotView;
@property (nonatomic, strong) UITextField* titleInput;
@property (nonatomic, strong) IBOutlet UITextView* textInput;
@property (nonatomic, strong) UITextField* cityInput;
@property (nonatomic, strong) UITextField* zipcodeInput;
@property (nonatomic, strong) UITextField* countryInput;
@property (nonatomic, strong) IBOutlet UIGlossyButton* shareButton;
@property (nonatomic, strong) IBOutlet UISwitch* publishSwitch;

@property (nonatomic, strong) NSURL* mediaAssetURL;
@property (nonatomic, strong) License* license;
@property (nonatomic, strong) CLLocation* mediaLocation;
@property (unsafe_unretained, nonatomic, readonly) NSArray* rowsInSection;
@property (nonatomic, readonly) NSMutableDictionary* cellForIndexPath;
@property (nonatomic, readonly) CLGeocoder* reverseGeocoder;

- (IBAction)uploadMedia:(id)sender;
- (void)refreshForm;
@end

@implementation MediaUploadFormViewController
@synthesize cellForIndexPath = _cellForIndexPath;
@synthesize reverseGeocoder = _reverseGeocoder;

#pragma mark - Super methodes override

- (id)initWithAssetURL:(NSURL*)assetURL
{
    self = [self initWithNibName:@"MediaUploadFormViewController" bundle:nil];
    if (self) {
        self.mediaAssetURL = assetURL;
        _rowsInSection = @[[NSNumber numberWithInt:1],
                          [NSNumber numberWithInt:1],
                          [NSNumber numberWithInt:1],
                          [NSNumber numberWithInt:1],
                          [NSNumber numberWithInt:1]];
        _license = [License defaultLicense];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load textCell, licenseCell and
    [[NSBundle mainBundle] loadNibNamed:@"MediaUploadFormCells" owner:self options:nil];
    self.navigationItem.title = _T(@"media_upload_view_title");
    
    self.shareButton.tintColor = kSecondaryColor;
    self.shareButton.buttonCornerRadius = 10.0;
    [self.shareButton setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
    
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
    
    
    if (self.license) {
        self.licenseCell.detailTextLabel.text = self.license.name;
    } else {
        self.licenseCell.detailTextLabel.text = _T(@"media_upload_no_license_text");
    }
    
    [self refreshForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.hud hide:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.textCell = nil;
    self.licenseCell = nil;
    self.publishCell = nil;
    self.mediaSnapshotView = nil;
    self.titleInput = nil;
    self.textInput = nil;
    self.cityInput = nil;
    self.zipcodeInput = nil;
    self.countryInput = nil;
    self.shareButton = nil;
    self.publishSwitch = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)refreshForm {
    [self.cellForIndexPath removeAllObjects];
    if (self.textCell)
        [self.cellForIndexPath setObject:self.textCell forKey:kTexteCellIndexPath];
    if (self.licenseCell) {
        [self.cellForIndexPath setObject:self.licenseCell forKey:kLicenseCellIndexPath];
    }
    
    // Title cell
    SingleLineInputCell* titleCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!titleCell) {
        titleCell = [SingleLineInputCell singleLineInputCell];
    }
    [titleCell setTitle:_T(@"common.title")];
    self.titleInput = titleCell.input;
    [self.titleInput setDelegate:self];
    [self.cellForIndexPath setObject:titleCell forKey:kTitleCellIndexPath];
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
        MapCell* mapCell = [self.tableView dequeueReusableCellWithIdentifier:[MapCell reuseIdentifier]];
        if (!mapCell) {
            mapCell = [MapCell mapCell];
        }
        MKPlacemark* annotation = [[MKPlacemark alloc] initWithCoordinate:self.mediaLocation.coordinate addressDictionary:nil];
        [mapCell.mapView removeAnnotations:mapCell.mapView.annotations];
        [mapCell.mapView addAnnotation:annotation];
        [mapCell.mapView setRegion:MKCoordinateRegionMake(self.mediaLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1))];
        NSIndexPath* mapCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
        [self.cellForIndexPath setObject:mapCell forKey:mapCellIndexPath];
        rowNumberForSection++;
    }
    
    // City cell
    SingleLineInputCell* cityCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!cityCell) {
        cityCell = [SingleLineInputCell singleLineInputCell];
    }
    [cityCell setTitle:_T(@"common.city")];
    self.cityInput = cityCell.input;
    [cityCell.input setDelegate:self];
    NSIndexPath* cityCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [self.cellForIndexPath setObject:cityCell forKey:cityCellIndexPath];
    rowNumberForSection++;
    
    // Zipcode cell
    SingleLineInputCell* zipcodeCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!zipcodeCell ) {
        zipcodeCell  = [SingleLineInputCell singleLineInputCell];
    }
    [zipcodeCell setTitle:_T(@"common.zipcode")];
    self.zipcodeInput = zipcodeCell.input;
    [zipcodeCell.input setDelegate:self];
    
    NSIndexPath* zipcodeCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [self.cellForIndexPath setObject:zipcodeCell forKey:zipcodeCellIndexPath];
    rowNumberForSection++;
    
    // Country cell
    SingleLineInputCell* countryCell = [self.tableView dequeueReusableCellWithIdentifier:[SingleLineInputCell reuseIdentifier]];
    if (!countryCell) {
        countryCell = [SingleLineInputCell singleLineInputCell];
    }
    [countryCell setTitle:_T(@"common.country")];
    self.countryInput = countryCell.input;
    [countryCell.input setDelegate:self];
    
    NSIndexPath* countryCellIndexPath = [NSIndexPath indexPathForRow:rowNumberForSection inSection:kLocationSection];
    [self.cellForIndexPath setObject:countryCell forKey:countryCellIndexPath];
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
    
    [self showDefaultHud];
    
    LTConnectionManager* connectionManager = [LTConnectionManager sharedConnectionManager];
    connectionManager.delegate = self;
    [connectionManager addMediaWithTitle:self.titleInput.text
                                    text:self.textInput.text
                                 license:self.license
                                location:self.mediaLocation
                                assetURL:self.mediaAssetURL
                           responseBlock:^(Media *media, NSError *error) {
                               if (media && !error) {
                                   [self showConfirmHudWithText:_T(@"media_upload.confirm.title")];
                                   [self.navigationController popViewControllerAnimated:YES];
                               }
                               else if ([error shouldBeDisplayed]) {
                                   [self.hud hide:NO];
                                   [UIAlertView showWithError:error];
                               }
                               else {
                                   [self showErrorHudWithText:_T(@"error.upload_failed.title")];
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
    UITableViewCell* cell = (UITableViewCell *)[self.cellForIndexPath objectForKey:indexPath];
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
        MediaLicenseChooserViewController* mediaLicenseChooserVC = [[MediaLicenseChooserViewController alloc] init];
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
    [self dismissModalViewControllerAnimated:YES];
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

- (void)didChooseLicense:(License *)license
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
    if (self.hud.mode != MBProgressHUDModeDeterminate) {
        self.hud.mode = MBProgressHUDModeDeterminate;
    }
    self.hud.progress = determination;
}

@end
