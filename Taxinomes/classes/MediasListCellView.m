//
//  MediasListCellView.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
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

#import "MediasListCellView.h"
#import "Author.h";

@implementation MediasListCellView
@synthesize article;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.opaque = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    int xMargin = 10;
	int yMargin = 10;
    
    int thumbnailHeight = 50;
    int thumbnailWidth = 50;
    
    int cellAccessoryWidth = 23;
    
	int cellWidth = self.frame.size.width;
	int cellHeight = self.frame.size.height;
    
    UIColor *titleColor = [UIColor colorWithRed:(95.0/255.0) green:(130.0/255.0) blue:(55.0/255.0) alpha:1.0];
	UIFont *titleFont = [UIFont systemFontOfSize:17];
    
    NSString *authorName = [NSString stringWithString:((Author *)[article.authors objectAtIndex:0]).name];
    UIColor *authorNameColor = [UIColor colorWithRed:(130.0/255.0) green:(210.0/255.0) blue:(55.0/255.0) alpha:1.0];
	UIFont *authorNameFont = [UIFont systemFontOfSize:17];
    
    // taille des textes
	CGSize sizeTitle = [article.title sizeWithFont:titleFont];
    //Author *author =
	CGSize sizeAuthor = [authorName sizeWithFont:authorNameFont];
	
	// calculs
	int xTextOffset = xMargin+thumbnailHeight+xMargin;
	int yTextOffset = 12;
    int maxWidthForTexts = cellWidth-xTextOffset-cellAccessoryWidth;
	// dessin du libelle
	[titleColor set];
	CGPoint point = CGPointMake( xTextOffset, yTextOffset );
	[article.title drawAtPoint:point forWidth:maxWidthForTexts withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
	
	// dessin du solde
	[authorNameColor set];
	point = CGPointMake( xTextOffset, cellHeight-sizeAuthor.height-yTextOffset );
	[authorName drawAtPoint:point forWidth:maxWidthForTexts withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
    
    CGRect zone = CGRectMake(xMargin, yMargin, thumbnailHeight, thumbnailWidth);
    [article.mediaThumbnail drawInRect:zone];
}


- (void)setArticle:(Article *) aArticle {
    article = aArticle;
}

@end
