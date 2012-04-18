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
@dynamic license;
@dynamic authors;
@dynamic section;

+ (Media *)mediaWithXMLRPCResponse: (NSDictionary *) response {
    
    if(response == nil){
        return nil;
    }
    
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    
    Media *media = (Media *)[NSEntityDescription insertNewObjectForEntityForName:kMediaEntityName inManagedObjectContext:context];
    
    media.identifier = [response objectForKey:@"id_media"];
    media.title = [response objectForKey:@"titre"];
    media.text = [response objectForKey:@"text"];
    media.status = [response objectForKey:@"statut"];
    NSString *strDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date"]];
    NSDate *date = [[[NSDate alloc] initWithString:strDateDesc] autorelease];
    if(date != nil)
        media.date = date;
    else
        media.date = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSInteger visits = [response objectForKey:@"visites"]!=nil?[[response objectForKey:@"visites"] intValue]:0;
    media.visits = [NSNumber numberWithInt:visits];
    
    CGFloat popularity = [response objectForKey:@"popularite"]!=nil?[[response objectForKey:@"popularite"] floatValue]:0.0;
    media.popularity = [NSNumber numberWithFloat:popularity];
    
    NSString *strUpdateDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date_modif"]];
    NSDate *updateDate = [[[NSDate alloc] initWithString:strUpdateDateDesc] autorelease];
    if(updateDate != nil)
        media.updateDate = updateDate;
    else
        media.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    media.mediaThumbnailUrl = [response objectForKey:@"vignette"];
    
    media.mediaThumbnailLocalFile = @"";
    media.mediaMediumLocalFile = @"";
    media.mediaMediumURL = [response objectForKey:@"document"];
    media.mediaLargeURL = @"";
    media.mediaLargeLocalFile = @"";
    media.localUpdateDate = [NSDate date];
    
    NSInteger licenceId = [[response objectForKey:@"id_licence"] intValue];
    media.license = [License licenseWithIdentifier:[NSNumber numberWithInt:licenceId]];
    
    if([[response objectForKey:@"auteurs"] isKindOfClass:[NSArray class]]){
        NSDictionary *authorDict = [[response objectForKey:@"auteurs"] objectAtIndex:0];
        NSInteger authorId = [[authorDict objectForKey:@"id_auteur"] intValue];
        media.authors = [Author authorWithIdentifier:[NSNumber numberWithInt:authorId]];
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %d",kMediaEntityIdentifierField,[identifier intValue]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kMediaEntityIdentifierField ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        return nil;
    } else if ([mutableFetchResults count] > 1) {
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES];
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
