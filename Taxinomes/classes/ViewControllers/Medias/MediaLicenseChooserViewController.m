//
//  MediaLicenseViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/05/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MediaLicenseViewController.h"

@interface MediaLicenseViewController (Private)

@end

@implementation MediaLicenseViewController
@synthesize tableView = tableView_;
@synthesize licenses = licenses_;
@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDatabase

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [licenses_ count] 
        && [[licenses_ objectAtIndex:indexPath.row] isKindOfClass:[License class]]
        && [delegate_ respondsToSelector:@selector(<#selector#>)]) {
    }
}

@end
