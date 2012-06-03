//
//  MediaLicenseChooserViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/05/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
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

#import "MediaLicenseChooserViewController.h"

#define kLicenceCellIdentifier @"LicenceCell"

@interface MediaLicenseChooserViewController (Private)
// Tools
- (NSIndexPath *)indexPathForCurrentLicense;
// Actions
- (IBAction)oKButtonButtonPressed:(UIBarButtonItem *)sender;
@end

@implementation MediaLicenseChooserViewController
@synthesize tableView = tableView_;
@synthesize licenses = licenses_;
@synthesize delegate = delegate_;
@synthesize currentLicense = currentLicense_;

- (id)init
{
    self = [super init];
    if (self) {
        [self initWithNibName:NSStringFromClass([MediaLicenseChooserViewController class]) bundle:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        licenses_ = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [licenses_ removeAllObjects];
    [licenses_ addObjectsFromArray:[License allLicenses]];
    currentLicenseIndexPath_ = [[self indexPathForCurrentLicense] retain];
    
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common_OK") style:UIBarButtonItemStyleDone target:self action:@selector(oKButtonButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:NO];

}

- (void)viewDidUnload
{
    self.tableView = nil;
    [currentLicenseIndexPath_ release];
    currentLicenseIndexPath_ = nil;
    [rightBarButton_ release];
    rightBarButton_ = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [licenses_ dealloc];
    [currentLicense_ release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Tools

- (NSIndexPath *)indexPathForCurrentLicense {
    if (licenses_ == nil) {
        return nil;
    }
    
    for (License * license in licenses_) {
        if (license.identifier.intValue == currentLicense_.identifier.intValue) {
            return [NSIndexPath indexPathForRow:[licenses_ indexOfObject:license]inSection:0];
        }
    }
    
    return nil;
}

#pragma mark Actions

- (IBAction)oKButtonButtonPressed:(UIBarButtonItem *)sender {
    if (currentLicenseIndexPath_.row < [licenses_ count] 
        && [[licenses_ objectAtIndex:currentLicenseIndexPath_.row] isKindOfClass:[License class]]
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kLicenceCellIdentifier] autorelease];
    }
    
    if (indexPath.row < [licenses_ count] 
        && [[licenses_ objectAtIndex:indexPath.row] isKindOfClass:[License class]]) {
        License * license = [licenses_ objectAtIndex:indexPath.row];
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
        [currentLicense_ release];
        currentLicense_ = nil;
        [currentLicenseIndexPath_ release];
        currentLicenseIndexPath_ = nil;
    } else {
        [currentLicense_ release];
        currentLicense_ = [[licenses_ objectAtIndex:indexPath.row] retain];
        [currentLicenseIndexPath_ release];
        currentLicenseIndexPath_ = [indexPath retain];
    }
    [tableView reloadData];
}

@end
