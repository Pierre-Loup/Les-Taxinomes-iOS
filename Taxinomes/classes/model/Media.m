//
//  Media.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 19/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
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

@dynamic identifier;
@dynamic title;
@dynamic text;
@dynamic status;
@dynamic date;
@dynamic visits;
@dynamic popularity;
@dynamic updateDate;
@dynamic mediaThumbnailUrl;
@dynamic mediaThumbnailLocalFile;
@dynamic mediaMediumLocalFile;
@dynamic mediaMediumURL;
@dynamic mediaLargeURL;
@dynamic mediaLargeLocalFile;
@dynamic localUpdateDate;
@dynamic latitude;
@dynamic longitude;
@dynamic license;
@dynamic authors;
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
    
    media.title = [response objectForKey:kTitleTag];
    media.text = [response objectForKey:kTextTag]?[response objectForKey:kTextTag]:kNoDescription;
    media.status = [response objectForKey:kStatusTag];
    NSString *strDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:kDateTag]];
    NSDate *date = [[[NSDate alloc] initWithString:strDateDesc] autorelease];
    if(date != nil)
        media.date = date;
    else
        media.date = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSString * visits = [response objectForKey:kVisitsTag]!=nil?[response objectForKey:kVisitsTag]:@"0";
    media.visits = [NSNumber numberWithInteger:[visits integerValue]];
    CGFloat popularity = [response objectForKey:kPopularityTag]!=nil?[[response objectForKey:kPopularityTag] floatValue]:0.0;
    media.popularity = [NSNumber numberWithFloat:popularity];
    
    NSString *strUpdateDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:kModifyDateTag]];
    NSDate *updateDate = [[[NSDate alloc] initWithString:strUpdateDateDesc] autorelease];
    if(updateDate != nil)
        media.updateDate = updateDate;
    else
        media.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    media.mediaThumbnailUrl = [response objectForKey:kMediaThumbnailTag];
    
    media.mediaThumbnailLocalFile = @"";
    media.mediaMediumLocalFile = @"";
    media.mediaMediumURL = [response objectForKey:kMediaMediumImageTag];
    media.mediaLargeURL = @"";
    media.mediaLargeLocalFile = @"";
    media.localUpdateDate = [NSDate date];
    
    NSInteger licenceId = [[response objectForKey:kLicenseTag] intValue];
    media.license = [License licenseWithIdentifier:[NSNumber numberWithInt:licenceId]];
    
    if([[response objectForKey:kAuthorsTag] isKindOfClass:[NSArray class]]){
        NSDictionary * authorDict = [[response objectForKey:kAuthorsTag] objectAtIndex:0];
        media.authors = [Author authorWithXMLRPCResponse:authorDict];
    }
    
    if ([[response objectForKey:kGisTag] isKindOfClass:[NSArray class]]) {
        NSDictionary * gisDict = [[response objectForKey:kGisTag] objectAtIndex:0];
        NSString *strLatitude = [gisDict objectForKey:kGisLatitudeTag];
        NSString *strLongitude = [gisDict objectForKey:kGisLongitudeTag];
        media.longitude = [NSNumber numberWithFloat:[strLongitude floatValue]];
        media.latitude = [NSNumber numberWithFloat:[strLatitude floatValue]];
    }
    
    media.section = nil;
    
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
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
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

@end
