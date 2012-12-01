//
//  UIAlertView+LTErrorAdditions.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 03/11/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "UIAlertView+LTErrorAdditions.h"

#import "AFURLConnectionOperation.h"
#import "LTConnectionManager.h"
#import "LTXMLRPCClient.h"
#import "UIAlertView+MKBlockAdditions.h"

@implementation UIAlertView (LTErrorAdditions)

+(UIAlertView*) showWithError:(NSError*) error {
    
    NSString* title;
    NSString* message;
    
    // External error domains
    if (error.domain == NSURLErrorDomain ||
        error.domain == AFNetworkingErrorDomain) {
        if ([error localizedRecoverySuggestion].length &&
            [error localizedDescription].length) {
            title = [error localizedDescription];
            message = [error localizedRecoverySuggestion];
        } else if ([[error localizedDescription] length]) {
            title = _T(@"error.network.title");
            message = [error localizedDescription];
        } else {
            title = _T(@"error.network.title");
            message = _T(@"error.network.text");
        }
    // Internal error domains
    } else if (error.domain == LTConnectionManagerErrorDomain ||
               error.domain == LTXMLRPCServerErrorDomain) {
        NSString* method = error.userInfo[LTXMLRPCMethodKey];
        if ([method isEqualToString:LTXMLRCPMethodSPIPAuth]) {
            title = _T(@"error.auth_failed.title");
            message = _T(@"error.auth_failed.text");
        } else if ([method isEqualToString:LTXMLRCPMethodGeoDivCreerMedia]) {
            title = _T(@"error.upload_failed.title");
            message = _T(@"error.upload_failed.text");
        } else {
            title = _T(@"error.internal.title");
            message = _T(@"error.internal.text");
        }
    }
      
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"common.ok", @"")
                          otherButtonTitles:nil];
    
    [alert show];
    return alert;
}

@end
