//
//  Author.m
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

#import "Author.h"
#import "LTDataManager.h"


@implementation Author

@dynamic identifier;
@dynamic name;
@dynamic biography;
@dynamic signupDate;
@dynamic avatarURL;
@dynamic localUpdateDate;
@dynamic status;

+ (Author*)authorWithXMLRPCResponse:(NSDictionary*)response {
    
    if(response == nil){
        return nil;
    }
    
    NSNumber * authorIdentifier = nil;
    if ([[response objectForKey:@"id_auteur"] isKindOfClass:[NSString class]]) {
        NSString * strAuthorIdentifier = (NSString *)[response objectForKey:@"id_auteur"];
        authorIdentifier = [NSNumber numberWithInt:[strAuthorIdentifier intValue]];
    } else {
        return nil;
    }
    
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    
    Author *author = [Author authorWithIdentifier:authorIdentifier];
    if (!author) {
        Author *author = (Author *)[NSEntityDescription insertNewObjectForEntityForName:kAuthorEntityName inManagedObjectContext:context];
        author.identifier = authorIdentifier;
    }
    NSString * authorName = (NSString *)[response objectForKey:@"nom"];
    if (authorName && ![authorName isEqualToString:@""]) {
        author.name = [response objectForKey:@"nom"];
    } else {
        author.name = kNoAuthorName;
    }
    
    author.biography = [response objectForKey:@"bio"];
    
    NSString *strSignupDate = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date_inscription"]];
    NSDate *signupDate = [[[NSDate alloc] initWithString:strSignupDate] autorelease];
    if(signupDate != nil)
        author.signupDate = signupDate;
    else
        author.signupDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    author.avatarURL = [response objectForKey:@"logo"];
    author.localUpdateDate = [NSDate date];
    author.status = [response objectForKey:@"statut"];
    
    if (![context save:nil]) {
        return nil;
    }
    
    return author;
}

+ (Author *)authorWithIdentifier: (NSNumber *)identifier {
    NSManagedObjectContext* context = [[LTDataManager sharedDataManager] mainManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d",kAuthorEntityIdentifierField,[identifier intValue]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kAuthorEntityIdentifierField ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[[context executeFetchRequest:request error:&error] mutableCopy] autorelease];
    [request release];
    if ([mutableFetchResults count] == 0) {
        return nil;
    } else if ([mutableFetchResults count] > 1) {
        return [mutableFetchResults objectAtIndex:0];
    } else {
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

@end
