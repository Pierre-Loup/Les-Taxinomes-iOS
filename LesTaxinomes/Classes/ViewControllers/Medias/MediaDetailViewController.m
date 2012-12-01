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

#import "Annotation.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+PhotoFrame.h"
//VC
#import "MapViewController.h"
#import "MediaDetailViewController.h"
#import "MediaFullSizeViewContoller.h"

@interface MediaDetailViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    int asynchLoadCounter_;
}

@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;
@property (nonatomic, retain) IBOutlet UIImageView * mediaImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* placeholderAIView;
@property (nonatomic, retain) IBOutlet LTTitleView * authorTitleView;
@property (nonatomic, retain) IBOutlet UIImageView * authorAvatarView;
@property (nonatomic, retain) IBOutlet UILabel * authorNameLabel;
@property (nonatomic, retain) IBOutlet LTTitleView * descTitleView;
@property (nonatomic, retain) IBOutlet UITextView * descTextView;
@property (nonatomic, retain) IBOutlet LTTitleView * licenseTitleView;
@property (nonatomic, retain) IBOutlet UILabel * licenseNameLabel;
@property (nonatomic, retain) IBOutlet LTTitleView * mapTitleView;
@property (nonatomic, retain) IBOutlet MKMapView * mapView;

@end

@implementation MediaDetailViewController
@synthesize media = media_;

#pragma mark - Overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) dealloc {
    [media_ release];
    [_scrollView release];
    [_mediaImageView release];
    [_placeholderAIView release];
    [_authorTitleView release];
    [_authorAvatarView release];
    [_authorNameLabel release];
    [_descTitleView release];
    [_descTextView release];
    [_mapTitleView release];
    [_mapView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = media_.title;
    
    UIBarButtonItem* backButtonItem = [[[UIBarButtonItem alloc] initWithTitle:_T(@"common.back")
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    asynchLoadCounter_ = 0;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.opaque = NO;
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(mediaImageTouched:)];
    [tapGestureRecognizer autorelease];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    //Don't forget to set the userInteractionEnabled UIView property to YES, default is NO.
    self.mediaImageView.userInteractionEnabled = YES;
    [self.mediaImageView addGestureRecognizer:tapGestureRecognizer];
    
    self.authorTitleView.title = _T(@"common.author");
    
    [self.authorAvatarView setImageWithURL:[NSURL URLWithString:media_.author.avatarURL]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    

    self.descTitleView.title = _T(@"common.description");
    self.licenseTitleView.title = _T(@"common.license");
    self.mapTitleView.title = _T(@"common.map");

    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(mapTouched:)];
    [tapGestureRecognizer autorelease];
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

- (void)setMedia:(Media *)media {
    if(media != media_) {
        [media_ release];
        media_ = [media retain];
        [self.scrollView scrollsToTop];
        [self configureView];
    }
}

#pragma mark - Private methodes

- (void)configureView
{
    [self showHudForLoading];
    LTDataManager *dm = [LTDataManager sharedDataManager];
    [dm getMediaWithId:self.media.identifier
          responseBlock:^(Media* media, NSError *error) {
              
              if ([error shouldBeDisplayed]) {
                  [UIAlertView showWithError:error];
                  [self.hud hide:NO];
              }
              
              asynchLoadCounter_--;
              [self loadMediaView];
              [self displayContentIfNeeded];
    }];
    asynchLoadCounter_++;
    [dm getAuthorWithId:self.media.author.identifier
          responseBlock:^(Author *author, NSError *error) {
              
              if ([error shouldBeDisplayed]) {
                  [UIAlertView showWithError:error];
                  [self.hud hide:NO];
              }
              
              asynchLoadCounter_--;
              [self displayContentIfNeeded];
    }];
    asynchLoadCounter_++;

}

- (void)refreshView {
    CGFloat currentContentHeight = 0;
    CGFloat commonMargin = 10.0;
    
    if (self.mediaImageView.image) {
        self.mediaImageView.frame = CGRectMake(self.mediaImageView.frame.origin.x,
                                               self.mediaImageView.frame.origin.y,
                                               self.mediaImageView.frame.size.width,
                                               self.mediaImageView.frame.size.width);
        self.placeholderAIView.center = CGPointMake(self.mediaImageView.bounds.size.width/2, self.mediaImageView.bounds.size.height/2);
    }
    currentContentHeight += self.mediaImageView.frame.origin.y + self.mediaImageView.frame.size.height + commonMargin;
     
    // Author section
    self.authorTitleView.frame = CGRectMake(self.authorTitleView.frame.origin.x,
                                            currentContentHeight,
                                            self.authorTitleView.frame.size.width,
                                            self.authorTitleView.frame.size.height);
    currentContentHeight += self.authorTitleView.frame.size.height + commonMargin;
    
    [self.authorAvatarView setImageWithURL:[NSURL URLWithString:media_.author.avatarURL]
                           placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    self.authorAvatarView.frame = CGRectMake(self.authorAvatarView.frame.origin.x,
                                             currentContentHeight,
                                             self.authorAvatarView.frame.size.width,
                                             self.authorAvatarView.frame.size.height);
    self.authorNameLabel.frame = CGRectMake(self.authorNameLabel.frame.origin.x,
                                            currentContentHeight,
                                            self.authorNameLabel.frame.size.width,
                                            self.authorNameLabel.frame.size.height);
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.authorNameLabel.text = [NSString stringWithFormat:_T(@"media_detail.publish_info_patern"),
                                 media_.author.name,
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
    }
    
    // Map section if media as coordinates
    if (media_.coordinate.latitude
        && media_.coordinate.longitude) {
        
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
        [self.mapView addAnnotation:media_];
        self.mapView.region = MKCoordinateRegionMake(media_.coordinate, MKCoordinateSpanMake(20.0, 20.0));
        self.mapTitleView.hidden = NO;
        self.mapView.hidden = NO;
        
        
        currentContentHeight += self.mapView.frame.size.height + commonMargin;
    } else {
        self.mapTitleView.hidden = YES;
        self.mapView.hidden = YES;
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, currentContentHeight)];
    if (asynchLoadCounter_ > 0) {
        [self showHudForLoading];
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

- (void)mediaImageTouched:(UIImage *)sender {
    MediaFullSizeViewContoller * mediaFullSizeViewController = [[MediaFullSizeViewContoller alloc] initWithNibName:@"MediaFullSizeViewController" bundle:nil];
    mediaFullSizeViewController.media = media_;
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:mediaFullSizeViewController];
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [mediaFullSizeViewController release];
}

- (void)displayContentIfNeeded {
    if (asynchLoadCounter_ <= 0) {
        [self.hud hide:YES];
        [self refreshView];
        [self.scrollView setHidden:NO];
    }
}

- (void)loadMediaView {
    
    [self.placeholderAIView startAnimating];
    [self.mediaImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:media_.mediaMediumURL]]
                           placeholderImage:[UIImage imageNamed:@"medium_placeholder"]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        [self.hud hide:YES];
                                        [self.placeholderAIView stopAnimating];
                                        [self refreshView];
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        [self.hud hide:YES];
                                    }];
}

- (void)mapTouched:(MKMapView *)sender {
    MapViewController* mapVC = [[MapViewController alloc] initWithAnnotation:media_];
    [self.navigationController pushViewController:mapVC animated:YES];
    mapVC.title = _T(@"common.map");
    [mapVC release];
}

@end
