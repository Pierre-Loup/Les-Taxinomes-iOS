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
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "AccountViewController.h"
#import "ConnectionManager.h"

@implementation AccountViewController
@synthesize tableView = _tableView;
@synthesize gridCell = _gridCell;
@synthesize accountSigninSubview = _accountSigninSubview;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Connexion" style:UIBarButtonItemStylePlain target:self action:@selector(signinButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    [leftButton release];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonAction:)];
        [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
        [rightButton release];
    }
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

-(IBAction)signinButtonAction:(id)sender{
    NSLog(@"%@",@"signinButtonAction");
    [[NSBundle mainBundle] loadNibNamed:@"AccountSigninSubview" owner:self options:nil];
    [self.view addSubview: self.accountSigninSubview];    
}
- (IBAction)forgotenPasswordButtonAction:(id) sender{
    NSLog(@"%@",@"forgotenPasswordButtonAction");
}
- (IBAction)submitSigninButtonAction:(id) sender{
    NSLog(@"%@",@"submitSigninButtonAction");
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    [connectionManager authWithLogin:@"pierre" password:@"crLu2Vzi"];
}
- (IBAction)signupButtonAction:(id) sender{
    NSLog(@"%@",@"signupButtonAction");
}
- (IBAction)cameraButtonAction:(id) sender{
    NSLog(@"%@",@"cameraButtonAction");
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
    //NSLog(@"Rows : %d",[articles count]);
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *gridCellIdentifier = @"gridCell";
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:gridCellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"GridCellView" owner:self options:nil];
        cell = self.gridCell;
        self.gridCell = nil;
    }
    
    cell.opaque = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
}

@end
