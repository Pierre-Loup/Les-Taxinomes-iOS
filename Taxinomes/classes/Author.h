//
//  Author.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 19/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

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
