//
//  Media.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/05/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
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

#import "Media.h"
#import "Author.h"
#import "License.h"
#import "Section.h"
#import "LTDataManager.h"

#define kMediaIdTag @"id_article"
#define kTitleTag @"titre"
#define kTextTag @"texte"
#define kStatusTag @"statut"
#define kDateTag @"date"
#define kVisitsTag @"visites"
#define kPopularityTag @"popularite"
#define kModifyDateTag @"date_modif"
#define kMediaThumbnailTag @"vignette"
#define kMediaMediumImageTag @"document"
#define kLicenseTag @"id_licence"
#define kAuthorsTag @"auteurs"
#define kAuthorIdTag @"id_auteur"
#define kGisTag @"gis"
#define kGisLongitudeTag @"lon"
#define kGisLatitudeTag @"lat"

@implementation Media

@dynamic date;
@dynamic identifier;
@dynamic latitude;
@dynamic localUpdateDate;
@dynamic longitude;
@dynamic mediaLargeLocalFile;
@dynamic mediaLargeURL;
@dynamic mediaMediumLocalFile;
@dynamic mediaMediumURL;
@dynamic mediaThumbnailLocalFile;
@dynamic mediaThumbnailUrl;
@dynamic popularity;
@dynamic status;
@dynamic text;
@dynamic title;
@dynamic updateDate;
@dynamic visits;
@dynamic sychGapForDateSorting;
@dynamic author;
@dynamic license;
@dynamic section;

+ (Media *)mediaWithXMLRPCResponse: (NSDictionary *) response {
    
    if(response == nil){
        return nil;
    }
    
    NSNumber * mediaIdentifier = nil;
    if ([[response objectForKey:kMediaIdTag] isKindOfClass:[NSString class]]) {
        NSString * strMediaIdentifier = (NSString *)[response objectForKey:kMediaIdTag];
        mediaIdentifier = [NSNumber numberWithInt:[strMediaIdentifier intValue]];
    } else {
        return nil;
    }
    
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    
    Media *media = [Media mediaWithIdentifier:mediaIdentifier];
    
    if (!media) {
        media = (Media *)[NSEntityDescription insertNewObjectForEntityForName:kMediaEntityName inManagedObjectContext:context];
        media.identifier = mediaIdentifier;
        
        
        
    }
    
    if ([response objectForKey:kTitleTag]) {
        media.title = [response objectForKey:kTitleTag];
    }
    
    if ([response objectForKey:kTextTag]) {
        media.text = [response objectForKey:kTextTag];
    }
    
    if ([response objectForKey:kStatusTag]) {
        media.status = [response objectForKey:kStatusTag];
    }
    if ([response objectForKey:kDateTag]) {
        NSString *strDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:kDateTag]];
        NSDate *date = [[[NSDate alloc] initWithString:strDateDesc] autorelease];
        if(date != nil)
            media.date = date;
        else
            media.date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if ([response objectForKey:kVisitsTag]) {
        NSString * visits = [response objectForKey:kVisitsTag];
        media.visits = [NSNumber numberWithInteger:[visits integerValue]];
    }
    
    if ([response objectForKey:kPopularityTag]) {
        NSString * popularity = [response objectForKey:kPopularityTag];
        media.popularity = [NSNumber numberWithFloat:[popularity floatValue]];
    }
    
    if ([response objectForKey:kModifyDateTag]) {
        NSString *strUpdateDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:kModifyDateTag]];
        NSDate *updateDate = [[[NSDate alloc] initWithString:strUpdateDateDesc] autorelease];
        if(updateDate != nil)
            media.updateDate = updateDate;
        else
            media.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    // Thumbnail image
    if ([response objectForKey:kMediaThumbnailTag]) {
        media.mediaThumbnailUrl = [response objectForKey:kMediaThumbnailTag];
    }
    media.mediaThumbnailLocalFile = @"";
    // Medium image
    media.mediaMediumLocalFile = @"";
    if ([response objectForKey:kMediaMediumImageTag]) {
        media.mediaMediumURL = [response objectForKey:kMediaMediumImageTag];
    }
    // Large image
    media.mediaLargeURL = @"";
    media.mediaLargeLocalFile = @"";
    
    if ([response objectForKey:kLicenseTag]) {
        NSInteger licenceId = [[response objectForKey:kLicenseTag] intValue];
        media.license = [License licenseWithIdentifier:[NSNumber numberWithInt:licenceId]];
    }
    
    if([[response objectForKey:kAuthorsTag] isKindOfClass:[NSArray class]]){
        NSDictionary * authorDict = [[response objectForKey:kAuthorsTag] objectAtIndex:0];
        media.author = [Author authorWithXMLRPCResponse:authorDict];
    }
    
    if ([[response objectForKey:kGisTag] isKindOfClass:[NSArray class]]) {
        NSDictionary * gisDict = [[response objectForKey:kGisTag] objectAtIndex:0];
        NSString *strLatitude = [gisDict objectForKey:kGisLatitudeTag];
        NSString *strLongitude = [gisDict objectForKey:kGisLongitudeTag];
        media.longitude = [NSNumber numberWithFloat:[strLongitude floatValue]];
        media.latitude = [NSNumber numberWithFloat:[strLatitude floatValue]];
    }
    
    media.section = nil;
    
    media.localUpdateDate = [NSDate date];
    
    if (![context save:nil]) {
        return nil;
    }
    
    return media;
    
}

+ (Media *)mediaWithIdentifier: (NSNumber *)identifier {
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d",kMediaEntityIdentifierField,[identifier intValue]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kMediaEntityIdentifierField ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[[context executeFetchRequest:request error:&error] mutableCopy] autorelease];
    [request release];
    if (mutableFetchResults == nil
        || [mutableFetchResults count] == 0) {
        return nil;
    } else if ([mutableFetchResults count] > 1) {
        NSLog(@"[WARNING] multiple records (%d) in database for id %d",[mutableFetchResults count],[identifier intValue]);
        return [mutableFetchResults objectAtIndex:0];
    } else {
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

+ (NSArray *)allMedias {
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kMediaEntityDateField ascending:NO];
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

+ (NSArray *)allSynchMedias {
    LTDataManager * dataManager = [LTDataManager sharedDataManager];
    if (dataManager.synchLimit == 0) {
        return [NSArray array];
    }
    
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.fetchLimit = dataManager.synchLimit;
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kMediaEntityDateField ascending:NO];
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
