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
    /*
    Media *media = [[[media alloc] init] autorelease];
    if(response == nil){
        return media;
    }
    
    media.id_media = [response objectForKey:@"id_media"]!=nil?[response objectForKey:@"id_media"]:@"";
    media.title = [response objectForKey:@"titre"]!=nil?[response objectForKey:@"titre"]:@"";
    media.text =[response objectForKey:@"texte"]!=nil?[response objectForKey:@"texte"]:@"";
    
    NSString *strDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date"]];
    NSDate *date = [[NSDate alloc] initWithString:strDateDesc];
    if(date != nil)
        media.date = date;
    else
        media.date = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSString *strUpdateDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date_modif"]];
    NSDate *updateDate = [[NSDate alloc] initWithString:strUpdateDateDesc];
    if(updateDate != nil)
        media.updateDate = updateDate;
    else
        media.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    media.status = [response objectForKey:@"statut"]!=nil?[response objectForKey:@"statut"]:@"";
    //media.id_section = [response objectForKey:@"id_rubrique"]!=nil?[response objectForKey:@"id_rubrique"]:@"";
    //media.id_license = [response objectForKey:@"id_licence"]!=nil?[response objectForKey:@"id_licence"]:@"";
    
    media.popularity = [response objectForKey:@"popularite"]!=nil?[[response objectForKey:@"popularite"] floatValue]:0.0;
    media.visits = [response objectForKey:@"visites"]!=nil?[[response objectForKey:@"visites"] intValue]:0;
    
    media.dataReceivedDate = [NSDate date];
    media.mediaURL = [response objectForKey:@"document"]!=nil?[response objectForKey:@"document"]:@"";
    if(media.mediaURL != @""){
        NSURL *mediaUrl = [NSURL URLWithString:media.mediaURL];
        NSData *mediaData = [NSData dataWithContentsOfURL:mediaUrl];
        media.media = [[UIImage alloc] initWithData:mediaData];
    } else {
        media.media = [UIImage imageNamed:@"lpd_logo.png"];
    }
    
    media.mediaThumbnailURL = [response objectForKey:@"vignette"]!=nil?[response objectForKey:@"vignette"]:@"";
    if(media.mediaThumbnailURL != @""){
        NSURL *mediaThumbnailUrl = [NSURL URLWithString:media.mediaThumbnailURL];
        NSData *mediaThumbnailData = [NSData dataWithContentsOfURL:mediaThumbnailUrl];
        media.mediaThumbnail = [[UIImage alloc] initWithData:mediaThumbnailData];
    } else {
        media.mediaThumbnail = [UIImage imageNamed:@"lpd_logo.png"];
    }
    
    if([[response objectForKey:@"auteurs"] isKindOfClass:[NSArray class]]){
        NSMutableArray *authors = [[NSMutableArray alloc] initWithCapacity:[[response objectForKey:@"auteurs"] count]];
        Author *author;
        for(NSDictionary *authorDict in [response objectForKey:@"auteurs"]){
            author = [[Author alloc] init];
            author.id_author = [authorDict objectForKey:@"id_auteur"];
            author.name = [authorDict objectForKey:@"nom"]!=nil?[authorDict objectForKey:@"nom"]:@"";
            [authors addObject:author];
            [author release];
        }
        media.authors = [NSArray arrayWithArray:authors];
        [authors release];
    }
    
    //DEBUG
     NSLog(media.id_media);
     NSLog(media.id_author);
     NSLog(media.id_section);
     NSLog(media.id_license);
     NSLog([media.date description]);
     NSLog([media.updateDate description]);
     NSLog(media.title);
     NSLog(media.text);
     NSLog(media.status):
     NSLog(@"%f",media.popularity);
     NSLog(@"%d",media.visits);azerty 
    [date release];
    [updateDate release];
    
    return media;
    */
}

@end
