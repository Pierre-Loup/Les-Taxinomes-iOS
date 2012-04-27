//
//  Author.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

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
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

@end
