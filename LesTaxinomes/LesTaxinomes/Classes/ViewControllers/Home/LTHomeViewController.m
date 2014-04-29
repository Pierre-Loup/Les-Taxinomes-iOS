//
//  HomeViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 26/01/12.
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

#import "LTHomeViewController.h"

// Views
#import "AGMedallionView.h"
#import "JBKenBurnsView.h"
#import "LTMediaListCell.h"
#import "UIImageView+AFNetworking.h"
// VCs
#import "LTAuthenticationSheetViewController.h"
#import "LTLegalNoticeViewController.h"
#import "LTMediaDetailViewController.h"
#import "LTMediasRootViewController.h"
#import "LTMediaUploadFormViewController.h"
// Model
#import "LTPhotoAssetManager.h"
#import "SDWebImageManager.h"

static NSString* const LTMediaListCellIdentifier = @"";
static NSTimeInterval const LTHomeCoverTransitionTimeInterval = 10.0;

// Segue
static NSString* const LTMediasRootViewControllerSegueId    = @"LTMediasRootViewControllerSegueId";
static NSString* const LTMediaDetailViewControllerSegueId   = @"LTMediaDetailViewControllerSegueId";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTHomeViewController () <LTAuthenticationSheetDelegate,
                                    JBKenBurnsViewDatasource>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *infoButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cameraBarButton;
@property (nonatomic, weak) IBOutlet UILabel* userNameLabel;
@property (nonatomic, weak) IBOutlet JBKenBurnsView *kenBurnsView;
@property (nonatomic, weak) IBOutlet AGMedallionView* userAvatarView;

@property (nonatomic, strong) NSURL* mediaToShareAssetURL;
@property (nonatomic, assign) BOOL shouldPresentAuthenticationSheet;
@property (nonatomic, strong) NSArray* mediasForCover;
@property (nonatomic, assign) NSInteger mediaCoverIndex;
@property (nonatomic, strong) AFHTTPRequestOperation* searchRequestOperation;
@property (nonatomic, strong) NSArray* mediasSearchResult;


@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - View implementation

