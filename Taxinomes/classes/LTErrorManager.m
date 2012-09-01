//
//  LTErrorManager.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 31/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTErrorManager.h"

@implementation LTErrorManager
+ (LTErrorManager *)sharedErrorManager {
    static LTErrorManager* errorManager = nil;
    static dispatch_once_t  errorManagerOnceToken;
    
    dispatch_once(&errorManagerOnceToken, ^{
        errorManager = [[LTErrorManager alloc] init];
    });
    
    return errorManager;
}
@end
