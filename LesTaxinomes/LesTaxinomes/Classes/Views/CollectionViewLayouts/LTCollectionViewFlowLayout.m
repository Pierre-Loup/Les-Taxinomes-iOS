//
//  LTCollectionViewFlowLayout.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 10/03/13.
//  Copyright (c) 2013  Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTCollectionViewFlowLayout.h"

@implementation LTCollectionViewFlowLayout

- (id)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 8.f;
        self.minimumInteritemSpacing = 8.f;
        self.sectionInset = UIEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
        self.footerReferenceSize = CGSizeMake(320.0, 55.0);
        self.itemSize = CGSizeMake(70.f, 70.f);
    }
    return self;
}

@end
