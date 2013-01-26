//
//  Author.m
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

#import "Author.h"
#import "Media.h"

@implementation Author

@dynamic avatarURL;
@dynamic biography;
@dynamic identifier;
@dynamic localUpdateDate;
@dynamic name;
@dynamic signupDate;
@dynamic status;
@dynamic medias;

+ (Author*)authorWithXMLRPCResponse:(NSDictionary*)response {
    
    if(response == nil){
        return nil;
    }
    
    NSNumber * authorIdentifier = nil;
    if ([[response objectForKey:@"id_auteur"] isKindOfClass:[NSString class]]) {
        NSString * strAuthorIdentifier = (NSString *)[response objectForKey:@"id_auteur"];
        authorIdentifier = [NSNumber numberWithInt:[strAuthorIdentifier intValue]];
    } else  if ([[response objectForKey:@"id_auteur"] isKindOfClass:[NSNumber class]]) {
        authorIdentifier = [response objectForKey:@"id_auteur"];
    } else {
        return nil;
    }
    
    NSManagedObjectContext* context = [NSManagedObjectContext contextForCurrentThread];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [authorIdentifier integerValue]];
    Author *author = [Author findFirstWithPredicate:predicate inContext:context];
    if (!author) {
        author = [Author createInContext:context];
        author.identifier = authorIdentifier;
        if (author == nil) {
            LogDebug(@"[ERROR] author = nil !!!");
        }
    }
    NSString * authorName = (NSString *)[response objectForKey:@"nom"];
    
    if (authorName && ![authorName isEqualToString:@""]) {
        author.name = [response objectForKey:@"nom"];
    } else {
        author.name = _T(@"common.anonymous");
    }
    
    if ([response objectForKey:@"bio"]) {
        author.biography = [response objectForKey:@"bio"];
    }

    if ([response objectForKey:@"date_inscription"]) {
        NSString *strSignupDate = [response objectForKey:@"date_inscription"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLog(@"%@", [dateFormatter dateFromString:strSignupDate]);
        NSDate *signupDate = [dateFormatter dateFromString:strSignupDate];
        if(signupDate != nil)
            author.signupDate = signupDate;
        else
            author.signupDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if ([response objectForKey:@"logo"]) {
        author.avatarURL = [response objectForKey:@"logo"];
    }

    if ([response objectForKey:@"statut"]) {
        author.status = [response objectForKey:@"statut"];
    }
    
    author.localUpdateDate = [NSDate date];
    
    [context save];
    
    return author;
}

+ (Author *)authorWithIdentifier: (NSNumber *)identifier {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d", [identifier integerValue]];
    Author *author = [Author findFirstWithPredicate:predicate];
    return  author;
}

+ (NSArray *)allAuthors {
    return [Author findAll];
}

@end
