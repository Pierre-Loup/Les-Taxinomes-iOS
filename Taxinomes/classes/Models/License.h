//
//  License.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 27/04/12.
//  Copyright (c) 2012 Les Petits Débrouillards Bretagne. All rights reserved.
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

@interface License : NSManagedObject

@property (nonatomic, retain) NSString* abbr;
@property (nonatomic, retain) NSString* desc;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSNumber* identifier;
@property (nonatomic, retain) NSString* link;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) Media *medias;

+ (License *)licenseWithXMLRPCResponse: (NSDictionary *) response;
+ (License *)licenseWithIdentifier: (NSNumber *)identifier;
+ (License *)defaultLicense;
+ (NSArray *)allLicenses;

@end
