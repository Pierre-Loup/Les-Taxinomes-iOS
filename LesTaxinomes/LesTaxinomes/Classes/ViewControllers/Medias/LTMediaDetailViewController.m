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
#import "LTLicense+Business.h"
#import "LTMedia+Business.h"

static NSString* const LTMediasRootViewControllerSegueId = @"LTMediasRootViewControllerSegueId";
static NSString* const LTMapViewControllerSegueId = @"LTMapViewControllerSegueId";

@interface LTMediaDetailViewController () <UIScrollViewDelegate,
                                            UIGestureRecognizerDelegate,
                                            MWPhotoBrowserDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UIImageView * mediaImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* placeholderAIView;
@property (nonatomic, weak) IBOutlet UIImageView * authorAvatarView;
@property (nonatomic, weak) IBOutlet UILabel * authorNameLabel;
@property (nonatomic, weak) IBOutlet UITextView * textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* textViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UIImageView * licenseImageView;
@property (nonatomic, weak) IBOutlet MKMapView * mapView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* mapViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* contentViewHeightConstraint;

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
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat textViewContentHeight = 0.f;
    if (IOS7_OR_GREATER)
    {
        CGSize sizeThatFits = [self.textView sizeThatFits:self.textView.frame.size];
        textViewContentHeight = sizeThatFits.height;
    }
    else
    {
        CGSize contentSize = self.textView.contentSize;
        textViewContentHeight = contentSize.height;
    }
    self.textViewHeightConstraint.constant = textViewContentHeight;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
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

- (void)setupView
{
    LTConnectionManager *cm = [LTConnectionManager sharedManager];
    
    if( self.media == nil
       ||  self.media.text == nil
       || [[NSDate date] timeIntervalSinceDate: self.media.localUpdateDate] > LTMediaCacheTime)
    {
        [SVProgressHUD show];
        [cm getMediaWithId:self.media.identifier
             responseBlock:^(LTMedia *media, NSError *error)
        {
            if (error)
            {
                [SVProgressHUD showErrorWithStatus:nil];
            }
            else
            {
                self.media = media;
                [SVProgressHUD dismiss];
            }
            
            [self refreshMedia];
        }];
    }
    [self refreshMedia];
    
    if( self.media.author == nil
       ||  self.media.author.avatarURL == nil
       || [[NSDate date] timeIntervalSinceDate: self.media.author.localUpdateDate] > LTMediaCacheTime)
    {
        [cm getAuthorWithId:self.media.author.identifier
              responseBlock:^(LTAuthor *author, NSError *error)
        {
            if (error)
            {
                [SVProgressHUD showErrorWithStatus:nil];
            }
            
            
            
        }];
    }
    [self refreshAuthor];
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

- (void)refreshMedia
{
    UIView* bottomView = self.mediaImageView;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(mediaImageTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    self.mediaImageView.userInteractionEnabled = YES;
    [self.mediaImageView addGestureRecognizer:tapGestureRecognizer];
    //[self.placeholderAIView startAnimating];
    
    [self.mediaImageView setImageWithMedia:self.media completion:^
    {
        
    }];
    
    if (self.media.license.icon.length)
    {
        NSURL* licenseIconURL = [NSURL URLWithString:self.media.license.icon];
        [self.licenseImageView setImageWithURL:licenseIconURL];
    }
    
    if(self.media)
    {
        self.textView.text = [self.media.text length] ? self.media.text : _T(@"media_detail.no_text");
        self.textView.hidden = NO;
        bottomView = self.textView;
    }
    else
    {
        self.textView.hidden = YES;
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
        bottomView = self.mapView;
    }
    else
    {
        self.mapView.hidden = YES;
    }
    
    [self.scrollView removeConstraint:self.contentViewHeightConstraint];
    self.contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:bottomView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:10];
    [self.scrollView addConstraint:self.contentViewHeightConstraint];
    [self.scrollView needsUpdateConstraints];
    
}

- (void)refreshAuthor
{
    UIImage* authorAvatarPlaceholderImage = [UIImage imageNamed:@"default_avatar.png"];
    if (self.media.author)
    {
        [self.authorAvatarView setImageWithURL:[NSURL URLWithString:self.media.author.avatarURL]
                              placeholderImage:authorAvatarPlaceholderImage];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        self.authorNameLabel.text = [NSString stringWithFormat:_T(@"media_detail.publish_info_patern"),
                                     self.media.author.name,
                                     [dateFormatter stringFromDate:self.media.date],
                                     [self.media.visits integerValue]];
        self.authorNameLabel.hidden = NO;
    }
    else
    {
        self.authorAvatarView.image = authorAvatarPlaceholderImage;
        self.authorNameLabel.hidden = YES;
    }
    
}

#pragma mark Actions

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
