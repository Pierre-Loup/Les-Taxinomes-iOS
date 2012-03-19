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


@implementation Author

@dynamic identifier;
@dynamic name;
@dynamic biography;
@dynamic signupDate;
@dynamic avatarURL;
@dynamic localUpdateDate;
@dynamic status;

+ (Author*)authorWithXMLRPCResponse:(NSDictionary*)response {
    Author *author = [[[Author alloc] init] autorelease];
    if(response == nil){
        return author;
    }
    
    author.id_author = [response objectForKey:@"id_auteur"]!=nil?[response objectForKey:@"id_auteur"]:@"";
    author.name = [response objectForKey:@"nom"]!=nil?[response objectForKey:@"nom"]:@"";
    author.biography = [response objectForKey:@"bio"]!=nil?[response objectForKey:@"bio"]:@"";
    
    NSString *strSignupDate = [NSString stringWithFormat:@"%@ +0000",[response objectForKey:@"date_inscription"]];
    NSDate *signupDate = [[NSDate alloc] initWithString:strSignupDate];
    if(signupDate != nil)
        author.signupDate = signupDate;
    else
        author.signupDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    author.status = [response objectForKey:@"statut"]!=nil?[response objectForKey:@"statut"]:@"";
    author.avatarURL = [response objectForKey:@"logo"]!=nil?[response objectForKey:@"logo"]:@"";
    
    if(author.avatarURL != @""){
        NSURL *imageUrl = [NSURL URLWithString:author.avatarURL];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        author.avatar = [[UIImage alloc] initWithData:imageData];
    } else {
        author.avatar = [UIImage imageNamed:@"default_avatar.png"];
    }
    
    author.dataReceivedDate = [NSDate date];
    
    /*//DEBUG    
     NSLog(author.id_author);
     NSLog(author.name);
     NSLog(author.biography);
     NSLog([author.signupDate description]);
     NSLog(author.status);
     NSLog(author.avatarURL);
     //*/
    
    [signupDate release];
    
    return author;
}

@end
