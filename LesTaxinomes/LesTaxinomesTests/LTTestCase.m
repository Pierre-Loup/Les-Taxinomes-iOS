//
//  LTTestCase.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTTestCase.h"

@interface LTTestCase ()
@property(atomic, assign) NSUInteger asyncTestCaseSignaledCount;
@end

static const NSTimeInterval kRunLoopSamplingInterval = 0.01;

@implementation LTTestCase

-(void)waitForAsyncOperationWithTimeout:(NSTimeInterval)timeout
{
    [self waitForAsyncOperations:1 withTimeout:timeout];
}

-(void)waitForAsyncOperations:(NSUInteger)count withTimeout:(NSTimeInterval)timeout
{
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while ((self.asyncTestCaseSignaledCount < count) && ([timeoutDate timeIntervalSinceNow]>0))
    {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopSamplingInterval, YES);
    }
    
    // Reset the counter for next time, in case we call this method again later
    // (don't reset it at the beginning of the method because we should be able to call
    // notifyAsyncOperationDone *before* this method if we wanted to)
    self.asyncTestCaseSignaledCount = 0;
    
    if ([timeoutDate timeIntervalSinceNow]<0)
    {
        // now is after timeoutDate, we timed out
        XCTFail(@"Timed out while waiting for Async Operations to finish.");
    }
}

-(void)waitForTimeout:(NSTimeInterval)timeout
{
    NSDate* waitEndDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while ([waitEndDate timeIntervalSinceNow]>0)
    {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopSamplingInterval, YES);
    }
}

-(void)notifyAsyncOperationDone
{
    @synchronized(self)
    {
        self.asyncTestCaseSignaledCount = self.asyncTestCaseSignaledCount+1;
    }
}

@end
