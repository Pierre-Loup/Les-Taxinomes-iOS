//
//  Author.h
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
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Author : NSObject {
    NSString* _id_author;
    NSString* _name;
    NSString* _biography;
    NSString* _status;
    NSDate* _signupDate;
    NSString* _avatarURL;
    UIImage* _avatar;
    NSDate* _dataReceivedDate;
}

@property (nonatomic, retain) NSString* id_author;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* biography;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSDate* signupDate;
@property (nonatomic, retain) NSString* avatarURL;
@property (nonatomic, retain) UIImage* avatar;
@property (nonatomic, retain) NSDate* dataReceivedDate;

+ (Author *)authorWithXMLRPCResponse: (NSDictionary *) response;

@end
