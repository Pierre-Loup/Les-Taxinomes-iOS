//
//  MediaDetailViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/11/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
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
#import <QuickLook/QuickLook.h>

// UI
#import "EGOPhotoGlobal.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+PhotoFrame.h"
// VC
#import "LTMapViewController.h"
#import "MediaDetailViewController.h"
// MODEL
#import "Annotation.h"
#import "LTMedia+Business.h"

@interface MediaDetailViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    int asynchLoadCounter_;
}

@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) IBOutlet UIImageView * mediaImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* placeholderAIView;
@property (nonatomic, strong) IBOutlet LTTitleView * authorTitleView;
@property (nonatomic, strong) IBOutlet UIImageView * authorAvatarView;
@property (nonatomic, strong) IBOutlet UILabel * authorNameLabel;
@property (nonatomic, strong) IBOutlet LTTitleView * descTitleView;
@property (nonatomic, strong) IBOutlet UITextView * descTextView;
@property (nonatomic, strong) IBOutlet LTTitleView * licenseTitleView;
@property (nonatomic, strong) IBOutlet UILabel * licenseNameLabel;
@property (nonatomic, strong) IBOutlet LTTitleView * mapTitleView;
@property (nonatomic, strong) IBOutlet MKMapView * mapView;
@property (nonatomic, readonly) IBOutlet UIImageView* downloadImageView;

@end

@implementation MediaDetailViewController
@synthesize downloadImageView = _downloadImageView;

#pragma mark - Overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.media.mediaTitle;
    
    UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithTitle:_T(@"common.back")
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    asynchLoadCounter_ = 0;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.opaque = NO;
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(mapTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    [self.mapView addGestureRecognizer:tapGestureRecognizer];
    
    [self.scrollView setHidden:YES];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    self.scrollView = nil;
    self.mediaImageView = nil;
    self.placeholderAIView = nil;
    self.mediaImageView = nil;
    self.authorAvatarView = nil;
    self.authorNameLabel = nil;
    self.descTitleView = nil;
    self.descTextView = nil;
    self.mapTitleView = nil;
    self.mapView = nil;
}

#pragma mark - Properties

- (void)setMedia:(LTMedia *)media {
    if(media != _media) {
        _media = media;
        [self.scrollView scrollsToTop];
        [self configureView];
    }
}

- (UIImageView*)downloadImageView
{
    if (!_downloadImageView) {
        _downloadImageView = [UIImageView new];
    }
    return _downloadImageView;
}

#pragma mark - Private methodes

- (void)configureView
{
    [SVProgressHUD show];
    LTConnectionManager *cm = [LTConnectionManager sharedManager];
    
    // Load media datas if not present or not up to date
    if( self.media == nil
       ||  self.media.mediaMediumURL == nil
       || [[NSDate date] timeIntervalSinceDate: self.media.localUpdateDate] > kMediaCacheTime) {
        [cm getMediaWithId:self.media.identifier
             responseBlock:^(LTMedia *media, NSError *error) {
                 if (error) {
                     [SVProgressHUD showErrorWithStatus:nil];
                     
                 } else {
                     self.media = media;
                 }
                 
                 asynchLoadCounter_--;
                 [self updateMediaInformation];
                 [self displayContentIfNeeded];
             }];
        asynchLoadCounter_++;
    } else {
        [self updateMediaInformation];
    }
    
    // Load media datas if not present or not up to date
    if( self.media.author == nil
       ||  self.media.author.avatarURL == nil
       || [[NSDate date] timeIntervalSinceDate: self.media.author.localUpdateDate] > kMediaCacheTime) {
        [cm getAuthorWithId:self.media.author.identifier
              responseBlock:^(LTAuthor *author, NSError *error) {
                  
                  if (error) {
                      [SVProgressHUD showErrorWithStatus:nil];
                  }
                  
                  asynchLoadCounter_--;
                  [self updateAuthorInformations];
                  [self displayContentIfNeeded];
              }];
        asynchLoadCounter_++;
    } else {
        [self updateAuthorInformations];
    }
    
    [self displayContentIfNeeded];
}

