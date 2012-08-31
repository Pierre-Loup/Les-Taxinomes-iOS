//
//  LTConnectionManager_tests.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 30/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "LTConnectionManager.h"

#define kDefaultTestTimeout 5.0

@interface LTConnectionManagerTest : GHAsyncTestCase { }
@end

@implementation LTConnectionManagerTest

- (void)setUpClass {
     [MagicalRecordHelpers setupCoreDataStackWithInMemoryStore];
}

- (void)test_get_licenses {
    
    [self prepare];
    
    [[LTConnectionManager sharedConnectionManager] getLicensesWithResponseBlock:^(NSArray *licenses, NSError *error) {
        if (licenses &&
            [licenses count] > 0 &&
            !error) {
            [self notify:kGHUnitWaitStatusSuccess];
        } else {
            
            [self notify:kGHUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

@end
