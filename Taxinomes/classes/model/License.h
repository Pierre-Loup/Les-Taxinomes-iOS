//
//  License.h
//  Taxinomes
//
//  Created by Pierre-Loup on 11/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface License : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * abbr;

+ (License *)licenseWithXMLRPCResponse: (NSDictionary *) response ;
+ (NSArray *)allLicenses;

@end
