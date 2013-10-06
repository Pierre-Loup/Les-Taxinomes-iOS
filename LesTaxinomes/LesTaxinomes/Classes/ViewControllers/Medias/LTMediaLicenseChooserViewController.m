//
//  MediaLicenseChooserViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Personnel on 27/05/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import "LTMediaLicenseChooserViewController.h"

#import "LTLicense+Business.h"
#import "LTLicenseCell.h"
#import "LTConnectionManager.h"

#define kLicenceCellIdentifier @"LTLicenseCell"

@interface LTMediaLicenseChooserViewController ()

@property (nonatomic, strong) NSArray* licenses;
@property (nonatomic, strong) NSIndexPath * currentLicenseIndexPath;

@end

@implementation LTMediaLicenseChooserViewController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.licenses = [LTLicense MR_findAllSortedBy:@"identifier"
                                        ascending:YES];
    if (self.licenses.count == 0) {
        [SVProgressHUD show];
        [[LTConnectionManager sharedManager] getLicensesWithResponseBlock:^(NSArray *licenses, NSError *error) {
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier"
                                                                             ascending:YES];
            self.licenses = [licenses sortedArrayUsingDescriptors:@[sortDescriptor]];
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        }];
    }
    
    self.currentLicenseIndexPath = [self indexPathForCurrentLicense];

}

#pragma mark Tools

- (NSIndexPath *)indexPathForCurrentLicense {
    if (self.licenses == nil || self.licenses.count == 0) {
        return nil;
    }
    
    for (LTLicense *license in self.licenses) {
        if (license.identifier.intValue == self.currentLicense.identifier.intValue) {
            return [NSIndexPath indexPathForRow:[self.licenses indexOfObject:license]
                                      inSection:0];
        }
    }
    
    return nil;
}

#pragma mark UITableViewDatabase

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.licenses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LTLicenseCell* cell = [tableView dequeueReusableCellWithIdentifier:kLicenceCellIdentifier];
    
    if (indexPath.row < [self.licenses count]
        && [[self.licenses objectAtIndex:indexPath.row] isKindOfClass:[LTLicense class]]) {
        LTLicense *license = [self.licenses objectAtIndex:indexPath.row];
        cell.licenseNameTextLabel.text = license.name;
        cell.licenseDetailTextLabel.text = license.desc;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([indexPath isEqual:self.currentLicenseIndexPath]) {
        cell.accessoryView = nil;
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * currentLicenseIndexPath = [self indexPathForCurrentLicense];
    if ([indexPath isEqual:currentLicenseIndexPath]) {
        self.currentLicense = nil;
        self.currentLicenseIndexPath = nil;
    } else {
        self.currentLicense = [self.licenses objectAtIndex:indexPath.row];
        self.currentLicenseIndexPath = indexPath;
    }
    
    [self.delegate mediaLicenseViewController:self
                             didChooseLicense:self.currentLicense];
    
    [tableView reloadData];
}

@end
