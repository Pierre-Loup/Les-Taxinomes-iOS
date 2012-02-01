//
//  MediaFullSizeViewContoller.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 24/01/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MediaFullSizeViewContoller.h"

@implementation MediaFullSizeViewContoller
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize mediaView = _mediaView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil media:(UIImage *)media {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *mediaView = [[UIImageView alloc] initWithFrame:self.view.frame];
        mediaView.image = media;
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
        //self.scrollView.maximumZoomScale = (self.mediaView.image.size.width/maxWidth)*2;
    } else {
        mediaHeight = maxHeight;
        mediaWidth = (maxHeight/self.mediaView.image.size.height)*self.mediaView.image.size.width;
        //self.scrollView.maximumZoomScale = (self.mediaView.image.size.height/maxHeight)*2;
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
