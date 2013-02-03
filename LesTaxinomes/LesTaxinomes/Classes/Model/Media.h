//
//  Media.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/05/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class Author, License, Section;

@interface Media : NSManagedObject <MKAnnotation>

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSNumber * identifier;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSDate * localUpdateDate;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSString * mediaLargeLocalFile;
@property (nonatomic, strong) NSString * mediaLargeURL;
@property (nonatomic, strong) NSString * mediaMediumLocalFile;
@property (nonatomic, strong) NSString * mediaMediumURL;
@property (nonatomic, strong) NSString * mediaThumbnailLocalFile;
@property (nonatomic, strong) NSString * mediaThumbnailUrl;
@property (nonatomic, strong) NSNumber * popularity;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) NSDate * updateDate;
@property (nonatomic, strong) NSNumber * visits;
@property (nonatomic, strong) NSNumber * sychGapForDateSorting;
@property (nonatomic, strong) Author * author;
@property (nonatomic, strong) License * license;
@property (nonatomic, strong) Section * section;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (Media *)mediaWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (Media *)mediaLargeURLWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (Media *)mediaWithIdentifier: (NSNumber *)identifier;
+ (NSArray *)allMedias;
+ (void)deleteAllMedias;

@end
