//
//  LTCollectionViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTCollectionViewController.h"
#import "LTCollectionViewFlowLayout.h"

@interface LTCollectionViewController ()
@end

@implementation LTCollectionViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass Overrides

- (id)init
{
    self = [super initWithCollectionViewLayout:[LTCollectionViewFlowLayout new]];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
