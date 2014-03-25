//
//  LTMediaDetailViewController.m
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
#import <MediaPlayer/MediaPlayer.h>

// UI
#import "UIImageView+AFNetworking.h"
#import "UIImageView+LT.h"
#import "UIImageView+PhotoFrame.h"
// VC
#import "LTMapViewController.h"
#import "LTMediaDetailViewController.h"
#import "LTMediasRootViewController.h"
#import "MWPhotoBrowser.h"
// MODEL
#import "Annotation.h"
#import "LTMedia+Business.h"

static NSString* const LTMediasRootViewControllerSegueId = @"LTMediasRootViewControllerSegueId";
static NSString* const LTMapViewControllerSegueId = @"LTMapViewControllerSegueId";

@interface LTMediaDetailViewController () <UIScrollViewDelegate,
                                            UIGestureRecognizerDelegate,
                                            MWPhotoBrowserDelegate>
{
    int asynchLoadCounter_;
}

@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UIView * containerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* containerViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* containerViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UIImageView * mediaImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* placeholderAIView;
@property (nonatomic, weak) IBOutlet UIImageView * authorAvatarView;
@property (nonatomic, weak) IBOutlet UILabel * authorNameLabel;
@property (nonatomic, weak) IBOutlet UITextView * descTextView;
@property (nonatomic, weak) IBOutlet UILabel * licenseNameLabel;
@property (nonatomic, weak) IBOutlet MKMapView * mapView;

@end

@implementation LTMediaDetailViewController

#pragma mark - Overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}


- (void)viewDidLoad
{
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
    
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(mapTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    [self.mapView addGestureRecognizer:tapGestureRecognizer];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(authorAvatarTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    self.authorAvatarView.userInteractionEnabled =YES;
    [self.authorAvatarView addGestureRecognizer:tapGestureRecognizer];
    
    self.scrollView.hidden = YES;
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.containerViewWidthConstraint.constant = self.view.bounds.size.width;
    self.containerViewHeightConstraint.constant = CGRectGetMaxY(self.mapView.frame);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LTMapViewControllerSegueId])
    {
        LTMapViewController* mapVC = (LTMapViewController*)segue.destinationViewController;
        mapVC.referenceAnnotation = self.media;
    }
    else if ([segue.identifier isEqualToString: LTMediasRootViewControllerSegueId])
    {
        LTMediasRootViewController* authorMediasVC = (LTMediasRootViewController*)segue.destinationViewController;
        authorMediasVC.currentUser = self.media.author;
    }
}

#pragma mark - Public methodes
#pragma mark Properties

- (void)setMedia:(LTMedia *)media
{
    if(media != _media)
    {
        _media = media;
        [self.scrollView scrollsToTop];
    }
}

#pragma mark - Private methodes

- (void)configureView
{
    [SVProgressHUD show];
    LTConnectionManager *cm = [LTConnectionManager sharedManager];
    
    // Load media datas if not present or not up to date
    if( self.media == nil
       ||  self.media.text == nil
       || [[NSDate date] timeIntervalSinceDate: self.media.localUpdateDate] > LTMediaCacheTime)
    {
        [cm getMediaWithId:self.media.identifier
             responseBlock:^(LTMedia *media, NSError *error) {
                 if (error)
                 {
                     [SVProgressHUD showErrorWithStatus:nil];
                 } else
                 {
                     self.media = media;
                 }
                 
                 asynchLoadCounter_--;
                 [self updateMediaInformation];
                 [self displayContentIfNeeded];
             }];
        asynchLoadCounter_++;
    }
    else
    {
        [self updateMediaInformation];
    }
    
    // Load media datas if not present or not up to date
    if( self.media.author == nil
       ||  self.media.author.avatarURL == nil
       || [[NSDate date] timeIntervalSinceDate: self.media.author.localUpdateDate] > LTMediaCacheTime)
    {
        [cm getAuthorWithId:self.media.author.identifier
              responseBlock:^(LTAuthor *author, NSError *error)
        {
                  
                  if (error) {
                      [SVProgressHUD showErrorWithStatus:nil];
                  }
                  
                  asynchLoadCounter_--;
                  [self displayContentIfNeeded];
              }];
        asynchLoadCounter_++;
    } else {
        [self updateAuthorInformations];
    }
    
    if (asynchLoadCounter_ > 0)
    {
        [SVProgressHUD dismiss];
    }
    
    [self displayContentIfNeeded];
}