- (void)refreshView {
    CGFloat currentContentHeight = 0;
    CGFloat commonMargin = 10.0;
    
    if (self.mediaImageView.image) {
        self.mediaImageView.frame = CGRectMake(self.mediaImageView.frame.origin.x,
                                               self.mediaImageView.frame.origin.y,
                                               self.mediaImageView.frame.size.width,
                                               self.mediaImageView.frame.size.width);
        self.placeholderAIView.center = CGPointMake(self.mediaImageView.bounds.size.width/2 + self.mediaImageView.frame.origin.x, (self.mediaImageView.bounds.size.height/2) + 100.0 + self.mediaImageView.frame.origin.y);
    }
    currentContentHeight += self.mediaImageView.frame.origin.y + self.mediaImageView.frame.size.height + commonMargin;
    
    // Author section
    self.authorTitleView.frame = CGRectMake(self.authorTitleView.frame.origin.x,
                                            currentContentHeight,
                                            self.authorTitleView.frame.size.width,
                                            self.authorTitleView.frame.size.height);
    currentContentHeight += self.authorTitleView.frame.size.height + commonMargin;
    
    [self.authorAvatarView setImageWithURL:[NSURL URLWithString:self.media.author.avatarURL]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    self.authorAvatarView.frame = CGRectMake(self.authorAvatarView.frame.origin.x,
                                             currentContentHeight,
                                             self.authorAvatarView.frame.size.width,
                                             self.authorAvatarView.frame.size.height);
    self.authorNameLabel.frame = CGRectMake(self.authorNameLabel.frame.origin.x,
                                            currentContentHeight,
                                            self.authorNameLabel.frame.size.width,
                                            self.authorNameLabel.frame.size.height);
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.authorNameLabel.text = [NSString stringWithFormat:_T(@"media_detail.publish_info_patern"),
                                 self.media.author.name,
                                 [dateFormatter stringFromDate:self.media.date],
                                 [self.media.visits integerValue]];
    currentContentHeight += self.authorAvatarView.frame.size.height + commonMargin;
    
    // Description section
    self.descTitleView.frame = CGRectMake(self.descTitleView.frame.origin.x,
                                          currentContentHeight,
                                          self.descTitleView.frame.size.width,
                                          self.descTitleView.frame.size.height);
    currentContentHeight += self.descTitleView.frame.size.height + commonMargin;
    
    if(self.media.text
       && ![self.media.text isEqualToString:@""]){
        self.descTextView.text = self.media.text;
    } else {
        self.descTextView.text = _T(@"media_detail.no_text");
    }
    self.descTextView.frame = CGRectMake(self.descTextView.frame.origin.x,
                                         currentContentHeight,
                                         self.descTextView.frame.size.width,
                                         self.descTextView.contentSize.height);
    currentContentHeight += self.descTextView.frame.size.height + commonMargin;
    
    // License section
    if ([self.media.license.name length]) {
        self.licenseTitleView.frame = CGRectMake(self.licenseTitleView.frame.origin.x,
                                                 currentContentHeight,
                                                 self.licenseTitleView.frame.size.width,
                                                 self.licenseTitleView.frame.size.height);
        currentContentHeight += self.licenseTitleView.frame.size.height + commonMargin;
        
        self.licenseNameLabel.text = self.media.license.name;
        
        self.licenseNameLabel.frame = CGRectMake(self.licenseNameLabel.frame.origin.x,
                                                 currentContentHeight,
                                                 self.licenseNameLabel.frame.size.width,
                                                 self.licenseNameLabel.frame.size.height);
        currentContentHeight += self.licenseNameLabel.frame.size.height + commonMargin;
    } else {
        self.licenseTitleView.hidden = YES;
        self.licenseNameLabel.hidden = YES;
    }
    
    // Map section if media as coordinates
    if (self.media.coordinate.latitude
        && self.media.coordinate.longitude) {
        
        self.mapTitleView.frame = CGRectMake(self.mapTitleView.frame.origin.x,
                                             currentContentHeight,
                                             self.mapTitleView.frame.size.width,
                                             self.mapTitleView.frame.size.height);
        currentContentHeight += self.mapTitleView.frame.size.height + commonMargin;
        
        self.mapView.frame = CGRectMake(self.mapView.frame.origin.x,
                                        currentContentHeight,
                                        self.mapView.frame.size.width,
                                        self.mapView.frame.size.width);
        if ([[self.mapView annotations] count]) {
            [self.mapView removeAnnotations:[self.mapView annotations]];
        }
        [self.mapView addAnnotation:self.media];
        self.mapView.region = MKCoordinateRegionMake(self.media.coordinate, MKCoordinateSpanMake(20.0, 20.0));
        self.mapTitleView.hidden = NO;
        self.mapView.hidden = NO;
        
        
        currentContentHeight += self.mapView.frame.size.height + commonMargin;
    } else {
        self.mapTitleView.hidden = YES;
        self.mapView.hidden = YES;
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, currentContentHeight)];
    if (asynchLoadCounter_ > 0) {
        [SVProgressHUD show];
    } else {
        self.scrollView.hidden = NO;
    }
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

- (void)mediaImageTouched:(UIImage *)sender
{    
    if (self.media.mediaLargeURL.length) {
        [self displayLargeMediaPhotoViewer];
    } else {
        [SVProgressHUD show];
        [[LTConnectionManager sharedManager] getMediaLargeURLWithId:self.media.identifier responseBlock:^(LTMedia *media, NSError *error) {
            
            if (!error) {
                self.media = media;
                [self displayLargeMediaPhotoViewer];
            } else {
                [SVProgressHUD showErrorWithStatus:nil];
            }
            
        }];
    }
}

- (void)displayLargeMediaPhotoViewer
{
    if (self.media.mediaLargeURL.length) {
        NSURL* imageURL = [NSURL URLWithString:self.media.mediaLargeURL];
        EGOPhotoViewController* photoController = [[EGOPhotoViewController alloc] initWithImageURL:imageURL];
        [self.navigationController pushViewController:photoController animated:YES];
        [SVProgressHUD dismiss];
    } else {
        [SVProgressHUD showErrorWithStatus:nil];
    }
}

- (void)displayContentIfNeeded
{
    if (asynchLoadCounter_ <= 0) {
        [SVProgressHUD dismiss];
        [self refreshView];
        [self.scrollView setHidden:NO];
    }
}

- (void)updateMediaInformation
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(mediaImageTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    //Don't forget to set the userInteractionEnabled UIView property to YES, default is NO.
    self.mediaImageView.userInteractionEnabled = YES;
    [self.mediaImageView addGestureRecognizer:tapGestureRecognizer];
    self.descTitleView.title = _T(@"common.description");
    self.licenseTitleView.title = _T(@"common.license");
    self.mapTitleView.title = _T(@"common.map");
    [self.placeholderAIView startAnimating];
    __block MediaDetailViewController* weakSelf = self;
    [self.mediaImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.media.mediaMediumURL]]
                               placeholderImage:[UIImage imageNamed:@"egopv_photo_placeholder"]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            weakSelf.mediaImageView.image = image;
                                            [SVProgressHUD dismiss];
                                            [weakSelf.placeholderAIView stopAnimating];
                                            [weakSelf refreshView];
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            [SVProgressHUD showErrorWithStatus:nil];
                                            [weakSelf.placeholderAIView stopAnimating];
                                            [weakSelf refreshView];
                                        }];
}

- (void)updateAuthorInformations
{
    self.authorTitleView.title = _T(@"common.author");
    [self.authorAvatarView setImageWithURL:[NSURL URLWithString:self.media.author.avatarURL]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
}

- (void)mapTouched:(MKMapView *)sender {
    LTMapViewController* mapVC = [[LTMapViewController alloc] initWithAnnotation:self.media];
    [self.navigationController pushViewController:mapVC animated:YES];
    mapVC.title = _T(@"common.map");
}

@end
