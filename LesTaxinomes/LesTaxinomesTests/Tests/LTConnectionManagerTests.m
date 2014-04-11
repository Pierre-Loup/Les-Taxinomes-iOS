//
//  LTConnectionManagerTests.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTTestCase.h"

#import "OHHTTPStubs.h"

#import "LTAuthor.h"
#import "LTMedia.h"
#import "LTSection.h"
#import "LTConnectionManager.h"

static NSTimeInterval const LTDefaultTestTimeout = 5.0;
static NSString* const LTDefaultRangeString = @"0,10";

@interface LTConnectionManagerTests : LTTestCase

@property (nonatomic, strong) NSError* error;

@end

@implementation LTConnectionManagerTests

- (void)setUp
{
    [super setUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.error = nil;
    [MagicalRecord cleanUp];
    [super tearDown];
}

//- (void)test01_authWithLogin_password {
//    [self prepare];
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm authWithLogin:@"test1"
//             password:@"testtest"
//        responseBlock:^(LTAuthor *authenticatedUser, NSError *error) {
//            if (authenticatedUser && !error) {
//                [self notify:kXCTUnitWaitStatusSuccess];
//            } else {
//                [self notify:kXCTUnitWaitStatusFailure];
//            }
//        }];
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//}
//
//- (void)test02_authWithCookie{
//    [self prepare];
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm authWithLogin:nil
//             password:nil
//        responseBlock:^(LTAuthor *authenticatedUser, NSError *error) {
//            if (authenticatedUser && !error) {
//                [self notify:kXCTUnitWaitStatusSuccess];
//            } else {
//                [self notify:kXCTUnitWaitStatusFailure];
//            }
//        }];
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//}
//
//- (void)test03_getLicenses {
//    
//    [self prepare];
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm getLicensesWithResponseBlock:^(NSArray *licenses, NSError *error) {
//        if (licenses &&
//            ([licenses count] > 0) &&
//            !error) {
//            [self notify:kXCTUnitWaitStatusSuccess];
//        } else {
//            [self notify:kXCTUnitWaitStatusFailure];
//        }
//    }];
//    
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//}
//
//- (void)test04_getShortMediasByDate {
//    
//    [self prepare];
//    NSRange mediasRange = kDefaultRange;
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm fetchMediasSummariesByDateForAuthor:nil
//                         nearLocation:nil
//                            withRange:mediasRange
//                        responseBlock:^(NSArray *medias, NSError *error) {
//                            if (medias &&
//                                [medias count] &&
//                                !error) {
//                                [self notify:kXCTUnitWaitStatusSuccess];
//                            } else {
//                                
//                                [self notify:kXCTUnitWaitStatusFailure];
//                            }
//                        }];
//    
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//}
//
//- (void)test05_getShortMediasByDate_forAuthor {
//    
//    [self prepare];
//    NSRange mediasRange = kDefaultRange;
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm fetchMediasSummariesByDateForAuthor:kDefaultAuthor
//                             nearLocation:nil
//                                withRange:mediasRange
//    responseBlock:^(NSArray *medias, NSError *error)
//     {
//         if (medias &&
//             [medias count] &&
//             !error) {
//             [self notify:kXCTUnitWaitStatusSuccess];
//         } else {
//             
//             [self notify:kXCTUnitWaitStatusFailure];
//         }
//     }];
//    
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//}
//
//- (void)test06_getShortMediasByDate_nearLocation {
//    
//    [self prepare];
//    NSRange mediasRange = kDefaultRange;
//    CLLocation* location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
//    
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm fetchMediasSummariesByDateForAuthor:nil
//                         nearLocation:location
//                            withRange:mediasRange
//                        responseBlock:^(NSArray *medias, NSError *error) {
//                            if (medias &&
//                                [medias count] &&
//                                !error) {
//                                [self notify:kXCTUnitWaitStatusSuccess];
//                            } else {
//                                
//                                [self notify:kXCTUnitWaitStatusFailure];
//                            }
//                        }];
//    
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//}
//
//- (void)test07_getMediaWithId {
//    
//    [self prepare];
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm getMediaWithId:kDefaultMedia.identifier
//         responseBlock:^(Media *media, NSError *error) {
//             if (media && !error) {
//                 [self notify:kXCTUnitWaitStatusSuccess];
//             } else {
//                 [self notify:kXCTUnitWaitStatusFailure];
//             }
//         }];
//    
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//    
//}
//
//- (void)test08_getAuthorWithId {
//    
//    [self prepare];
//    
//    LTConnectionManager* cm = [LTConnectionManager sharedManager];
//    [cm getAuthorWithId:kDefaultAuthor.identifier
//          responseBlock:^(LTAuthor *author, NSError *error) {
//              if (author && !error) {
//                  [self notify:kXCTUnitWaitStatusSuccess];
//              } else {
//                  [self notify:kXCTUnitWaitStatusFailure];
//              }
//          }];
//    
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:kDefaultTestTimeout];
//    
//}

- (void)testFetchFullTree
{
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
    {
        return YES;
        
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request)
    {
        NSString* filePath = OHPathForFileInBundle(@"fetchFullTree.json",nil);
        NSData* fixtureData = [NSData dataWithContentsOfFile:filePath];
        return [OHHTTPStubsResponse responseWithData:fixtureData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];
    }];
    
    [[LTConnectionManager sharedManager] fetchFullTreeWithCompletion:^(NSError *error)
    {
        self.error = error;
        [self notifyAsyncOperationDone];
    }];
    
    [self waitForAsyncOperationWithTimeout:LTDefaultTestTimeout];
    
    XCTAssertNil(self.error, @"error should be nil");
    
    NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
    NSArray* sections = [LTSection MR_findAllInContext:context];
    NSInteger expectedSections = 779;
    XCTAssertEqual((NSInteger)[sections count], expectedSections, @"Section number is %d. Expected %d", [sections count], expectedSections);
}



@end
