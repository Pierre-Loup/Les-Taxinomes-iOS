//
//  AccountViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
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
#import "MediasListViewController.h"
#import "UIImageView+AFNetworking.h"

@interface AccountViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LTConnectionManagerAuthDelegate> {
    
    NSArray* accountMenuLabels_;
    Author * authenticatedUser_;
    
    UIBarButtonItem* rightBarButton_;
}
@property (retain, nonatomic) IBOutlet UITableView* tableView;
@property (retain, nonatomic) IBOutlet UIImageView* defaultAvatarView;
@property (retain, nonatomic) IBOutlet UILabel* userNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView* avatarView;

- (void)commonInit;
- (void)displayAuthenticationSheetAnimated:(BOOL)animated;
- (IBAction)logoutButtonPressed:(id)sender;
- (void)switchToAuthenticatedMode:(BOOL)animated;
- (void)switchToUnauthenticatedMode:(BOOL)animated;
@end

@implementation AccountViewController
@synthesize tableView = tableView_;
@synthesize defaultAvatarView = defaultAvatarView_;
@synthesize userNameLabel = userNameLabel_;
@synthesize avatarView = avatarView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    accountMenuLabels_ = [[NSArray arrayWithObjects:TRANSLATE(@"account_uploas_media"), TRANSLATE(@"account_my_medias"), nil] retain];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
    [authenticatedUser_ release];
    [rightBarButton_ release];
    [accountMenuLabels_ release];
    [avatarView_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    bgView_.light = NO;
    [self.tableView setHidden:YES];
    [avatarView_ setImageWithURL:[NSURL URLWithString:authenticatedUser_.avatarURL]
                placeholderImage:[UIImage imageNamed:@"default_avatar_medium"]];
    avatarView_.frame = defaultAvatarView_.frame;
    [self.view addSubview:avatarView_];
    
    [self switchToUnauthenticatedMode:YES];
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    if (!cm.authenticatedUser) {
        [cm checkUserAuthStatusWithDelegate:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    if (cm.authenticatedUser) {
        [authenticatedUser_ release];
        authenticatedUser_ = [cm.authenticatedUser retain];
        [self switchToAuthenticatedMode:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
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
    authenticationSheetViewController.authDelegate = self;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationSheetViewController];
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
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
    if(section == 0)
        return [accountMenuLabels_ count];
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
        cell.textLabel.text = [accountMenuLabels_ objectAtIndex:[indexPath row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        MediaUploadFormViewController * mediaUploadFormViewController = [[MediaUploadFormViewController alloc] initWithNibName:@"MediaUploadFormViewController" bundle:nil];
        [self.navigationController pushViewController:mediaUploadFormViewController animated:YES];
        [mediaUploadFormViewController release];
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        MediasListViewController * mediasListViewController = [[MediasListViewController alloc] initWithNibName:@"MediasListViewController" bundle:nil];
        mediasListViewController.currentUser = authenticatedUser_;
        [self.navigationController pushViewController:mediasListViewController animated:YES];
        mediasListViewController.title = TRANSLATE(@"account_my_medias");
        [mediasListViewController release];
    }
}

#pragma mark - Action

- (IBAction)logoutButtonPressed:(id)sender {
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager unAuthenticate];
    [self switchToUnauthenticatedMode:YES];
}

- (IBAction)signInButtonPressed:(id)sender {
    [self displayAuthenticationSheetAnimated:YES];
    
}

- (void)switchToAuthenticatedMode:(BOOL)animated {
    if (authenticatedUser_) {
        self.userNameLabel.text = authenticatedUser_.name;
        [avatarView_ setImageWithURL:[NSURL URLWithString:authenticatedUser_.avatarURL]
                    placeholderImage:[UIImage imageNamed:@"default_avatar_medium"]];
    }
    [avatarView_ setHidden:NO];
    [self.tableView setHidden:NO];
    [rightBarButton_ release];
    rightBarButton_ = nil;
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common.logout") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:YES];
    
    [self dismissModalViewControllerAnimated:animated];
}

- (void)switchToUnauthenticatedMode:(BOOL)animated {
    [rightBarButton_ release];
    rightBarButton_ = nil;
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:TRANSLATE(@"common.signin") style:UIBarButtonItemStylePlain target:self action:@selector(signInButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:YES];
    [self.tableView setHidden:YES];
    [avatarView_ setHidden:YES];
}

#pragma mark - LTConnectionManagerAuthDelegate

- (void)authDidEndWithLogin:(NSString *)login
                   password:(NSString *)password
                     author:(Author *)author
                      error:(NSError *)error {
    
    [self hideLoader];
    if ([self.modalViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)self.modalViewController;
        if ([navigationController.topViewController isKindOfClass:[AuthenticationSheetViewController class]]) {
            [(AuthenticationSheetViewController *)navigationController.topViewController hideLoader];
        }
    }
    if (author) {
        [authenticatedUser_ release];
        authenticatedUser_ = [author retain];
        self.userNameLabel.text = authenticatedUser_.name;
        [avatarView_ setImageWithURL:[NSURL URLWithString:authenticatedUser_.avatarURL]
                    placeholderImage:[UIImage imageNamed:@"default_avatar_medium"]];
        [self switchToAuthenticatedMode:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self switchToUnauthenticatedMode:YES];
        [self displayAuthenticationSheetAnimated:YES];
    }
    
    if (error && login && password) {
        UIAlertView *authFailedAlert = nil;
        if ([error.domain isEqualToString:kNetworkRequestErrorDomain]) {
            authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_network_unreachable_title") message:TRANSLATE(@"alert_network_unreachable_text") delegate:self cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
        } else if ([error.domain isEqualToString:kLTAuthenticationFailedError]) {
            authFailedAlert = [[UIAlertView alloc] initWithTitle:TRANSLATE(@"alert_auth_failed_title") message:TRANSLATE(@"alert_auth_failed_text") delegate:self cancelButtonTitle:TRANSLATE(@"common.ok") otherButtonTitles:nil];
        }
        
        [authFailedAlert show];
        [authFailedAlert release];
    }
}

@end
