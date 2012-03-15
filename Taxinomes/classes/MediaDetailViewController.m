//
//  MediaDetailViewController.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 28/11/11.
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

#import "MediaDetailViewController.h"
#import "MediaFullSizeViewContoller.h"
#import "LTDataManager.h"
#import "Constants.h"

@implementation MediaDetailViewController
@synthesize id_article = _id_article;
@synthesize article = _article;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil articleId:(NSString *)id_article {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.id_article = id_article;
    }
    return self;
}

- (void) dealloc {
    [_id_article release];
    [_article release];
    [_scrollView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad{
    int maxWidth = [UIScreen mainScreen].applicationFrame.size.width;
    int maxHeight = [UIScreen mainScreen].applicationFrame.size.height;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner setCenter:CGPointMake(maxWidth/2.0, maxHeight/2.0)]; 
    [self.scrollView addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    
    self.navigationController.tabBarItem.title = @"Media";
    LTDataManager *dm = [LTDataManager sharedDataManager];
    if(self.article == nil)
        self.article = [dm getArticleWithId:self.id_article];
    
    NSString *authorId = ((Author *)[self.article.authors objectAtIndex:0]).id_author;
    Author *author = [[dm getAuthorWithId:authorId] retain];
    
    
    int maxWidth = [UIScreen mainScreen].applicationFrame.size.width;
    int maxHeight = [UIScreen mainScreen].applicationFrame.size.height;
    self.scrollView.delegate = self;
    
    CGRect frame = CGRectMake(0, 0, maxWidth, maxHeight*2);
    self.scrollView.contentSize = frame.size;
    
    int imageOffsetTop = 50;
    int marginsLeftRight = 5;
    int marginsTopBottom = 10;
    
    //Article Title Background
    CGRect articleTitleBackgroundFrame = CGRectMake(marginsLeftRight, marginsTopBottom, maxWidth-(marginsLeftRight*2), imageOffsetTop-(marginsTopBottom*2));
    UIImageView *articleTitleView = [[UIImageView alloc] initWithFrame:articleTitleBackgroundFrame];
    articleTitleView.image = [UIImage imageNamed:@"bg_titre_left.png"];
    
    //Article Title Text
    CGRect titleLabelFrame = CGRectMake(marginsLeftRight, 0, maxWidth-(marginsLeftRight*2)-65, imageOffsetTop-(marginsTopBottom*2));
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = self.article.title;
    titleLabel.backgroundColor = [UIColor clearColor];
    [articleTitleView addSubview:titleLabel];
    [titleLabel release];
    [self.scrollView addSubview:articleTitleView];
    [articleTitleView release];

    
    //Media image
    
    int mediaWidth = maxWidth-(marginsLeftRight*2);
    int mediaHeight = ((maxWidth-(marginsLeftRight*2))/self.article.media.size.width)*self.article.media.size.height;
    
    CGRect mediaFrame = CGRectMake(marginsLeftRight, imageOffsetTop, mediaWidth, mediaHeight);
    UIImageView *mediaView = [[UIImageView alloc] initWithFrame:mediaFrame];
    mediaView.image = self.article.media;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClickEventOnMedia:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    mediaView.userInteractionEnabled = YES;
    [mediaView addGestureRecognizer:tapRecognizer];
    
    [self.scrollView addSubview:mediaView];
    [tapRecognizer release];
    [mediaView release];
    
    //AUTHOR
    int authorTitleOffsetTop = imageOffsetTop+mediaHeight+marginsTopBottom;
    
    //AuthorTitle Background
    CGRect authorTitleBackgroundFrame = CGRectMake(marginsLeftRight, authorTitleOffsetTop, maxWidth-(marginsLeftRight*2), imageOffsetTop-(marginsTopBottom*2));
    UIImageView *authorTitleView = [[UIImageView alloc] initWithFrame:authorTitleBackgroundFrame];
    authorTitleView.image = [UIImage imageNamed:@"bg_titre_left.png"];
    
    //Author Title Text
    CGRect authorTitleLabelFrame = CGRectMake(marginsLeftRight, 0, maxWidth/2, imageOffsetTop-(marginsTopBottom*2));
    UILabel *authorTitleLabel = [[UILabel alloc] initWithFrame:authorTitleLabelFrame];
    authorTitleLabel.textColor = [UIColor whiteColor];
    authorTitleLabel.font = [UIFont systemFontOfSize:20];
    authorTitleLabel.text = @"Auteur";
    authorTitleLabel.backgroundColor = [UIColor clearColor];
    [authorTitleView addSubview:authorTitleLabel];
    [authorTitleLabel release];
    [self.scrollView addSubview:authorTitleView];
    [authorTitleView release];
    
    int authorThumbnailOffsetTop = (imageOffsetTop*2)+mediaHeight;
    CGRect authorThumbnailFrame = CGRectMake(marginsLeftRight, authorThumbnailOffsetTop, 50, 50);
    UIImageView *authorThumbnailView = [[UIImageView alloc] initWithFrame:authorThumbnailFrame];
    authorThumbnailView.image = author.avatar; 
    [self.scrollView addSubview:authorThumbnailView];    
    [authorThumbnailView release];
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"dd/MM/yyyy"];
    
    int authorNameOffsetLeft = (marginsLeftRight*2)+50;
    CGRect authorNameLabelFrame = CGRectMake(authorNameOffsetLeft, authorThumbnailOffsetTop, maxWidth-authorNameOffsetLeft-marginsLeftRight, 50);    
    UILabel *authorNameLabel = [[UILabel alloc] initWithFrame:authorNameLabelFrame];
    authorNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    authorNameLabel.numberOfLines = 3;
    authorNameLabel.font = [UIFont systemFontOfSize:12];
    authorNameLabel.text = [NSString stringWithFormat:@"Publié par %@ le %@\n %d vues",author.name, [df stringFromDate:self.article.date],self.article.visits];
    [self.scrollView addSubview:authorNameLabel];
    [authorNameLabel release];
    
    //DESCRIPTION
    int descTitleOffsetTop = authorThumbnailOffsetTop+50+marginsTopBottom;
    
    //descTitle Background
    CGRect descTitleBackgroundFrame = CGRectMake(marginsLeftRight, descTitleOffsetTop, maxWidth-(marginsLeftRight*2), imageOffsetTop-(marginsTopBottom*2));
    UIImageView *descTitleView = [[UIImageView alloc] initWithFrame:descTitleBackgroundFrame];
    descTitleView.image = [UIImage imageNamed:@"bg_titre_left.png"];
    
    //desc Title Text
    CGRect descTitleLabelFrame = CGRectMake(marginsLeftRight, 0, maxWidth/2, imageOffsetTop-(marginsTopBottom*2));
    UILabel *descTitleLabel = [[UILabel alloc] initWithFrame:descTitleLabelFrame];
    descTitleLabel.textColor = [UIColor whiteColor];
    descTitleLabel.font = [UIFont systemFontOfSize:20];
    descTitleLabel.text = @"Description";
    descTitleLabel.backgroundColor = [UIColor clearColor];
    [descTitleView addSubview:descTitleLabel];
    [descTitleLabel release];
    [self.scrollView addSubview:descTitleView];
    [descTitleView release];
    
    int descTextViewOffsetTop = descTitleOffsetTop+40;
    CGRect descTextViewFrame = CGRectMake(marginsLeftRight, descTextViewOffsetTop, maxWidth-(marginsLeftRight*2), 20);
    UITextView *descTextView = [[UITextView alloc] initWithFrame:descTextViewFrame];
    if(self.article.text != @""){
        descTextView.text = self.article.text;
    } else {
        descTextView.text = kNoDescription;
    }
    
    descTextView.editable = NO;
    [self.scrollView addSubview:descTextView];
    descTextViewFrame.size.height = descTextView.contentSize.height;
    descTextView.frame = descTextViewFrame;
    [descTextView release];
    
    frame = CGRectMake(0, 0, maxWidth, descTextViewOffsetTop+descTextViewFrame.size.height+marginsTopBottom);
    self.scrollView.contentSize = frame.size;
    
    [self.spinner stopAnimating];
    [author release];
     
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.spinner = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)ClickEventOnMedia:(id)sender{
    MediaFullSizeViewContoller *mediaFullSizeViewController = [[MediaFullSizeViewContoller alloc] initWithNibName:@"MediaFullSizeView" bundle:nil media:self.article.media];
    [self.navigationController pushViewController:mediaFullSizeViewController animated:YES];
    [mediaFullSizeViewController release];
}

@end
