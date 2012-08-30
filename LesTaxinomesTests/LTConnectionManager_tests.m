//
//  LTConnectionManager_tests.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 30/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface LTConnectionManager_tests : GHTestCase { }
@end

@implementation LTConnectionManager_tests

- (void)testStrings {
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNil(string1, nil);
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

@end
