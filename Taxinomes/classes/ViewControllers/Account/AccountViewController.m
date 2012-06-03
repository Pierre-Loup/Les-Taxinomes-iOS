//
//  AccountViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribusigninSubviewte it and/or modify
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

#import "AccountViewController.h"
#import "MediaUploadFormViewController.h"

@interface AccountViewController (Private)
- (void)switchToAuthenticatedMode:(BOOL)animated;
- (void)switchToUnauthenticatedMode:(BOOL)animated;
@end

@implementation AccountViewController
@synthesize tableView = _tableView;
@synthesize defaultAvatarView = defaultAvatarView_;
@synthesize userNameLabel = userNameLabel_;
@synthesize accountMenuLabels = _accountMenuLabels;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        rightBarButton_ = nil;
        authenticatedUser_ = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
    [rightBarButton_ release];
    self.accountMenuLabels = nil;
    [avatarView_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountMenuLabels = [NSArray arrayWithObjects:@"Publier un média", @"Média publiés", nil];
    [self.view setHidden:YES];
    
    NSString * userAvatarURL = @"";
    LTConnectionManager * cm = [LTConnectionManager sharedConnectionManager];
    if ([cm isAuthenticated]) {
        userAvatarURL = authenticatedUser_.avatarURL;;
    }
    
    avatarView_ = [[TCImageView alloc] initWithURL:userAvatarURL placeholderView:nil];
    avatarView_.frame = defaultAvatarView_.frame;
    [self.view addSubview:avatarView_];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LTConnectionManager * cm = [LTConnectionManager sharedConnectionManager];
    if ([cm isAuthenticated]) {
        [self switchToAuthenticatedMode:NO];
    } else {
        [self switchToUnauthenticatedMode:NO];
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    [self.view becomeFirstResponder];
}

- (void)viewDidUnload
{
    [authenticatedUser_ release];
    authenticatedUser_ = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - IBAction

- (void)displayAuthenticationSheetAnimated:(BOOL)animated {
    AuthenticationSheetViewController * authenticationSheetViewController = [[AuthenticationSheetViewController alloc] initWithNibName:@"AuthenticationSheetViewController" bundle:nil];
    authenticationSheetViewController.delegate = self;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationSheetViewController];
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:navigationController animated:animated];
    [authenticationSheetViewController release];
    [navigationController release];
}

- (IBAction)dismissKeyboardSubview:(id)sender {    
    [sender becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"Rows : %d",[medias count]);
    if(section == 0)
        return [self.accountMenuLabels count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *gridCellIdentifier = @"accountMenuCell";
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"accountMenuCell"] autorelease];
    }
    if ([indexPath section] == 0) {
        cell.textLabel.text = [self.accountMenuLabels objectAtIndex:[indexPath row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] == 0 && [indexPath section] == 0) {
        MediaUploadFormViewController * mediaUploadFormViewController = [[MediaUploadFormViewController alloc] initWithNibName:@"MediaUploadFormViewController" bundle:nil];
        [self.navigationController pushViewController:mediaUploadFormViewController animated:YES];
        [mediaUploadFormViewController release];
    }
}

#pragma mark - MediaManagerDelegate

- (void)didFinishTakingPicture {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Action

- (IBAction)logoutButtonPressed:(id)sender {
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager unAuthenticate];
    [self switchToUnauthenticatedMode:YES];
}

- (IBAction)signInButtonPressed:(id)sender {
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager unAuthenticate];
    [self switchToUnauthenticatedMode:YES];
}

- (void)switchToAuthenticatedMode:(BOOL)animated {
    if (authenticatedUser_) {
        self.userNameLabel.text = authenticatedUser_.name;
        [avatarView_ reloadWithUrl:authenticatedUser_.avatarURL];
    }
    [self.view setHidden:NO];
    [rightBarButton_ release];
    rightBarButton_ = nil;
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common_logout") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:YES];
    
    [self dismissModalViewControllerAnimated:animated];
}

- (void)switchToUnauthenticatedMode:(BOOL)animated {
    [self displayAuthenticationSheetAnimated:animated];
    [rightBarButton_ release];
    rightBarButton_ = nil;
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common_signin") style:UIBarButtonItemStylePlain target:self action:@selector(signInButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:YES];
    [self.view setHidden:YES];
}

#pragma mark - LTConnectionManagerAuthDelegate

- (void)didAuthenticateWithAuthor:(Author *)author {
    [authenticatedUser_ release];
    authenticatedUser_ = [author retain];
    self.userNameLabel.text = authenticatedUser_.name;
    [avatarView_ reloadWithUrl:authenticatedUser_.avatarURL];
    [self switchToAuthenticatedMode:YES];
}

- (void)didFailToAuthenticateWithError:(NSError *)error {
    [self switchToUnauthenticatedMode:YES];
}

@end
