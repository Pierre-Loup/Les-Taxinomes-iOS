//
//  MediaFullSizeViewContoller.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 24/01/12.
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

#import "MediaFullSizeViewContoller.h"

@implementation MediaFullSizeViewContoller
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize mediaView = _mediaView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mediaURL:(NSString *)mediaURL {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *mediaView = [[UIImageView alloc] initWithFrame:self.view.frame];
        mediaView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaURL]]];
        self.mediaView = mediaView;
        [mediaView release];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int maxWidth = [UIScreen mainScreen].applicationFrame.size.width;
    int maxHeight = [UIScreen mainScreen].applicationFrame.size.height;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner setCenter:CGPointMake(maxWidth/2.0, maxHeight/2.0)]; 
    [self.scrollView addSubview:self.spinner];
    [self.spinner startAnimating];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    
    double maxWidth = self.view.frame.size.width;
    double maxHeight = self.view.frame.size.height;
    double mediaWidth = self.mediaView.image.size.width;
    double mediaHeight = self.mediaView.image.size.height;
    
    if((self.mediaView.image.size.height/self.mediaView.image.size.width) > (maxHeight/maxWidth) ){
        mediaWidth = maxWidth;
        mediaHeight = (maxWidth/self.mediaView.image.size.width)*self.mediaView.image.size.height;
        self.scrollView.maximumZoomScale = (self.mediaView.image.size.width/maxWidth)*2;
    } else {
        mediaHeight = maxHeight;
        mediaWidth = (maxHeight/self.mediaView.image.size.height)*self.mediaView.image.size.width;
        self.scrollView.maximumZoomScale = (self.mediaView.image.size.height/maxHeight)*2;
    }
    
    
    self.mediaView.frame = CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, mediaWidth, mediaHeight);
    
    self.navigationController.tabBarItem.title = @"Media";
    self.scrollView.delegate = self;
    
    CGRect frame = CGRectMake(0, 0, maxWidth, maxHeight*2);
    self.scrollView.contentSize = frame.size;
    
    [self.scrollView addSubview:self.mediaView];
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.bouncesZoom = NO;
    
    self.scrollView.contentSize = self.mediaView.frame.size;    
    [self.spinner stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.mediaView;
}

@end
