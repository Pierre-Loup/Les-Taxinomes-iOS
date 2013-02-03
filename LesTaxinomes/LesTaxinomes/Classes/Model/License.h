//
//  License.h
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

@interface License : NSManagedObject

@property (nonatomic, strong) NSString* abbr;
@property (nonatomic, strong) NSString* desc;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) NSString* link;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) Media *medias;

+ (License*)licenseWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error;
+ (License*)licenseWithIdentifier:(NSNumber*)identifier;
+ (License*)defaultLicense;
+ (NSArray*)allLicenses;

@end
