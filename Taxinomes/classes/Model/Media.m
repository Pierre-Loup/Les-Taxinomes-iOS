//
//  Media.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 06/05/12.
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

#import "Media.h"
#import "Author.h"
#import "License.h"
#import "Section.h"
#import "LTDataManager.h"

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

+ (Media *)mediaWithXMLRPCResponse:(NSDictionary *)response {
    
    if(response == nil){
        return nil;
    }
    
    NSNumber * mediaIdentifier = nil;
    if ([[response objectForKey:@"id_article"] isKindOfClass:[NSString class]]
        && [[response objectForKey:@"statut"] isEqualToString:@"publie"]) {
        NSString * strMediaIdentifier = (NSString *)[response objectForKey:@"id_article"];
        mediaIdentifier = [NSNumber numberWithInt:[strMediaIdentifier intValue]];
    } else {
        return nil;
    }
    
    NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];;
    
    Media *media = [Media mediaWithIdentifier:mediaIdentifier];
    
    if (!media) {
        media = (Media *)[NSEntityDescription insertNewObjectForEntityForName:kMediaEntityName inManagedObjectContext:context];
        media.identifier = mediaIdentifier;
        
        
        
    }
    
    if ([response objectForKey:@"titre"]) {
        media.title = [response objectForKey:@"titre"];
    }
    
    if ([response objectForKey:@"texte"]) {
        media.text = [response objectForKey:@"texte"];
    }
    
    if ([response objectForKey:@"statut"]) {
        media.status = [response objectForKey:@"statut"];
    }
    if ([response objectForKey:@"date"]) {
        NSString *strDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date"]];
        NSDate *date = [[[NSDate alloc] initWithString:strDateDesc] autorelease];
        if(date != nil)
            media.date = date;
        else
            media.date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if ([response objectForKey:@"visites"]) {
        NSString * visits = [response objectForKey:@"visites"];
        media.visits = [NSNumber numberWithInteger:[visits integerValue]];
    }
    
    if ([response objectForKey:@"popularite"]) {
        NSString * popularity = [response objectForKey:@"popularite"];
        media.popularity = [NSNumber numberWithFloat:[popularity floatValue]];
    }
    
    if ([response objectForKey:@"date_modif"]) {
        NSString *strUpdateDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date_modif"]];
        NSDate *updateDate = [[[NSDate alloc] initWithString:strUpdateDateDesc] autorelease];
        if(updateDate != nil)
            media.updateDate = updateDate;
        else
            media.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    // Thumbnail image
    if ([response objectForKey:@"vignette"]) {
        media.mediaThumbnailUrl = [response objectForKey:@"vignette"];
    }
    media.mediaThumbnailLocalFile = @"";
    // Medium image
    media.mediaMediumLocalFile = @"";
    if ([response objectForKey:@"document"]) {
        media.mediaMediumURL = [response objectForKey:@"document"];
    }
    // Large image
    media.mediaLargeURL = @"";
    media.mediaLargeLocalFile = @"";
    
    if ([response objectForKey: @"id_licence"]) {
        NSInteger licenceId = [[response objectForKey: @"id_licence"] intValue];
        media.license = [License licenseWithIdentifier:[NSNumber numberWithInt:licenceId]];
    }
    
    if([[response objectForKey:@"auteurs"] isKindOfClass:[NSArray class]]){
        NSDictionary * authorDict = [[response objectForKey:@"auteurs"] objectAtIndex:0];
        media.author = [Author authorWithXMLRPCResponse:authorDict];
    }
    
    if ([[response objectForKey:@"gis"] isKindOfClass:[NSArray class]]) {
        NSDictionary * gisDict = [[response objectForKey:@"gis"] objectAtIndex:0];
        NSString *strLatitude = [gisDict objectForKey:@"lat"];
        NSString *strLongitude = [gisDict objectForKey:@"lon"];
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

+ (Media *)mediaLargeURLWithXMLRPCResponse:(NSDictionary *)response {
    if(response == nil){
        return nil;
    }
    
    NSNumber * mediaIdentifier = nil;
    if ([[response objectForKey:@"id_article"] isKindOfClass:[NSString class]]) {
        NSString * strMediaIdentifier = (NSString *)[response objectForKey:@"id_article"];
        mediaIdentifier = [NSNumber numberWithInt:[strMediaIdentifier intValue]];
    } else {
        return nil;
    }
    
    Media *media = [Media mediaWithIdentifier:mediaIdentifier];
    
    if (!media) {
        return nil;
    }
    
    media.mediaMediumLocalFile = @"";
    if ([response objectForKey:@"document"]) {
        media.mediaLargeURL = [response objectForKey:@"document"];
    }
    return media;
}

+ (Media *)mediaWithIdentifier:(NSNumber *)identifier {
    NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];;
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
        LogDebug(@"[WARNING] multiple records (%d) in database for id %d",[mutableFetchResults count],[identifier intValue]);
        return [mutableFetchResults objectAtIndex:0];
    } else {
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

+ (NSArray *)allMedias {
    NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];;
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
    return [Media allSynchMediasForAuthor:nil];
}

+ (NSArray *)allSynchMediasForAuthor:(Author *)author {
    LTDataManager * dataManager = [LTDataManager sharedDataManager];
    if (dataManager.synchLimit == 0) {
        return [NSArray array];
    }
    
    NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.fetchLimit = dataManager.synchLimit;
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    
    if (author) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K.%K == %d",kMediaEntityAuthorsField, kAuthorEntityIdentifierField,[author.identifier intValue]];
        LogDebug(@"%@",predicate.predicateFormat);
        [request setPredicate:predicate];
    }
    
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

+ (void)deleteAllMedias {
    NSArray* allMedias = [self allMedias];
    for (Media* media in allMedias) {
        [[NSManagedObjectContext MR_contextForCurrentThread] deleteObject:media];
    }
}

#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
}


@end
