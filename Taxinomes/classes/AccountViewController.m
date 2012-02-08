//
//  AccountViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "AccountViewController.h"
#import "ConnectionManager.h"

@implementation AccountViewController
@synthesize tableView = _tableView;
@synthesize gridCell = _gridCell;

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
    ConnectionManager *connectionManager = [ConnectionManager sharedConnectionManager];
    [connectionManager authWithLogin:@"pierre" password:@"crLu2Vzi"];
}

- (IBAction)cameraButtonAction:(id) sender{
    NSLog(@"%@",@"cameraButtonActionn");
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
