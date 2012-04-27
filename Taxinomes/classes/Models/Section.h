//
//  Section.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 27/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, Section;

@interface Section : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Section *parent;
@property (nonatomic, retain) Media *medias;

@end
