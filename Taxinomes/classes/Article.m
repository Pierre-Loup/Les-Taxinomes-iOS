//
//  Article.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 19/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
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

#import "Article.h"
#import "Author.h"
#import "Constants.h"


@implementation Article 

@synthesize id_article =  _id_article;
@synthesize date = _date;
@synthesize popularity = _popularity;
@synthesize text = _text;
@synthesize title = _title;
@synthesize visits = _visits;
@synthesize updateDate = _updateDate;
@synthesize id_license = _id_license;
@synthesize id_section = _id_section;
@synthesize status = _status;
@synthesize dataReceivedDate = _dataReceivedDate;
@synthesize media = _media;
@synthesize mediaURL = _mediaURL;
@synthesize mediaThumbnail = _mediaThumbnail; 
@synthesize mediaThumbnailURL = _mediaThumbnailURL;
@synthesize authors = _authors;



+ (Article *)articleWithXMLRPCResponse: (NSDictionary *) response {
    Article *article = [[[Article alloc] init] autorelease];
    if(response == nil){
        return article;
    }
    
    article.id_article = [response objectForKey:@"id_article"]!=nil?[response objectForKey:@"id_article"]:@"";
    article.title = [response objectForKey:@"titre"]!=nil?[response objectForKey:@"titre"]:@"";
    article.text =[response objectForKey:@"texte"]!=nil?[response objectForKey:@"texte"]:@"";
    
    NSString *strDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date"]];
    NSDate *date = [[NSDate alloc] initWithString:strDateDesc];
    if(date != nil)
        article.date = date;
    else
        article.date = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSString *strUpdateDateDesc = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date_modif"]];
    NSDate *updateDate = [[NSDate alloc] initWithString:strUpdateDateDesc];
    if(updateDate != nil)
        article.updateDate = updateDate;
    else
        article.updateDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    article.status = [response objectForKey:@"statut"]!=nil?[response objectForKey:@"statut"]:@"";
    article.id_section = [response objectForKey:@"id_rubrique"]!=nil?[response objectForKey:@"id_rubrique"]:@"";
    article.id_license = [response objectForKey:@"id_licence"]!=nil?[response objectForKey:@"id_licence"]:@"";
    
    article.popularity = [response objectForKey:@"popularite"]!=nil?[[response objectForKey:@"popularite"] floatValue]:0.0;
    article.visits = [response objectForKey:@"visites"]!=nil?[[response objectForKey:@"visites"] intValue]:0;
    
    article.dataReceivedDate = [NSDate date];
    article.mediaURL = [response objectForKey:@"document"]!=nil?[response objectForKey:@"document"]:@"";
    if(article.mediaURL != @""){
        NSURL *mediaUrl = [NSURL URLWithString:article.mediaURL];
        NSData *mediaData = [NSData dataWithContentsOfURL:mediaUrl];
        article.media = [[UIImage alloc] initWithData:mediaData];
    } else {
        article.media = [UIImage imageNamed:@"lpd_logo.png"];
    }
    
    article.mediaThumbnailURL = [response objectForKey:@"vignette"]!=nil?[response objectForKey:@"vignette"]:@"";
    if(article.mediaThumbnailURL != @""){
        NSURL *mediaThumbnailUrl = [NSURL URLWithString:article.mediaThumbnailURL];
        NSData *mediaThumbnailData = [NSData dataWithContentsOfURL:mediaThumbnailUrl];
        article.mediaThumbnail = [[UIImage alloc] initWithData:mediaThumbnailData];
    } else {
        article.mediaThumbnail = [UIImage imageNamed:@"lpd_logo.png"];
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
        article.authors = [NSArray arrayWithArray:authors];
        [authors release];
    }
    
    /*//DEBUG
    NSLog(article.id_article);
    NSLog(article.id_author);
    NSLog(article.id_section);
    NSLog(article.id_license);
    NSLog([article.date description]);
    NSLog([article.updateDate description]);
    NSLog(article.title);
    NSLog(article.text);
    NSLog(article.status):
    NSLog(@"%f",article.popularity);
    NSLog(@"%d",article.visits);azerty    //*/
    [date release];
    [updateDate release];
    
    return article;
}

-(void)dealloc{
    [_id_article release];
    [_title release];
    [_text release];
    [_id_section release];
    [_status release];
    [_date release];
    [_updateDate release];
    [_id_license release];
    [_dataReceivedDate release];
    [_mediaThumbnailURL release];
    [_mediaURL release];
    [_mediaThumbnail release];
    [_media release];    
    [_authors release];
    
}

@end
