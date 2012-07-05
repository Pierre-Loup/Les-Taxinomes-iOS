//
//  MediaSynchGap.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 11/05/12.
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

#import "LTDataManager.h"
#import "MediaSynchGap.h"
#import "Media.h"

#define kMediaSynchGapEntityName @"MediaSynchGap"

@implementation MediaSynchGap

@dynamic medias;

+ (void)addGapWithMediaMax:(Media *)mediaMax min:(Media *)mediaMin {
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    MediaSynchGap * gap = (MediaSynchGap *)[NSEntityDescription insertNewObjectForEntityForName:kMediaSynchGapEntityName inManagedObjectContext:context];
    [gap addMediasObject:mediaMax];
    [gap addMediasObject:mediaMin];
}

+ (NSArray *)allMediaSynchGap {
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] init];
    /*
    sortDescriptor.comparator = ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }
     */
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    if (mutableFetchResults == nil) {
        return nil;
    }
    
    return [mutableFetchResults autorelease];
}

@end
