//
//  Author+Business.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 28/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "Author+Business.h"

@implementation Author (Business)

+ (Author*)authorWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error {
    
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
    
    NSString* authorEmail = [response objectForKey:@"email"];
    if (authorName.length) {
        author.emailAddress = authorEmail;
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
    
    [context save:error];
    
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