@implementation LTHomeViewController
;
////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _shouldPresentAuthenticationSheet = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView* searchResultsTableView = self.searchDisplayController.searchResultsTableView;
    if ([searchResultsTableView respondsToSelector:@selector(separatorInset)])
    {
        searchResultsTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    // Medaillion view
    UIImage* defaultAvatar = [UIImage imageNamed:@"default_avatar"];
    self.userAvatarView.image = defaultAvatar;
    
    [self.userNameLabel setNumberOfLines:0];
    [self.userNameLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self.userNameLabel setContentMode:UIViewContentModeCenter];
    [self.userNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.userNameLabel setFont:[UIFont fontWithName:@"Jesaya Free" size:17.0]];
    self.userNameLabel.text = _T(@"home.username.placeholder");
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.infoButton = infoBarButtonItem;
    [self.navigationItem setLeftBarButtonItem:infoBarButtonItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.cameraBarButton animated:YES];
    
    // Medaillion view
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(medaillonTouchUpInside:)];
    [self.userAvatarView addGestureRecognizer:tapGesture];
    
    // Medias cover view
    self.mediaCoverIndex = -1;
    __weak LTHomeViewController* weakSelf = self;
    [[LTConnectionManager sharedManager] fetchHomeCoversWithResponseBlock:^(NSArray *medias, NSError *error)
     {
         if (!error)
         {
             weakSelf.mediasForCover = medias;
         }
         else
         {
             NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.mediaLargeURL != nil"];
             weakSelf.mediasForCover = [LTMedia MR_findAllWithPredicate:predicate
                                                              inContext:[NSManagedObjectContext MR_defaultContext]];
         }
         
         if ([weakSelf.mediasForCover count])
         {
             [weakSelf.kenBurnsView startAnimationWithDatasource:weakSelf
                                                            loop:YES
                                                         rotates:NO
                                                     isLandscape:YES];
             UITapGestureRecognizer* mediasCoverTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf
                                                                                                     action:@selector(mediasCoverTouchUpInside:)];
             [weakSelf.kenBurnsView addGestureRecognizer:mediasCoverTapGesture];
         }
     }];
    
    [[LTConnectionManager sharedManager] authWithLogin:nil
                                              password:nil
                                         responseBlock:^(LTAuthor *authenticatedUser, NSError *error)
    {
        if (authenticatedUser)
        {
            weakSelf.userNameLabel.text = authenticatedUser.name;
            [weakSelf updateAvatar];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateAvatar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if(self.shouldPresentAuthenticationSheet)
    {
        self.shouldPresentAuthenticationSheet = NO;
        [self displayAuthenticationSheetAnimated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LTMediasRootViewControllerSegueId])
    {
        LTMediasRootViewController* homeVC = (LTMediasRootViewController*)segue.destinationViewController;
        homeVC.currentUser = [LTConnectionManager sharedManager].authenticatedUser;
    }
    else if ([segue.identifier isEqualToString:LTMediaDetailViewControllerSegueId])
    {
        LTMediaDetailViewController* mediaDetailVC = (LTMediaDetailViewController*)segue.destinationViewController;
        mediaDetailVC.media = self.mediasForCover[self.mediaCoverIndex];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientation
{
    return UIInterfaceOrientationMaskPortrait;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)displayAuthenticationSheetAnimated:(BOOL)animated
{
    UINavigationController* authenticationSheetNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthenticationSheet"];
    LTAuthenticationSheetViewController* authenticationSheetViewController = (LTAuthenticationSheetViewController*)authenticationSheetNavigationController.viewControllers[0];
    authenticationSheetViewController.delegate = self;
    authenticationSheetViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:authenticationSheetNavigationController
                       animated:animated
                     completion:^{}];
}

- (void)updateAvatar
{
    LTAuthor* user = [LTConnectionManager sharedManager].authenticatedUser;
    if (user)
    {
        NSURL* imageURL = [NSURL URLWithString:user.avatarURL];
        NSURLRequest* request = [NSURLRequest requestWithURL:imageURL];
        
        __weak LTHomeViewController* weakSelf = self;
        [[UIImageView new] setImageWithURLRequest:request
                                 placeholderImage:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            weakSelf.userAvatarView.image = image;
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
    }
    
    
}

#pragma mark Actions

- (IBAction)infoButtonAction:(id) sender
{
    LTLegalNoticeViewController *legalInformationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LTLegalNoticeViewController"];
    [self.navigationController pushViewController:legalInformationsViewController animated:YES];
}

- (IBAction)cameraButtonAction:(id) sender
{
    __weak LTHomeViewController* weakSelf = self;
    [[LTPhotoAssetManager sharedManager] photoAssetPickerWithTitle:nil
                                                        showInView:self.view.window
                                                         presentVC:self
    onPhotoPicked:^(NSURL* chosenImageAssetURL, NSError* error)
    {
        if (chosenImageAssetURL && !error) {
            LTConnectionManager* cm = [LTConnectionManager sharedManager];
            if (!cm.authenticatedUser)
            {
                [SVProgressHUD show];
                [cm authWithLogin:nil
                         password:nil
                    responseBlock:^(LTAuthor *authenticatedUser, NSError *error)
                {
                        [SVProgressHUD dismiss];
                        if (!authenticatedUser)
                        {
                            weakSelf.mediaToShareAssetURL = chosenImageAssetURL;
                            if(weakSelf.presentedViewController)
                            {
                                weakSelf.shouldPresentAuthenticationSheet = YES;
                            } else {
                                [weakSelf displayAuthenticationSheetAnimated:YES];
                            }
                        }
                        else
                        {
                            [weakSelf dismissViewControllerAnimated:YES
                                                     completion:^{}];
                            LTMediaUploadFormViewController* mediaUploadVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"LTMediaUploadFormViewController"];
                            mediaUploadVC.mediaAssetURL = chosenImageAssetURL;
                            [weakSelf.navigationController pushViewController:mediaUploadVC animated:YES];
                        }
                    }];
            }
            else
            {
                [weakSelf dismissViewControllerAnimated:YES
                                         completion:^{}];
                LTMediaUploadFormViewController* mediaUploadVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"LTMediaUploadFormViewController"];
                mediaUploadVC.mediaAssetURL = chosenImageAssetURL;
                [weakSelf.navigationController pushViewController:mediaUploadVC animated:YES];
            }
        }
    } onCancel:^{}];
}

- (void)medaillonTouchUpInside:(AGMedallionView*)medaillonView
{
    if (![LTConnectionManager sharedManager].authenticatedUser)
    {
        
        [self displayAuthenticationSheetAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:LTMediasRootViewControllerSegueId
                                  sender:self];
    }
}

- (void)mediasCoverTouchUpInside:(JBKenBurnsView*)kenBurnsView
{
    if (self.mediaCoverIndex >= 0 &&
        self.mediaCoverIndex < [self.mediasForCover count])
    {
        [self performSegueWithIdentifier:LTMediaDetailViewControllerSegueId
                                  sender:self];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTAuthenticationSheetDelegate

- (void)authenticationDidFinishWithSuccess:(BOOL)success
{
    LTAuthor *authenticatedUser = [LTConnectionManager sharedManager].authenticatedUser;
    if (success && authenticatedUser)
    {
        self.userNameLabel.text = authenticatedUser.name;
        [self updateAvatar];
        [self dismissViewControllerAnimated:YES
                                 completion:^{}];
        if (self.mediaToShareAssetURL)
        {
            LTMediaUploadFormViewController* mediaUploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LTMediaUploadFormViewController"];
            mediaUploadVC.mediaAssetURL = self.mediaToShareAssetURL;
            self.mediaToShareAssetURL = nil;
            [self.navigationController pushViewController:mediaUploadVC animated:YES];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^{}];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - JBKenBurnsViewDatasource

- (NSInteger)numberOfImagesInKenBurnsView:(JBKenBurnsView*)kenBurnsView
{
    return [self.mediasForCover count];
}

- (CGFloat)kenBurnsView:(JBKenBurnsView*)kenBurnsView transitionDurationForImageAtIndex:(NSInteger)imageIndex
{
    return LTHomeCoverTransitionTimeInterval;
}

- (void)kenBurnsView:(JBKenBurnsView*)kenBurnsView loadImageAtIndex:(NSInteger)imageIndex completed:(void(^)(UIImage *image))completed
{
    LTMedia* mediaToDisplay = self.mediasForCover[imageIndex];
    NSURL* mediaCoverURL = [NSURL URLWithString:mediaToDisplay.mediaLargeURL];
    if (mediaCoverURL)
    {
        __weak LTHomeViewController* weakSelf = self;
        [[SDWebImageManager sharedManager] downloadWithURL:mediaCoverURL
                                                   options:0
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             weakSelf.mediaCoverIndex = imageIndex;
             completed(image);
         }];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(self.searchRequestOperation)
    {
        
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.mediasSearchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTMedia *media = self.mediasSearchResult[indexPath.row];
    
    LTMediaListCell* cell = [aTableView dequeueReusableCellWithIdentifier:LTMediaListCellIdentifier];
    if (!cell)
    {
        cell = [LTMediaListCell mediaListCell];
    }
    
    cell.media = media;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LTMediasListCommonRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTMedia *media = self.mediasSearchResult[indexPath.row];
    
    if(media)
    {
        LTMediaDetailViewController* mediaDetailViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"LTMediaDetailViewController"];
        mediaDetailViewController.media = media;
        mediaDetailViewController.title = media.mediaTitle;
        [self.navigationController pushViewController:mediaDetailViewController
                                             animated:YES];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // return YES to cause the search result table view to be reloaded
    if ([searchString length] >= 3)
    {
        NSRange range;
        range.location = 0;
        range.length = LTMediasSearchStep;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.searchRequestOperation cancel];
        
        __weak LTHomeViewController* weakSelf = self;
        self.searchRequestOperation = [[LTConnectionManager sharedManager] fetchMediasSummariesByDateForAuthor:nil
                                                                  nearLocation:nil
                                                                  searchFilter:searchString
                                                                     withRange:range
                                                                 responseBlock:^(NSArray *medias, NSError *error)
         {
             NSLog(@"%@", error);
             if ([medias count])
             {
                 weakSelf.mediasSearchResult = medias;
                 [controller.searchResultsTableView reloadData];
             }
             else if (!error)
             {
                 weakSelf.mediasSearchResult = nil;
                 [controller.searchResultsTableView reloadData];
             }
             
             if (!error ||
                 !([error.domain isEqualToString:NSURLErrorDomain] &&
                  error.code == NSURLErrorCancelled))
             {
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }
         }];
        return NO;
    }
    else
    {
        if(self.searchRequestOperation)
        {
            self.searchRequestOperation = nil;
            [controller.searchResultsTableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }
        return YES;
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchRequestOperation cancel];
    self.searchRequestOperation = nil;
    [controller.searchResultsTableView reloadData];
}



@end
