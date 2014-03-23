//
//  LTSectionsViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTTableViewController.h"

@class LTSection;

@interface LTSectionsViewController : LTTableViewController

@property (nonatomic, strong) LTSection* section;

@end
