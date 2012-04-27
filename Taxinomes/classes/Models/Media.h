//
//  Media.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, License, Section;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * localUpdateDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * mediaLargeLocalFile;
@property (nonatomic, retain) NSString * mediaLargeURL;
@property (nonatomic, retain) NSString * mediaMediumLocalFile;
@property (nonatomic, retain) NSString * mediaMediumURL;
@property (nonatomic, retain) NSString * mediaThumbnailLocalFile;
@property (nonatomic, retain) NSString * mediaThumbnailUrl;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * visits;
@property (nonatomic, retain) Author *author;
@property (nonatomic, retain) License *license;
@property (nonatomic, retain) Section *section;

@end
