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

// XML-RPC response keys
static NSString* const LTMediaIdKey         = @"id_article";
static NSString* const LTMediaStatusKey     = @"statut";
static NSString* const LTMediaTitleKey      = @"titre";
static NSString* const LTMediaTexteKey      = @"texte";
static NSString* const LTMediaDateKey       = @"date";
static NSString* const LTMediaVisitsKey     = @"visites";
static NSString* const LTMediaPopularityKey = @"popularite";
static NSString* const LTMediaEditDateKey   = @"date_modif";
static NSString* const LTMediaThumbnailKey  = @"vignette";
static NSString* const LTMediaExentionKey   = @"extension";
static NSString* const LTMediaDocumentKey   = @"document";
static NSString* const LTMediaLicenceIdKey  = @"id_licence";
static NSString* const LTMediaAuthorIdKey   = @"auteurs";
static NSString* const LTMediaGisKey        = @"gis";
static NSString* const LTMediaGisLatKey     = @"lat";
static NSString* const LTMediaGisLonKey     = @"lon";

// LTMediaType values

static NSString* const LTMediaTypeImageJPGValue = @"jpg";
static NSString* const LTMediaTypeImagePNGValue = @"png";
static NSString* const LTMediaTypeImageGIFValue = @"gif";
static NSString* const LTMediaTypeAudioMP3Value = @"mp3";
static NSString* const LTMediaTypeVideoMP4Value = @"mp4";

@implementation LTMedia (Business)

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (NSString*)title
{
    return self.mediaTitle;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%@ %@", _T(@"common.by"), self.author.name];
}

+ (LTMedia *)mediaWithXMLRPCResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*) context error:(NSError**)error
{
    
    if(response == nil){
        return nil;
    }
    
    NSNumber * mediaIdentifier = nil;
    if ([[response objectForKey:LTMediaIdKey] isKindOfClass:[NSString class]]
        && [[response objectForKey:LTMediaStatusKey] isEqualToString:@"publie"])
    {
        NSString * strMediaIdentifier = (NSString *)[response objectForKey:LTMediaIdKey];
        mediaIdentifier = [NSNumber numberWithInt:[strMediaIdentifier intValue]];
    }
    else
    {
        return nil;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d",[mediaIdentifier integerValue]];
    LTMedia *media = [LTMedia MR_findFirstWithPredicate:predicate
                                       inContext:context];
    
    if (!media)
    {
        media = [LTMedia MR_createInContext:context];
        media.identifier = mediaIdentifier;
    }
    
    if ([response objectForKey:LTMediaTitleKey])
    {
        media.mediaTitle = [response objectForKey:LTMediaTitleKey];
    }
    
    if ([response objectForKey:LTMediaTexteKey])
    {
        media.text = [response objectForKey:LTMediaTexteKey];
    }
    
    if ([response objectForKey:LTMediaStatusKey])
    {
        media.status = [response objectForKey:LTMediaStatusKey];
    }
    if ([response objectForKey:LTMediaDateKey])
    {
        NSString* strDateDesc = [response objectForKey:LTMediaDateKey];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *date = [dateFormatter dateFromString:strDateDesc];
        if(date)
        {
            media.date = date;
        }
        else
        {
            media.date = [NSDate dateWithTimeIntervalSince1970:0];
        }
    }
    
    if ([response objectForKey:LTMediaVisitsKey])
    {
        NSString * visits = [response objectForKey:LTMediaVisitsKey];
        media.visits = [NSNumber numberWithInteger:[visits integerValue]];
    }
    
    if ([response objectForKey:LTMediaPopularityKey]) {
        NSString * popularity = [response objectForKey:LTMediaPopularityKey];
        media.popularity = [NSNumber numberWithFloat:[popularity floatValue]];
    }
    
    if ([response objectForKey:LTMediaEditDateKey]) {
        NSString* strUpdateDateDesc = [response objectForKey:LTMediaEditDateKey];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* updateDate = [dateFormatter dateFromString:strUpdateDateDesc];
        if(updateDate != nil)
        {
            media.updateDate = updateDate;
        }
        else
        {
            media.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
        }
    }
    
    // Thumbnail image
    if ([response objectForKey:LTMediaThumbnailKey])
    {
        media.mediaThumbnailUrl = [response objectForKey:LTMediaThumbnailKey];
    }

    if ([[response objectForKey:LTMediaExentionKey] isKindOfClass:[NSString class]])
    {
        NSString* emType = [response objectForKey:LTMediaExentionKey];
        
        if ([emType isEqualToString:LTMediaTypeImageJPGValue] ||
            [emType isEqualToString:LTMediaTypeImagePNGValue] ||
            [emType isEqualToString:LTMediaTypeImageGIFValue])
        {
            media.type = @(LTMediaTypeImage);
        }
        else if ([emType isEqualToString:LTMediaTypeAudioMP3Value])
        {
            media.type = @(LTMediaTypeAudio);
        }
        else if ([emType isEqualToString:LTMediaTypeVideoMP4Value])
        {
            media.type = @(LTMediaTypeVideo);
        }
        else
        {
            media.type = @(LTMediaTypeOther);
        }
    }
    
    // Medium image

    if ([response objectForKey:LTMediaDocumentKey])
    {
        media.mediaMediumURL = [response objectForKey:LTMediaDocumentKey];
    }
    // Large image
    media.mediaLargeURL = @"";
    
    if ([response objectForKey:LTMediaLicenceIdKey])
    {
        NSInteger licenceId = [[response objectForKey:LTMediaLicenceIdKey] intValue];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %d",licenceId];
        media.license = [LTLicense MR_findFirstWithPredicate:predicate
                                              inContext:context];
    }
    
    if([[response objectForKey:LTMediaAuthorIdKey] isKindOfClass:[NSArray class]])
    {
        NSArray* authors = [response objectForKey:LTMediaAuthorIdKey];
        if ([authors count] > 0)
        {
            NSDictionary * authorDict = authors[0];
            media.author = [LTAuthor authorWithXMLRPCResponse:authorDict inContext:context error:error];
        }
    }
    
    if ([[response objectForKey:LTMediaGisKey] isKindOfClass:[NSArray class]])
    {
        NSArray* gisArray = [response objectForKey:LTMediaGisKey];
        if ([gisArray count])
        {
            NSDictionary * gisDict = gisArray[0];
            NSString *strLatitude = [gisDict objectForKey:LTMediaGisLatKey];
            NSString *strLongitude = [gisDict objectForKey:LTMediaGisLonKey];
            media.longitude = [NSNumber numberWithFloat:[strLongitude floatValue]];
            media.latitude = [NSNumber numberWithFloat:[strLatitude floatValue]];
        }
    }
    
    media.section = nil;
    media.localUpdateDate = [NSDate date];
    
    return media;
    
}

+ (LTMedia *)mediaLargeURLWithXMLRPCResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
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
    
    LTMedia *media = [LTMedia MR_findFirstByAttribute:@"identifier"
                                            withValue:mediaIdentifier
                                            inContext:context];
    
    if (!media) {
        return nil;
    }
    
    if ([response objectForKey:@"document"]) {
        media.mediaLargeURL = [response objectForKey:@"document"];
    }
    
    return media;
}

@end
