//
//  Media+Business.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 29/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTAuthor+Business.h"
#import "LTLicense+Business.h"
#import "LTMedia+Business.h"

@implementation LTMedia (Business)

+ (LTMedia *)mediaWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error {
    
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
    
    NSManagedObjectContext* context = [NSManagedObjectContext contextForCurrentThread];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d",[mediaIdentifier integerValue]];
    LTMedia *media = [LTMedia findFirstWithPredicate:predicate
                                       inContext:context];
    
    if (!media) {
        media = [LTMedia createInContext:context];
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
        NSString* strDateDesc = [response objectForKey:@"date"];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:strDateDesc];
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
        NSString* strUpdateDateDesc = [response objectForKey:@"date_modif"];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* updateDate = [dateFormatter dateFromString:strUpdateDateDesc];
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
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d",licenceId];
        media.license = [LTLicense findFirstWithPredicate:predicate
                                              inContext:context];
    }
    
    if([[response objectForKey:@"auteurs"] isKindOfClass:[NSArray class]]){
        NSDictionary * authorDict = [[response objectForKey:@"auteurs"] objectAtIndex:0];
        media.author = [LTAuthor authorWithXMLRPCResponse:authorDict error:error];
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
    
    return media;
    
}

+ (LTMedia *)mediaLargeURLWithXMLRPCResponse:(NSDictionary*)response error:(NSError**)error {
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
    
    LTMedia *media = [LTMedia findFirstByAttribute:@"identifier" withValue:mediaIdentifier];
    
    if (!media) {
        return nil;
    }
    
    media.mediaMediumLocalFile = @"";
    if ([response objectForKey:@"document"]) {
        media.mediaLargeURL = [response objectForKey:@"document"];
    }
    
    return media;
}

#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
}

@end
