//
//  MediaFullSizeViewContoller.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 24/01/12.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import "MediaFullSizeViewContoller.h"

@implementation MediaFullSizeViewContoller
@synthesize scrollView = scrollView_;
@synthesize media = media_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mediaURL:(NSString *)mediaURL {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayLoader];
    
    self.title = media_.title;
    
    mediaView_ = [[TCImageView alloc] initWithURL:@"" placeholderView:nil];
    mediaView_.delegate = self;
    mediaView_.downloadProgressDelegate = self;
    [scrollView_ addSubview:mediaView_];
    
    LTConnectionManager * connectionManager = [LTConnectionManager sharedConnectionManager];
    [connectionManager getMediaLargeURLWithId:media_.identifier delegate:self];
}


- (void)viewDidUnload {
    [mediaView_ release];
    mediaView_ = nil;
    [scrollView_ release];
    scrollView_ = nil;
    
    self.media = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    /*
    
    */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return mediaView_;
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedMedia:(Media *)media {
    [self hideLoader];
    [self displayLoaderViewWithDetermination];
    [mediaView_ reloadWithUrl:media.mediaLargeURL];
}

- (void)didFailWithError:(NSError *)error {
#if TAXINOMES_DEV
    NSLog(@"%@",error.localizedDescription);
#endif
    [self hideLoader];
}

#pragma mark - TCImageViewDelegate

- (void)TCImageView:(TCImageView *) view FinisehdImage:(UIImage *)image {
    double maxWidth = self.view.frame.size.width;
    double maxHeight = self.view.frame.size.height;
    double mediaWidth;
    double mediaHeight;
    
    if((mediaView_.image.size.height/mediaView_.image.size.width) > (maxHeight/maxWidth) ){
        mediaWidth = maxWidth;
        mediaHeight = (maxWidth/mediaView_.image.size.width)*mediaView_.image.size.height;
        self.scrollView.maximumZoomScale = (mediaView_.image.size.width/maxWidth)*5;
    } else {
        mediaHeight = maxHeight;
        mediaWidth = (maxHeight/mediaView_.image.size.height)*mediaView_.image.size.width;
        self.scrollView.maximumZoomScale = (mediaView_.image.size.height/maxHeight)*5;
    }
    
    
    mediaView_.frame = CGRectMake(mediaView_.frame.origin.x, mediaView_.frame.origin.y, mediaWidth, mediaHeight);
    
    self.navigationController.tabBarItem.title = @"Media";
    self.scrollView.delegate = self;
    
    CGRect frame = CGRectMake(0, 0, maxWidth, maxHeight*2);
    self.scrollView.contentSize = frame.size;
    
    [self.scrollView addSubview:mediaView_];
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.bouncesZoom = NO;
    
    self.scrollView.contentSize = mediaView_.frame.size;
    
    view.downloadProgressDelegate = nil;
    [self hideLoader];
}

-(void) TCImageView:(TCImageView *) view failedWithError:(NSError *)error {
    view.downloadProgressDelegate = nil;
    [self hideLoader];
}

@end
