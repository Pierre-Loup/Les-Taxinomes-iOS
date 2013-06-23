//
//  LTSection.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 23/06/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LTMedia, LTSection;

@interface LTSection : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) LTMedia *medias;
@property (nonatomic, retain) LTSection *parent;

@end
