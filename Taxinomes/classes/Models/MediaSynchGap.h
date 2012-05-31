//
//  MediaSynchGap.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 11/05/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface MediaSynchGap : NSManagedObject

@property (nonatomic, retain) NSSet *medias;
@end

@interface MediaSynchGap (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

@end
