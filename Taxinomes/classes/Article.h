//
//  Article.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 19/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMLRPCResponse.h"

@interface Article : NSObject {
    NSString* _id_article;
    NSString* _title;
    NSString* _text;
    NSString* _id_section;
    NSString* _status;
    NSDate* _date;
    NSDate* _updateDate;
    NSInteger _visits;
    CGFloat _popularity;
    NSString* _id_license;
    NSDate* _dataReceivedDate;
    NSString* _mediaThumbnailURL;
    NSString* _mediaURL;
    UIImage* _mediaThumbnail;
    UIImage* _media;    
    NSArray* _authors;
}

@property (nonatomic, retain) NSString* id_article;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* id_section;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSDate* updateDate;
@property (nonatomic, assign) NSInteger visits;
@property (nonatomic, assign) CGFloat popularity;
@property (nonatomic, retain) NSString* id_license;
@property (nonatomic, retain) NSDate* dataReceivedDate;
@property (nonatomic, retain) NSString* mediaThumbnailURL;
@property (nonatomic, retain) NSString* mediaURL;
@property (nonatomic, retain) UIImage* mediaThumbnail;
@property (nonatomic, retain) UIImage* media;
@property (nonatomic, retain) NSArray* authors;

+ (Article *)articleWithXMLRPCResponse: (NSDictionary *) response;

@end
