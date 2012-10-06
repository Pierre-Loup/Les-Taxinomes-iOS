//
//  LTConnectionManager_tests.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 30/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "LTConnectionManager.h"

#define kDefaultTestTimeout 5.0
#define kDefaultRange NSRangeFromString(@"0,10")
#define kDefaultMedia ((Media *)[[Media allMedias] objectAtIndex:0])
#define kDefaultAuthor ((Author *)[Author authorWithIdentifier:[NSNumber numberWithInt:211]])


@interface LTConnectionManagerTest : GHAsyncTestCase { }
@end

@implementation LTConnectionManagerTest

- (void)setUpClass {
    [MagicalRecordHelpers setupCoreDataStackWithInMemoryStore];
}

- (void)test01_authWithLogin_password {
    [self prepare];
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm authWithLogin:@"test1"
             password:@"testtest"
        responseBlock:^(NSString *login, NSString *password, Author *authenticatedUser, NSError *error) {
            if (authenticatedUser && !error) {
                [self notify:kGHUnitWaitStatusSuccess];
            } else {
                [self notify:kGHUnitWaitStatusFailure];
            }
        }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

- (void)test02_authWithCookie{
    [self prepare];
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm authWithLogin:nil
             password:nil
        responseBlock:^(NSString *login, NSString *password, Author *authenticatedUser, NSError *error) {
            if (authenticatedUser && !error) {
                [self notify:kGHUnitWaitStatusSuccess];
            } else {
                [self notify:kGHUnitWaitStatusFailure];
            }
        }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

- (void)test03_getLicenses {
    
    [self prepare];
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm getLicensesWithResponseBlock:^(NSArray *licenses, NSError *error) {
        if (licenses &&
            ([licenses count] > 0) &&
            !error) {
            [self notify:kGHUnitWaitStatusSuccess];
        } else {
            [self notify:kGHUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
}

- (void)test04_getShortMediasByDate {
    
    [self prepare];
    NSRange mediasRange = kDefaultRange;
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm getShortMediasByDateForAuthor:nil
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

- (void)test05_getShortMediasByDate_forAuthor {
    
    [self prepare];
    NSRange mediasRange = kDefaultRange;
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm getShortMediasByDateForAuthor:kDefaultAuthor
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

- (void)test06_getShortMediasByDate_nearLocation {
    
    [self prepare];
    NSRange mediasRange = kDefaultRange;
    CLLocation* location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm getShortMediasByDateForAuthor:nil
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

- (void)test07_getMediaWithId {
    
    [self prepare];
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm getMediaWithId:kDefaultMedia.identifier
         responseBlock:^(NSNumber *mediaIdentifier, Media *media, NSError *error) {
             if (media && !error) {
                 [self notify:kGHUnitWaitStatusSuccess];
             } else {
                 [self notify:kGHUnitWaitStatusFailure];
             }
         }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
    
}

- (void)test08_getAuthorWithId {
    
    [self prepare];
    
    LTConnectionManager* cm = [LTConnectionManager sharedConnectionManager];
    [cm getAuthorWithId:kDefaultAuthor.identifier
         responseBlock:^(NSNumber *authorIdentifier, Author *author, NSError *error) {
             if (author && !error) {
                 [self notify:kGHUnitWaitStatusSuccess];
             } else {
                 [self notify:kGHUnitWaitStatusFailure];
             }
         }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
    
}

@end
