//
//  LTTestCase.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface LTTestCase : XCTestCase

-(void)waitForAsyncOperationWithTimeout:(NSTimeInterval)timeout; //!< Wait for one async operation
-(void)waitForAsyncOperations:(NSUInteger)count withTimeout:(NSTimeInterval)timeout; //!< Wait for multiple async operations
-(void)waitForTimeout:(NSTimeInterval)timeout; //!< Wait for a fixed amount of time
-(void)notifyAsyncOperationDone; //!< notify any waiter that the async op is done

@end
