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

#import "MediaLicenseChooserViewController.h"

#import "LTLicense+Business.h"

#define kLicenceCellIdentifier @"LicenceCell"

@interface MediaLicenseChooserViewController (Private)
// Tools
- (NSIndexPath *)indexPathForCurrentLicense;
// Actions
- (IBAction)oKButtonButtonPressed:(UIBarButtonItem *)sender;
@end

@implementation MediaLicenseChooserViewController
@synthesize delegate = delegate_;
@synthesize currentLicense = currentLicense_;

- (id)init
{
    self = [super init];
    if (self) {
        if (!(self = [self initWithNibName:NSStringFromClass([MediaLicenseChooserViewController class]) bundle:nil])) return nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        licenses_ = [LTLicense findAll];
        currentLicenseIndexPath_ = [self indexPathForCurrentLicense];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:_T(@"common.ok") style:UIBarButtonItemStylePlain target:self action:@selector(oKButtonButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:NO];

}

- (void)viewDidUnload
{
    rightBarButton_ = nil;
    [super viewDidUnload];
}


#pragma mark Tools

- (NSIndexPath *)indexPathForCurrentLicense {
    if (licenses_ == nil) {
        return nil;
    }
    
    for (LTLicense *license in licenses_) {
        if (license.identifier.intValue == currentLicense_.identifier.intValue) {
            return [NSIndexPath indexPathForRow:[licenses_ indexOfObject:license]inSection:0];
        }
    }
    
    return nil;
}

#pragma mark Actions

- (IBAction)oKButtonButtonPressed:(UIBarButtonItem *)sender {
    if (currentLicenseIndexPath_.row < [licenses_ count] 
        && [[licenses_ objectAtIndex:currentLicenseIndexPath_.row] isKindOfClass:[LTLicense class]]
        && [delegate_ respondsToSelector:@selector(didChooseLicense:)]) {
        [delegate_ didChooseLicense:currentLicense_];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UITableViewDatabase

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [licenses_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kLicenceCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kLicenceCellIdentifier];
    }
    
    if (indexPath.row < [licenses_ count] 
        && [[licenses_ objectAtIndex:indexPath.row] isKindOfClass:[LTLicense class]]) {
        LTLicense *license = [licenses_ objectAtIndex:indexPath.row];
        cell.textLabel.text = license.name;
        cell.detailTextLabel.text = license.desc;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([indexPath isEqual:currentLicenseIndexPath_]) {
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
        currentLicense_ = nil;
        currentLicenseIndexPath_ = nil;
    } else {
        currentLicense_ = [licenses_ objectAtIndex:indexPath.row];
        currentLicenseIndexPath_ = indexPath;
    }
    [tableView reloadData];
}

@end
