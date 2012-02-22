//
//  AccountViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "AccountViewController.h"
#import "MediaUploadFormViewController.h"

@implementation AccountViewController
@synthesize tableView = _tableView;
@synthesize avatarView = _avatarView;
@synthesize nameLabel = _nameLabel;
@synthesize signinSubview = _signinSubview;
@synthesize loadingSubview = _loadingSubview;
@synthesize userTextField = _userTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize accountMenuLabels = _accountMenuLabels;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.signinSubview = nil;
    self.loadingSubview = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonAction:)];
        [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
        [rightButton release];
    }
    
    // Setup sign in subview, not visible because out of the screen (bottom)
    [[NSBundle mainBundle] loadNibNamed:@"SigninSubview" owner:self options:nil];
    CGRect frame = self.signinSubview.frame;	
    frame.origin.y = frame.size.height;
	self.signinSubview.frame = frame;
    [self.view addSubview: self.signinSubview];
    
    // Setup loading subview, not visible because out of the screen (top)
    [[NSBundle mainBundle] loadNibNamed:@"LoadingSubview" owner:self options:nil];
    frame = self.loadingSubview.frame;
	frame.origin.y = -frame.size.height;
	self.loadingSubview.frame = frame;
    [self.view addSubview: self.loadingSubview];
    
    self.accountMenuLabels = [NSArray arrayWithObjects:@"Publier un média", @"Média publiés", nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    if(connectionManager.authStatus != AUTHENTICATED){
        [self setViewComponentsHidden:YES];
        [self setSigninSubviewHidden:NO animated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self dismissSigninSubview:self];
    [self setLoadingSubviewHidden:YES animated:animated];
    [self.view becomeFirstResponder];
}

- (void)viewDidUnload
{
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

- (IBAction)forgotenPasswordButtonAction:(id) sender{
    NSLog(@"%@",@"forgotenPasswordButtonAction");
}

- (IBAction)submitSigninButtonAction:(id) sender{
    NSLog(@"%@",@"submitSigninButtonAction");
    [self setSigninSubviewHidden:YES animated:NO];
    [self setLoadingSubviewHidden:NO animated:NO];
    [self performSelectorInBackground:@selector(submitAuthentication:) withObject:self];
}

- (IBAction)signupButtonAction:(id)sender {
    NSString *url = [NSString stringWithString:@"http://taxinomes.arscenic.org/spip.php?page=inscription"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)cameraButtonAction:(id) sender{
    MediaManager *mediaManager = [MediaManager sharedMediaManager];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = mediaManager;    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    imagePicker.allowsEditing = NO;
    
    [self presentModalViewController:imagePicker animated:YES];
    mediaManager.delegate = self;
    [mediaManager takePicture];
    [imagePicker retain];
}

- (IBAction)presentSigninSubview:(id)sender {    
    [self setSigninSubviewHidden:NO animated:YES];
}

- (IBAction)dismissSigninSubview:(id)sender {    
    [self setSigninSubviewHidden:YES animated:YES];
}

- (IBAction)presentLoadingSubview:(id)sender {    
    [self setLoadingSubviewHidden:NO animated:YES];
}

- (IBAction)dismissLoadingSubview:(id)sender {    
    [self setLoadingSubviewHidden:YES animated:YES];
}

- (IBAction)dismissKeyboardSubview:(id)sender {    
    [sender becomeFirstResponder];
}

- (void)submitAuthentication:(id)sender {
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    connectionManager.delegate = self;
    //[connectionManager authWithLogin:@"pierre" password:@"crLu2Vzi"];
    [connectionManager authWithLogin:self.userTextField.text password:self.passwordTextField.text];
}

#pragma mark - Table view components management

- (void) setLoadingSubviewHidden:(BOOL) hidden animated:(BOOL) animated {
    CGRect frame = self.loadingSubview.frame;
    frame.size.height = self.view.frame.size.height;
    frame.origin.y = hidden?self.view.frame.size.height:self.view.frame.origin.y;
    
    if(animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.loadingSubview.frame = frame;
        }];
    } else {
        self.loadingSubview.frame = frame;
    }
}

- (void) setSigninSubviewHidden:(BOOL) hidden animated:(BOOL) animated {
    CGRect frame = self.signinSubview.frame;
    frame.size.height = self.view.frame.size.height;
    frame.origin.y = hidden?self.view.frame.size.height:self.view.frame.origin.y;
    
    if(animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.signinSubview.frame = frame;
        }];
    } else {
        self.signinSubview.frame = frame;
    }
}

- (void) setViewComponentsHidden:(BOOL)hidden {
    self.avatarView.hidden = hidden;
    self.tableView.hidden = hidden;
    self.nameLabel.hidden = hidden;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"Rows : %d",[articles count]);
    if(section == 0)
        return [self.accountMenuLabels count];
    else
        return 1;
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
        cell.textLabel.text = [self.accountMenuLabels objectAtIndex:[indexPath row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @"Se déconnecter";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] == 0 && [indexPath section] == 0) {
        MediaUploadFormViewController *mediaUploadFormViewController = [[MediaUploadFormViewController alloc] initWithNibName:@"MediaUploadFormView" bundle:nil];
        //mediaUploadFormViewController.media = [UIImage imageNamed:@"Icon.png"];
        [self.navigationController pushViewController:mediaUploadFormViewController animated:YES];
    } else if ([indexPath row] == 0 && [indexPath section] == 1) {
        ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
        connectionManager.authStatus = UNAUTHENTICATED;
        [self setViewComponentsHidden:YES];
        [self setSigninSubviewHidden:NO animated:YES];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - MediaManagerDelegate

- (void)didFinishTakingPicture{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ConnectionManagerDelegate

- (void)didAuthenticate {
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    Author *author = connectionManager.author;
    self.avatarView.image = author.avatar;
    self.nameLabel.text = author.name;
    [self setViewComponentsHidden:NO];
    [self setLoadingSubviewHidden:YES animated:YES];
}

- (void)didFailToAuthenticate:(NSString *)message {
    [self setLoadingSubviewHidden:YES animated:NO];
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Echec de l'authentification" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self setSigninSubviewHidden:NO animated:NO];

}

@end
