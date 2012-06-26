//
//  MediaDetailViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 28/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
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

#import "MediaDetailViewController.h"
#import "MediaFullSizeViewContoller.h"
#import "Constants.h"
#import "Annotation.h"

#define kCommonWidth 310.0

@implementation MediaDetailViewController
@synthesize mediaIdentifier = mediaIdentifier_;
@synthesize media = media_;
@synthesize scrollView = scrollView_;
@synthesize mediaImageView = mediaImageView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mediaId:(NSNumber *)mediaIdentifier {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mediaIdentifier = mediaIdentifier;
    }
    return self;
}

- (void) dealloc {
    self.mediaIdentifier = nil;
    self.media = nil;
    self.scrollView = nil;
    
    [mediaTitleView_ release];
    [mediaImageView_ release];
    [authorTitleView_ release];
    [authorAvatarView_ release];
    [authorNameLabel_ release];
    [descTitleView_ release];
    [descTextView_ release];
    [mapTitleView_ release];
    [mapView_ release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    asynchLoadCounter_ = 0;
    self.title = @"Média";
    [self.scrollView setHidden:YES];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.opaque = NO;
    self.scrollView.delegate = self;
    
    mediaTitleView_ = [[LTTitleView titleViewWithOrigin:CGPointMake(5, 5)] retain];
    [self.scrollView addSubview:mediaTitleView_];
    [mediaTitleView_ setHidden:YES];
    
    mediaImageView_ = [[TCImageView alloc] initWithURL:@"" placeholderView:nil];
    mediaImageView_.caching = YES;
    mediaImageView_.delegate = self;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaImageTouched:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    mediaImageView_.userInteractionEnabled = YES;
    [mediaImageView_ addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    [self.scrollView addSubview:mediaImageView_];
    
    
    authorTitleView_ = [[LTTitleView titleViewWithOrigin:CGPointMake(5, 5)] retain];
    authorTitleView_.titleLabel.text = @"Auteur";
    [self.scrollView addSubview:authorTitleView_];
    [authorTitleView_ setHidden:YES];
    
    authorAvatarView_ = [[TCImageView alloc] initWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    authorAvatarView_.caching = YES;
    authorAvatarView_.delegate = self;
    [authorNameLabel_ setClipsToBounds:YES];
    [authorNameLabel_ setContentMode:UIViewContentModeScaleAspectFill];
    [self.scrollView addSubview:authorAvatarView_];
    
    authorNameLabel_ = [[UILabel alloc] init];
    [self.scrollView addSubview:authorNameLabel_];
    
    descTitleView_ = [[LTTitleView titleViewWithOrigin:CGPointMake(5, 5)] retain];
    descTitleView_.titleLabel.text = @"Description";
    [self.scrollView addSubview:descTitleView_];
    [descTitleView_ setHidden:YES];
    
    descTextView_ = [[UITextView alloc] init];
    descTextView_.editable = NO;
    [descTextView_ setDataDetectorTypes:UIDataDetectorTypeAll];
    [self.scrollView addSubview:descTextView_];
    
    mapTitleView_ = [[LTTitleView titleViewWithOrigin:CGPointMake(5, 5)] retain];
    mapTitleView_.titleLabel.text = @"Carte";
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    LTDataManager *dm = [LTDataManager sharedDataManager];
    self.media = [Media mediaWithIdentifier: 
                  self.mediaIdentifier];
    if([dm getMediaAsychIfNeededWithId:self.mediaIdentifier withDelegate:self])
        asynchLoadCounter_ = asynchLoadCounter_ + 1;
    if([dm getAuthorAsychIfNeededWithId:self.media.author.identifier withDelegate:self])
        asynchLoadCounter_ = asynchLoadCounter_ + 1;
    if (asynchLoadCounter_ > 0) {
        [self displayLoader];
    }
    [self refreshView];
}

- (void)refreshView {
    CGFloat imageHeight;
    CGFloat descHeight;
    
    if (media_.title && ![media_.title isEqualToString:@""]) {
        mediaTitleView_.titleLabel.text = media_.title;
        
    } else {
        mediaTitleView_.titleLabel.text = kNoTitle;
    }
    [mediaTitleView_ setHidden:NO];
    
    NSString * mediaImageUrl = media_.mediaMediumURL?media_.mediaMediumURL:@"";
    if (![mediaImageView_.url isEqualToString:mediaImageUrl]
        && ![mediaImageUrl isEqualToString:@""]) {
        asynchLoadCounter_ = asynchLoadCounter_ + 1;
        [mediaImageView_ reloadWithUrl:mediaImageUrl];
    }
    
    if (mediaImageView_.image) {
        imageHeight =  (kCommonWidth/mediaImageView_.image.size.width)*mediaImageView_.image.size.height;
        mediaImageView_.frame = CGRectMake(5, 40, 310.0, imageHeight);
    }
    
    authorTitleView_.frame = CGRectMake(5.0, 45.0+imageHeight, authorTitleView_.frame.size.width, authorTitleView_.frame.size.height);
    [authorTitleView_ setHidden:NO];
    
    NSString * authorAvatarUrl = media_.author.avatarURL?media_.author.avatarURL:@"";
    if (![authorAvatarView_.url isEqualToString:authorAvatarUrl]
        && ![authorAvatarUrl isEqualToString:@""]) {
        asynchLoadCounter_ = asynchLoadCounter_ + 1;
        [authorAvatarView_ reloadWithUrl:authorAvatarUrl];
    }
    authorAvatarView_.frame = CGRectMake(5.0, 80.0+imageHeight, 50.0, 50.0);
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"dd/MM/yyyy"];
    
    authorNameLabel_.frame = CGRectMake(65.0, 80.0+imageHeight, 250.0, 50.0);
    authorNameLabel_.lineBreakMode = UILineBreakModeTailTruncation;
    authorNameLabel_.numberOfLines = 0;
    authorNameLabel_.font = [UIFont systemFontOfSize:14.0];
    authorNameLabel_.text = [NSString stringWithFormat:@"Publié par %@ le %@\n%d vues", media_.author.name, [df stringFromDate:self.media.date],[self.media.visits integerValue]];
    [authorNameLabel_ setBackgroundColor:[UIColor clearColor]];
    
    descTitleView_.frame = CGRectMake(5.0, 135.0+imageHeight, descTitleView_.frame.size.width, descTitleView_.frame.size.height);
    [descTitleView_ setHidden:NO];
    
    if(self.media.text
       && ![self.media.text isEqualToString:@""]){
        descTextView_.text = self.media.text;
    } else {
        descTextView_.text = kNoDescription;
    }
    descHeight = (CGFloat)descTextView_.contentSize.height;
    descTextView_.frame = CGRectMake(0.0, 170.0+imageHeight, 320.0, descHeight);
    [descTextView_ setBackgroundColor:[UIColor clearColor]];
    
    mapTitleView_.frame = CGRectMake(5.0, 175.0+imageHeight+descHeight, mapTitleView_.frame.size.width, mapTitleView_.frame.size.height);
    [mapTitleView_ setHidden:NO];
    
    CGRect mapViewFrame = CGRectMake(5.0, 210.0+imageHeight+descHeight, 310.0, 310.0);
    [mapView_ setFrame:mapViewFrame];
    if ([[mapView_ annotations] count]) {
        [mapView_ removeAnnotations:[mapView_ annotations]];
    }
    Annotation * mediaPinAnnotation = [[Annotation new] autorelease];
    mediaPinAnnotation.title = media_.title;
    mediaPinAnnotation.subtitle = [NSString stringWithFormat:@"Par %@",media_.author.name];
    mediaPinAnnotation.coordinate = CLLocationCoordinate2DMake([media_.latitude floatValue], [media_.longitude floatValue]);
    if (mediaPinAnnotation.coordinate.longitude != 0.0
        && mediaPinAnnotation.coordinate.latitude != 0.0) {
        [mapView_ addAnnotation:mediaPinAnnotation];
        mapView_.region = MKCoordinateRegionMake(mediaPinAnnotation.coordinate, MKCoordinateSpanMake(20.0, 20.0));
    } else {
        mapView_.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(20.0, 0.0), MKCoordinateSpanMake(150.0, 180.0));
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 525.0+imageHeight+descHeight)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)mediaImageTouched:(UIImage *)sender {
    MediaFullSizeViewContoller * mediaFullSizeViewController = [[MediaFullSizeViewContoller alloc] initWithNibName:@"MediaFullSizeViewController" bundle:nil];
    mediaFullSizeViewController.media = media_;
    [self.navigationController pushViewController:mediaFullSizeViewController animated:YES];
    [mediaFullSizeViewController release];
}

- (void)displayContentIfNeeded {
    [self refreshView];
    if (asynchLoadCounter_ <= 0) {
        [self hideLoader];
        [self.scrollView setHidden:NO];
    }
}

- (void)mapTouched:(MKMapView *)sender {
    NSLog(@"mapTouched:");
}

#pragma mark - TCImageViewDelegate

- (void)TCImageView:(TCImageView *) view FinisehdImage:(UIImage *)image {
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

-(void) TCImageView:(TCImageView *) view failedWithError:(NSError *)error {
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

#pragma mark - LTConnectionManagerDelegate

- (void)didRetrievedMedia:(Media *)media {
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

- (void)didRetrievedAuthor:(Author *)author {
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

- (void)didFailWithError:(NSError *)error {
#if TAXINOMES_DEV
    NSLog(@"%@",error.localizedDescription);
#endif
    asynchLoadCounter_ = asynchLoadCounter_ - 1;
    [self displayContentIfNeeded];
}

@end
