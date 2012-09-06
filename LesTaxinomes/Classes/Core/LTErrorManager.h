//
//  LTErrorManager.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 31/08/12.
//  Copyright (c) 2012  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTErrorManager : NSObject
+ (LTErrorManager *)sharedErrorManager;
- (void)manageError:(NSError *)error;
@end
