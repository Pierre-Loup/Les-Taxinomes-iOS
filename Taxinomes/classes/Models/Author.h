//
//  Author.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * biography;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * localUpdateDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * signupDate;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *medias;

+ (Author *)authorWithXMLRPCResponse:(NSDictionary*)response;
+ (Author *)authorWithIdentifier: (NSNumber *)identifier;

@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

@end
