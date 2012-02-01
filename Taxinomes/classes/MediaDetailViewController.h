//
//  MediaDetailViewController.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 28/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface MediaDetailViewController : UIViewController <UIScrollViewDelegate>{
    NSString* _id_article;
    Article* _article;
    UIScrollView* _scrollView;
    UIActivityIndicatorView* _spinner;
}

@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) NSString *id_article;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil articleId:(NSString *)id_article;
- (IBAction)ClickEventOnMedia:(id)sender;

@end
