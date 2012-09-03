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

- (void)test_getShortMediasByDate {
    
    [self prepare];
    NSRange mediasRange;
    mediasRange.location = 0;
    mediasRange.length = 10;
    [[LTConnectionManager sharedConnectionManager] getShortMediasByDateForAuthor:nil
                                                                    nearLocation:nil
                                                                       withRange:mediasRange
    responseBlock:^(Author *author, NSRange range, NSArray *medias, NSError *error) {
        if (medias &&
            [medias count] &&
            !error) {
            [self notify:kGHUnitWaitStatusSuccess];
        } else {
            
            [self notify:kGHUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

- (void)test_getShortMediasByDate_forAuthor {
    
    [self prepare];
    NSRange mediasRange;
    mediasRange.location = 0;
    mediasRange.length = 10;
    [[LTConnectionManager sharedConnectionManager] getShortMediasByDateForAuthor:[[Author allAuthors] objectAtIndex:0]
                                                                    nearLocation:nil
                                                                       withRange:mediasRange
    responseBlock:^(Author *author, NSRange range, NSArray *medias, NSError *error) {
        if (medias &&
            [medias count] &&
            !error) {
            [self notify:kGHUnitWaitStatusSuccess];
        } else {
            
            [self notify:kGHUnitWaitStatusFailure];
        }
   }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

- (void)test_getShortMediasByDate_nearLocation{
    
    [self prepare];
    NSRange mediasRange;
    mediasRange.location = 0;
    mediasRange.length = 10;
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    
    [[LTConnectionManager sharedConnectionManager] getShortMediasByDateForAuthor:nil
                                                                    nearLocation:location
                                                                       withRange:mediasRange
    responseBlock:^(Author *author, NSRange range, NSArray *medias, NSError *error) {
        if (medias &&
            [medias count] &&
            !error) {
            [self notify:kGHUnitWaitStatusSuccess];
        } else {
            
            [self notify:kGHUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

@end