- (void)refreshView
{
    if (self.mediaImageView.image)
    {
        self.mediaImageView.frame = CGRectMake(self.mediaImageView.frame.origin.x,
                                               self.mediaImageView.frame.origin.y,
                                               self.mediaImageView.frame.size.width,
                                               self.mediaImageView.frame.size.width);
        self.placeholderAIView.center = CGPointMake(self.mediaImageView.bounds.size.width/2 + self.mediaImageView.frame.origin.x, (self.mediaImageView.bounds.size.height/2) + 100.0 + self.mediaImageView.frame.origin.y);
    }
    
    [self.authorAvatarView setImageWithURL:[NSURL URLWithString:self.media.author.avatarURL]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.authorNameLabel.text = [NSString stringWithFormat:_T(@"media_detail.publish_info_patern"),
                                 self.media.author.name,
                                 [dateFormatter stringFromDate:self.media.date],
                                 [self.media.visits integerValue]];
    
    
    if (self.descTextView)
    {
        if(self.media.text
           && ![self.media.text isEqualToString:@""])
        {
            self.descTextView.text = self.media.text;
        }
        else
        {
            self.descTextView.text = _T(@"media_detail.no_text");
        }
        
        [self.descTextView sizeToFit];
        [self.descTextView removeConstraints:self.descTextView.constraints];
        NSDictionary* views = @{@"text" : self.descTextView};
        NSString* visualFormat = [NSString stringWithFormat:@"V:[text(==%f)]", self.descTextView.contentSize.height];
        NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views];
        [self.descTextView addConstraints:constraints];
        [self.view needsUpdateConstraints];
    }
    
    if ([self.media.license.name length])
    {
        self.licenseNameLabel.text = self.media.license.name;
    }
    else
    {
        self.licenseNameLabel.hidden = YES;
    }
    
    // Map section if media as coordinates
    if (self.media.coordinate.latitude
        && self.media.coordinate.longitude)
    {
        if ([[self.mapView annotations] count])
        {
            [self.mapView removeAnnotations:[self.mapView annotations]];
        }
        [self.mapView addAnnotation:self.media];
        self.mapView.region = MKCoordinateRegionMake(self.media.coordinate, MKCoordinateSpanMake(20.0, 20.0));

        self.mapView.hidden = NO;
        
    }
    else
    {
        self.mapView.hidden = YES;
    }
    
    if (asynchLoadCounter_ > 0)
    {
        [SVProgressHUD show];
    }
    else
    {
        self.scrollView.hidden = NO;
    }

    [self.scrollView layoutIfNeeded];
    
    CGRect containerViewFrame = self.containerView.frame;
    containerViewFrame.size.width = self.scrollView.bounds.size.width;
    containerViewFrame.size.height = CGRectGetMaxY(self.mapView.frame);
    self.containerView.frame = containerViewFrame;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self refreshView];
}

- (void)mediaImageTouched:(UIImage *)sender
{    
    if (self.media.mediaLargeURL.length)
    {
        [self displayMedia];
    }
    else if([self.media.type integerValue] != LTMediaTypeOther)
    {
        [SVProgressHUD show];
        [[LTConnectionManager sharedManager] getMediaLargeURLWithId:self.media.identifier responseBlock:^(LTMedia *media, NSError *error)
        {
            if (!error)
            {
                [self displayMedia];
                [SVProgressHUD dismiss];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:nil];
            }
        }];
    }
}



- (void)displayMedia
{
    if (self.media.mediaLargeURL.length)
    {
        LTMediaType mediaType = [self.media.type integerValue];
        if (mediaType == LTMediaTypeImage)
        {
            // Create browser
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            
            // Present
            [self.navigationController pushViewController:browser animated:YES];
        }
        else if ([self.media.type integerValue] == LTMediaTypeAudio ||
                 [self.media.type integerValue] == LTMediaTypeVideo)
        {
            NSURL* contentURL = [NSURL URLWithString:self.media.mediaLargeURL];
            MPMoviePlayerViewController* playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:contentURL];
            [self presentMoviePlayerViewControllerAnimated:playerViewController];
        }
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
    [self.placeholderAIView startAnimating];
    
    NSString* placeholderImageName;
    LTMediaType mediaType = [self.media.type integerValue];
    [self.mediaImageView setImageWithMedia:self.media];
}

- (void)updateAuthorInformations
{
//    [self.authorAvatarView setImageWithURL:[NSURL URLWithString:self.media.author.avatarURL]
//                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
}

#pragma mark Actions

- (void)authorAvatarTouched:(UIImageView *)sender
{
    [self performSegueWithIdentifier:LTMediasRootViewControllerSegueId sender:self];
}

- (void)mapTouched:(MKMapView *)sender
{
    [self performSegueWithIdentifier:LTMapViewControllerSegueId sender:self];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MWPhotoBrowserDelegate methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    NSURL* imageURL = [NSURL URLWithString:self.media.mediaLargeURL];
    return [MWPhoto photoWithURL:imageURL];
}

@end
