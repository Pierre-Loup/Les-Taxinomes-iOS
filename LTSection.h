//
//  LTSection.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LTMedia, LTSection;

@interface LTSection : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) LTMedia *medias;
@property (nonatomic, retain) LTSection *parent;
@end

@interface LTSection (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(LTSection *)value;
- (void)removeChildrenObject:(LTSection *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
