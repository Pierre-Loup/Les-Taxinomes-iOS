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
#import "UIImageView+AFNetworking.h"

@interface MediaFullSizeViewContoller () <UIScrollViewDelegate, LTConnectionManagerDelegate>
@property(retain,nonatomic) IBOutlet UIScrollView* scrollView;
@property(retain,nonatomic) IBOutlet UIImageView* mediaImageView;
- (void)cancelButtonTouched:(UIBarButtonItem *)cancelButton;
- (void)loadMediaImageAsych;
- (void)resizeImage;
@end

@implementation MediaFullSizeViewContoller
@synthesize scrollView = scrollView_;
@synthesize media = media_;
@synthesize mediaImageView = mediaImageView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mediaURL:(NSString *)mediaURL {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonTouched:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [cancelButton release];
    
    
    self.title = media_.title;
    if (media_.mediaLargeURL &&
        ![media_.mediaLargeURL isEqualToString:@""]) {
        [self loadMediaImageAsych];
    } else {
        [self displayLoader];
        LTConnectionManager * connectionManager = [LTConnectionManager sharedConnectionManager];
        [connectionManager getMediaLargeURLWithId:media_.identifier delegate:self];
    }
    [scrollView_ addSubview:mediaImageView_];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.mediaImageView = nil;
    self.scrollView = nil;
}

- (void)dealloc {
    [media_ release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

#pragma mark - Private methods

- (void)cancelButtonTouched:(UIBarButtonItem *)cancelButton {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadMediaImageAsych {
    [self displayLoaderViewWithDetermination];
    [mediaImageView_ setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:media_.mediaLargeURL]]
                           placeholderImage:nil
                        uploadProgressBlock:nil
                      downloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                          float progress = (float)((double)totalBytesRead/(double)totalBytesExpectedToRead);
                          [self setProgress:progress];
                        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                            //[self resizeImage];
                            [self hideLoader];
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                            [self hideLoader];
                        }];
}

- (void)resizeImage {
    double maxWidth = self.view.frame.size.width;
    double maxHeight = self.view.frame.size.height;
    double mediaWidth;
    double mediaHeight;
    
    if(mediaImageView_.image.size.height/mediaImageView_.image.size.width > maxHeight/mediaWidth){
        mediaHeight = maxHeight;
        mediaWidth = (maxHeight/mediaImageView_.image.size.height)*mediaImageView_.image.size.width;
        self.scrollView.maximumZoomScale = (mediaImageView_.image.size.height/maxHeight)*5;
    } else {
        mediaWidth = maxWidth;
        mediaHeight = (maxWidth/mediaImageView_.image.size.width)*mediaImageView_.image.size.height;
        self.scrollView.maximumZoomScale = (mediaImageView_.image.size.width/maxWidth)*5;
    }
    
    
    mediaImageView_.frame = CGRectMake(0, 0, mediaWidth, mediaHeight);
    CGSize scrollViewBoundsSize = self.scrollView.bounds.size;
    mediaImageView_.center = CGPointMake(scrollViewBoundsSize.width/2, scrollViewBoundsSize.height/2);
    
    self.scrollView.delegate = self;
    
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.minimumZoomScale = 1.0;
    
    self.scrollView.contentSize = mediaImageView_.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return mediaImageView_;
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedMedia:(Media *)media {
    [self hideLoader];
    [self displayLoaderViewWithDetermination];
    [self loadMediaImageAsych];
}

- (void)didFailWithError:(NSError *)error {
    LogDebug(@"%@",error.localizedDescription);
    [self hideLoader];
}

@end
