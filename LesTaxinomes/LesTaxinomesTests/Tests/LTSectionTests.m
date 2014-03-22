//
//  LTSectionTests.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTTestCase.h"

#import "LTSection+Business.h"
#import "OHHTTPStubs.h"

@interface LTSectionTests : LTTestCase

@end

@implementation LTSectionTests

- (void)setUp
{
    [super setUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [MagicalRecord cleanUp];
    [super tearDown];
}

- (void)testSectionWithoutChildren
{
    
    
    NSString* fixturePath = OHPathForFileInBundle(@"section-without-children.json",nil);
    NSData* fixtureData = [NSData dataWithContentsOfFile:fixturePath];
    NSDictionary* sectionDict = [NSJSONSerialization JSONObjectWithData:fixtureData
                                                                options:0
                                                                  error:nil];
    NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
    NSError* parseError;
    
    LTSection* section = [LTSection sectonWithJSONResponse:sectionDict
                                                 inContext:context
                                                     error:&parseError];
    
    XCTAssertNil(parseError, @"error should be nil");
    XCTAssertNotNil(section, @"section should no be nil");
    XCTAssertNotNil(section.identifier, @"section's identifier should not be nil");
    XCTAssertNotNil(section.title, @"section's title should not be nil");
    
    NSInteger expectedChidren = 0;
    XCTAssertEqual((NSInteger)[[section children] count], expectedChidren, @"Section's chidren number is %d. Expected %d", [[section children] count], expectedChidren);
}

- (void)testSectionWithChildren
{
    
    
    NSString* fixturePath = OHPathForFileInBundle(@"section-with-children.json",nil);
    NSData* fixtureData = [NSData dataWithContentsOfFile:fixturePath];
    NSDictionary* sectionDict = [NSJSONSerialization JSONObjectWithData:fixtureData
                                                                options:0
                                                                  error:nil];
    NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
    NSError* parseError;
    
    LTSection* section = [LTSection sectonWithJSONResponse:sectionDict
                                                 inContext:context
                                                     error:&parseError];
    
    XCTAssertNil(parseError, @"error should be nil");
    XCTAssertNotNil(section, @"section should no be nil");
    XCTAssertNotNil(section.identifier, @"section's identifier should not be nil");
    XCTAssertNotNil(section.title, @"section's title should not be nil");
    
    NSInteger expectedChidren = 21;
    XCTAssertEqual((NSInteger)[[section children] count], expectedChidren, @"Section's chidren number is %d. Expected %d", [[section children] count], expectedChidren);
}

@end
