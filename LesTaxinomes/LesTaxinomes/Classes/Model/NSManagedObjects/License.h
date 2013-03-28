//
//  License.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface License : NSManagedObject

@property (nonatomic, retain) NSString * abbr;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Media *medias;

@end
