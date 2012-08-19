//
//  MediaDetailViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 28/11/11.
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

#import "Annotation.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+PhotoFrame.h"
//VC
#import "MapViewController.h"
#import "MediaDetailViewController.h"
#import "MediaFullSizeViewContoller.h"

@interface MediaDetailViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, LTConnectionManagerDelegate, MKMapViewDelegate>{
    int asynchLoadCounter_;
    
    LTTitleView * mediaTitleView_;
    UIImageView * mediaImageView_;
    LTTitleView * authorTitleView_;
    UIImageView * authorAvatarView_;
    UILabel * authorNameLabel_;
    LTTitleView * descTitleView_;
    UITextView * descTextView_;
    LTTitleView * mapTitleView_;
    MKMapView * mapView_;
    UIActivityIndicatorView* placeholderAIView_;
}

@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;
- (void)configureView;
- (void)refreshView;
- (void)mediaImageTouched:(UIImage *)sender;
- (void)displayContentIfNeeded;
- (void)loadMediaView;
@end

@implementation MediaDetailViewController
@synthesize media = media_;
@synthesize scrollView = scrollView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) dealloc {
    [media_ release];
    [scrollView_ release];
    [mediaTitleView_ release];
    [mediaImageView_ release];
    [placeholderAIView_ release];
    [authorTitleView_ release];
    [authorAvatarView_ release];
    [authorNameLabel_ release];
    [descTitleView_ release];
    [descTextView_ release];
    [mapTitleView_ release];
    [mapView_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    asynchLoadCounter_ = 0;
    [self.scrollView setHidden:YES];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.opaque = NO;
    self.scrollView.delegate = self;
    
    mediaTitleView_ = [LTTitleView new];
    [self.scrollView addSubview:mediaTitleView_];
    [mediaTitleView_ setHidden:YES];
    
    mediaImageView_ = [UIImageView new];
    [mediaImageView_ setClipsToBounds:YES];
    [mediaImageView_ setContentMode:UIViewContentModeScaleAspectFill];
    [placeholderAIView_ = [UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [placeholderAIView_ startAnimating];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaImageTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    //Don't forget to set the userInteractionEnabled UIView property to YES, default is NO.
    mediaImageView_.userInteractionEnabled = YES;
    [mediaImageView_ addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    [self.scrollView addSubview:mediaImageView_];
    
    
    authorTitleView_ = [LTTitleView new];
    authorTitleView_.title = TRANSLATE(@"common.author");
    [self.scrollView addSubview:authorTitleView_];
    [authorTitleView_ setHidden:YES];
    
    authorAvatarView_ = [UIImageView new];
    [authorNameLabel_ setClipsToBounds:YES];
    [authorNameLabel_ setContentMode:UIViewContentModeScaleAspectFill];
    [self.scrollView addSubview:authorAvatarView_];
    
    authorNameLabel_ = [[UILabel alloc] init];
    [self.scrollView addSubview:authorNameLabel_];
    
    descTitleView_ = [LTTitleView new];
    descTitleView_.title = TRANSLATE(@"common.description");
    [self.scrollView addSubview:descTitleView_];
    [descTitleView_ setHidden:YES];
    
    descTextView_ = [[UITextView alloc] init];
    descTextView_.editable = NO;
    [descTextView_ setDataDetectorTypes:UIDataDetectorTypeAll];
    [self.scrollView addSubview:descTextView_];
    
    mapTitleView_ = [LTTitleView new];
    mapTitleView_.title = TRANSLATE(@"common.map");
    [self.scrollView addSubview:mapTitleView_];
    [mapTitleView_ setHidden:YES];
    
    mapView_ = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    mapView_.mapType = MKMapTypeStandard;
    mapView_.scrollEnabled = NO;
    mapView_.zoomEnabled = NO;
    mapView_.delegate = self;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    [mapView_ addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    [self.scrollView addSubview:mapView_];
    
    [self.scrollView setHidden:YES];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    self.scrollView = nil;
    [mediaTitleView_ release];
    mediaTitleView_ = nil;
    [mediaImageView_ release];
    mediaImageView_ = nil;
    [placeholderAIView_ release];
    placeholderAIView_ = nil;
    [authorTitleView_ release];
    mediaImageView_ = nil;
    [authorAvatarView_ release];
    authorAvatarView_ = nil;
    [authorNameLabel_ release];
    authorNameLabel_ = nil;
    [descTitleView_ release];
    descTitleView_ = nil;
    [descTextView_ release];
    descTextView_ = nil;
    [mapTitleView_ release];
    mapTitleView_ = nil;
    [mapView_ release];
    mapView_ = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (media_) {
        [self configureView];
    }
}

#pragma mark - Properties

- (void)setMedia:(Media *)media {
    if(media != media_) {
        [media_ release];
        media_ = [media retain];
        [self configureView];
    }
}

#pragma mark - Private methodes

- (void)configureView {
    [self displayLoader];
    scrollView_.hidden = YES;
    LTDataManager *dm = [LTDataManager sharedDataManager];
    if([dm getMediaAsychIfNeededWithId:media_.identifier withDelegate:self]) {
        asynchLoadCounter_ = asynchLoadCounter_ + 1;
    } else {
        [self loadMediaView];
        [self refreshView];
    }
    if([dm getAuthorAsychIfNeededWithId:self.media.author.identifier withDelegate:self])
        asynchLoadCounter_ = asynchLoadCounter_ + 1;
    if (asynchLoadCounter_ > 0) {
        [self displayLoader];
    } else {
        [self refreshView];
        [self.scrollView setHidden:NO];
    }
}

- (void)refreshView {
    CGFloat contentHeight = 0;
    
    CGFloat imageHeight = 0;
    CGFloat descHeight;
    
    CGFloat commonWidth = self.view.frame.size.width - 10.0;
    CGRect viewFrame = self.view.frame;
    
    mediaTitleView_.frame = CGRectMake(5.0, 5.0, viewFrame.size.width, 30.0);
    if (media_.title && ![media_.title isEqualToString:@""]) {
        mediaTitleView_.title = media_.title;
        
    } else {
        mediaTitleView_.title = TRANSLATE(@"media_upload_no_title");
    }
    [mediaTitleView_ setHidden:NO];
    
    if (mediaImageView_.image) {
        imageHeight =  (commonWidth/mediaImageView_.image.size.width)*mediaImageView_.image.size.height;
        mediaImageView_.frame = CGRectMake(5, 40, 310.0, imageHeight);
        placeholderAIView_.center = CGPointMake(mediaImageView_.bounds.size.width/2, mediaImageView_.bounds.size.height/2);
    }
    
    authorTitleView_.frame = CGRectMake(5.0, 45.0+imageHeight, authorTitleView_.frame.size.width, authorTitleView_.frame.size.height);
    [authorTitleView_ setHidden:NO];
    
    [authorAvatarView_ setImageWithURL:[NSURL URLWithString:media_.author.avatarURL]
                      placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    authorAvatarView_.frame = CGRectMake(5.0, 80.0+imageHeight, 50.0, 50.0);
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"dd/MM/yyyy"];
    
    authorNameLabel_.frame = CGRectMake(65.0, 80.0+imageHeight, 250.0, 50.0);
    authorNameLabel_.lineBreakMode = UILineBreakModeTailTruncation;
    authorNameLabel_.numberOfLines = 0;
    authorNameLabel_.font = [UIFont systemFontOfSize:14.0];
    authorNameLabel_.text = [NSString stringWithFormat:TRANSLATE(@"media_detail.publish_info_patern"), media_.author.name, [df stringFromDate:self.media.date],[self.media.visits integerValue]];
    [authorNameLabel_ setBackgroundColor:[UIColor clearColor]];
    
    descTitleView_.frame = CGRectMake(5.0, 135.0+imageHeight, descTitleView_.frame.size.width, descTitleView_.frame.size.height);
    [descTitleView_ setHidden:NO];
    
    if(self.media.text
       && ![self.media.text isEqualToString:@""]){
        descTextView_.text = self.media.text;
    } else {
        descTextView_.text = TRANSLATE(@"media_detail.no_text");
    }
    descHeight = (CGFloat)descTextView_.contentSize.height;
    descTextView_.frame = CGRectMake(0.0, 170.0+imageHeight, 320.0, descHeight);
    [descTextView_ setBackgroundColor:[UIColor clearColor]];
    
    
    if (media_.coordinate.latitude
        && media_.coordinate.longitude) {
        mapTitleView_.frame = CGRectMake(5.0, 175.0+imageHeight+descHeight, mapTitleView_.frame.size.width, mapTitleView_.frame.size.height);
        [mapTitleView_ setHidden:NO];
        
        CGRect mapViewFrame = CGRectMake(5.0, 210.0+imageHeight+descHeight, 310.0, 310.0);
        [mapView_ setFrame:mapViewFrame];
        if ([[mapView_ annotations] count]) {
            [mapView_ removeAnnotations:[mapView_ annotations]];
        }
        Annotation * mediaPinAnnotation = [[Annotation new] autorelease];
        mediaPinAnnotation.title = media_.title;
        mediaPinAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@",TRANSLATE(@"common.by"),media_.author.name];
        mediaPinAnnotation.coordinate = CLLocationCoordinate2DMake([media_.latitude floatValue], [media_.longitude floatValue]);
        if (mediaPinAnnotation.coordinate.longitude != 0.0
            && mediaPinAnnotation.coordinate.latitude != 0.0) {
            [mapView_ addAnnotation:mediaPinAnnotation];
            mapView_.region = MKCoordinateRegionMake(mediaPinAnnotation.coordinate, MKCoordinateSpanMake(20.0, 20.0));
        } else {
            mapView_.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(20.0, 0.0), MKCoordinateSpanMake(150.0, 180.0));
        }
        contentHeight += 355.0;
        mapTitleView_.hidden = NO;
        mapView_.hidden = NO;
    } else {
        mapTitleView_.hidden = YES;
        mapView_.hidden = YES;
    }
    
    contentHeight += 170.0;
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, contentHeight+imageHeight+descHeight)];
    if (asynchLoadCounter_ > 0) {
        [self displayLoader];
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
        [self hideLoader];
        [self refreshView];
        [self.scrollView setHidden:NO];
    }
}

- (void)loadMediaView {
    
    [mediaImageView_ addSubview:placeholderAIView_];
    [mediaImageView_ setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:media_.mediaMediumURL]]
                           placeholderImage:[UIImage imageNamed:@"medium_placeholder"]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        [self hideLoader];
                                        [placeholderAIView_ removeFromSuperview];
                                        [self refreshView];
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        [self hideLoader];
                                    }];
}

- (void)mapTouched:(MKMapView *)sender {
    MapViewController* mapVC = [[MapViewController alloc] initWithAnnotation:media_];
    [self.navigationController pushViewController:mapVC animated:YES];
    mapVC.title = TRANSLATE(@"common.map");
    [mapVC release];
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedMedia:(Media *)media {
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self loadMediaView];
    [self displayContentIfNeeded];
}

- (void)didRetrievedAuthor:(Author *)author {
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

- (void)didFailWithError:(NSError *)error {
    LogDebug(@"%@",error.localizedDescription);
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

@end
