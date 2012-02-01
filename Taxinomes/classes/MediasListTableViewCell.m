//
//  MediasListTableViewCell.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import "MediasListTableViewCell.h"
#import "MediasListCellView.h"

@implementation MediasListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		CGRect cvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		cellView = [[MediasListCellView alloc] initWithFrame:cvFrame];
		cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //cellView.backgroundColor = [UIColor clearColor];
        //cellView.opaque = NO;
		[self.contentView addSubview:cellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArticle:(Article *) article{
    [cellView setArticle:article];
}

@end
