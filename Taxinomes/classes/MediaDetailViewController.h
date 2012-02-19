//
//  MediaDetailViewController.h
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
