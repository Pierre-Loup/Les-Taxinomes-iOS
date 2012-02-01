//
//  MediasListCellView.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface MediasListCellView : UIView {
    Article *article;
}

@property (nonatomic, retain) Article *article;

- (void)setArticle:(Article *) aArticle;

@end
