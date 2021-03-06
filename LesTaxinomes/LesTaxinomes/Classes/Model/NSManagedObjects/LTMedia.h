//
//  LTMedia.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 07/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LTAuthor, LTLicense, LTSection;

@interface LTMedia : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * localUpdateDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * mediaLargeURL;
@property (nonatomic, retain) NSString * mediaMediumURL;
@property (nonatomic, retain) NSString * mediaThumbnailUrl;
@property (nonatomic, retain) NSString * mediaTitle;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * sychGapForDateSorting;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * visits;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) LTAuthor *author;
@property (nonatomic, retain) LTLicense *license;
@property (nonatomic, retain) LTSection *section;

@end
