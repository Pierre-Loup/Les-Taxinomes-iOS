//
//  Author.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 27/04/12.
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

@class Media;

@interface Author : NSManagedObject

@property (nonatomic, strong) NSString * avatarURL;
@property (nonatomic, strong) NSString * biography;
@property (nonatomic, strong) NSNumber * identifier;
@property (nonatomic, strong) NSDate * localUpdateDate;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSDate * signupDate;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSSet *medias;

+ (Author *)authorWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (Author *)authorWithIdentifier: (NSNumber *)identifier;
+ (NSArray *)allAuthors;
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

@end