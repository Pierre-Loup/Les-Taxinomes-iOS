//
//  LTAuthor.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 23/06/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LTMedia;

@interface LTAuthor : NSManagedObject

@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * biography;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * localUpdateDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * signupDate;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *medias;
@end

@interface LTAuthor (CoreDataGeneratedAccessors)

- (void)addMediasObject:(LTMedia *)value;
- (void)removeMediasObject:(LTMedia *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

@end
