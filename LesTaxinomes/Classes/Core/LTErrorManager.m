//
//  LTErrorManager.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 31/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTErrorManager.h"
#import "AFNetworking.h"

NSString* const LTServerErrorDomain = @"org.lestaxinomes.app.iphone.LesTaxinomes.ws_error";

@implementation LTErrorManager

+ (LTErrorManager *)sharedErrorManager {
    static LTErrorManager* errorManager = nil;
    static dispatch_once_t  errorManagerOnceToken;
    
    dispatch_once(&errorManagerOnceToken, ^{
        errorManager = [[LTErrorManager alloc] init];
    });
    
    return errorManager;
}

- (void)manageError:(NSError *)error {
    if (error.domain == NSURLErrorDomain) {
        [self manageNSURLError:error];
    } else if (error.domain == AFNetworkingErrorDomain) {
        [self manageAFNetworkingError:error];
    } else if (error.domain == LTServerErrorDomain) {
        [self manageLTServerError:error];
    } else {
        // Do nothing
    }
}

- (void)manageNSURLError:(NSError *)error {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:TRANSLATE(@"error.network.title")
                                                    message:TRANSLATE(@"error.network.text")
                                                   delegate:self
                                          cancelButtonTitle:TRANSLATE(@"common.ok")
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)manageAFNetworkingError:(NSError *)error {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:TRANSLATE(@"error.network.title")
                                                     message:TRANSLATE(@"error.network.text")
                                                    delegate:self
                                           cancelButtonTitle:TRANSLATE(@"common.ok")
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)manageLTServerError:(NSError *)error {
    // Do nothing
}


@end
