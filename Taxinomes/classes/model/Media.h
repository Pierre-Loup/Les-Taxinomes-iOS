//
//  Media.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 19/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, License, Section;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * visits;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * mediaThumbnailUrl;
@property (nonatomic, retain) NSString * mediaThumbnailLocalFile;
@property (nonatomic, retain) NSString * mediaMediumLocalFile;
@property (nonatomic, retain) NSString * mediaMediumURL;
@property (nonatomic, retain) NSString * mediaLargeURL;
@property (nonatomic, retain) NSString * mediaLargeLocalFile;
@property (nonatomic, retain) NSDate * localUpdateDate;
@property (nonatomic, retain) License *license;
@property (nonatomic, retain) Author *authors;
@property (nonatomic, retain) Section *section;

+ (Media *)mediaWithXMLRPCResponse: (NSDictionary *) response;
+ (Media *)mediaWithIdentifier: (NSNumber *)identifier;
+ (NSArray *)allMedias;

@end
