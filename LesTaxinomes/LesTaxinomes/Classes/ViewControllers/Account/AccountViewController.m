//
//  AccountViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribusigninSubviewte it and/or modify
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

#import "AccountViewController.h"
#import "MediaUploadFormViewController.h"
#import "LTMediasRootViewController.h"
#import "UIImageView+AFNetworking.h"
#import "LTTitleView.h"

@interface AccountViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LTAuthenticationSheetDelegate> {
    
    NSArray* accountMenuLabels_;
    LTAuthor *authenticatedUser_;
    
    UIBarButtonItem* rightBarButton_;
}
@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet LTTitleView* userNameView;
@property (strong, nonatomic) IBOutlet UIImageView* avatarView;

- (void)commonInit;
- (void)displayAuthenticationSheetAnimated:(BOOL)animated;
- (IBAction)logoutButtonPressed:(id)sender;
@end

@implementation AccountViewController
@synthesize tableView = tableView_;
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
    accountMenuLabels_ = @[_T(@"account_my_medias")];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setHidden:YES];
    [avatarView_ setImageWithURL:[NSURL URLWithString:authenticatedUser_.avatarURL]
                placeholderImage:[UIImage imageNamed:@"default_avatar_medium"]];
    [self.view addSubview:avatarView_];
    [self switchToUnauthenticatedModeAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    if (!cm.authenticatedUser) {
        [self showDefaultHud];
        [cm authWithLogin:nil
                 password:nil
            responseBlock:^(LTAuthor *authenticatedUser, NSError *error) {
                [self.hud hide:YES];
                if (authenticatedUser) {
                    [self switchToAuthenticatedModeAnimated:YES];
                } else {
                    [self switchToUnauthenticatedModeAnimated:YES];
                }
            }];
    } else {
        [self switchToAuthenticatedModeAnimated:NO];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


#pragma mark - IBAction

- (void)displayAuthenticationSheetAnimated:(BOOL)animated {
    AuthenticationSheetViewController * authenticationSheetViewController = [[AuthenticationSheetViewController alloc] initWithNibName:@"AuthenticationSheetViewController" bundle:nil];
    authenticationSheetViewController.delegate = self;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationSheetViewController];
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:animated];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"accountMenuCell"];
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
        LTMediasRootViewController * mediasListViewController = [[LTMediasRootViewController alloc] initWithNibName:@"MediasListViewController" bundle:nil];
        mediasListViewController.currentUser = [LTConnectionManager sharedConnectionManager].authenticatedUser;
        [self.navigationController pushViewController:mediasListViewController animated:YES];
        mediasListViewController.title = _T(@"account_my_medias");
    }
}

#pragma mark - Action

- (IBAction)logoutButtonPressed:(id)sender {
    LTConnectionManager *connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager unAuthenticate];
    [self switchToUnauthenticatedModeAnimated:YES];
}

- (IBAction)signInButtonPressed:(id)sender {
    [self displayAuthenticationSheetAnimated:YES];
    
}

- (void)switchToAuthenticatedModeAnimated:(BOOL)animated {
    if ([LTConnectionManager sharedConnectionManager].authenticatedUser) {
        LTAuthor *authUser = [LTConnectionManager sharedConnectionManager].authenticatedUser;
        self.userNameView.title = authUser.name;
        [avatarView_ setImageWithURL:[NSURL URLWithString:authUser.avatarURL]
                    placeholderImage:[UIImage imageNamed:@"default_avatar_medium"]];
    }
    [avatarView_ setHidden:NO];
    [self.tableView setHidden:NO];
    rightBarButton_ = nil;
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:_T(@"common.logout") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:YES];
    
    [self dismissModalViewControllerAnimated:animated];
}

- (void)switchToUnauthenticatedModeAnimated:(BOOL)animated {
    rightBarButton_ = nil;
    rightBarButton_ = [[UIBarButtonItem alloc] initWithTitle:_T(@"common.signin") style:UIBarButtonItemStylePlain target:self action:@selector(signInButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton_ animated:YES];
    [self.tableView setHidden:YES];
    [avatarView_ setHidden:YES];
}

#pragma mark - LTAuthenticationSheetDelegate

- (void)authenticationDidFinishWithSuccess:(BOOL)success {
    LTAuthor *authenticatedUser = [LTConnectionManager sharedConnectionManager].authenticatedUser;
    if (success && authenticatedUser) {
        self.userNameView.title = authenticatedUser.name;
        [self.avatarView setImageWithURL:[NSURL URLWithString:authenticatedUser.avatarURL]
                        placeholderImage:[UIImage imageNamed:@"default_avatar_medium"]];
        [self switchToAuthenticatedModeAnimated:YES];
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
