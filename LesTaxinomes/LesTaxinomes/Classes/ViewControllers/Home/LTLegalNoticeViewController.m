//
//  LegalInformationsViewController.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 06/12/11.
//  Copyright (c) 2011 Les Petits Débrouillards Bretagne. All rights reserved.
//

/*
 
 LesTaxinomes is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 LesTaxinomes is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "LTLegalNoticeViewController.h"

@interface LTLegalNoticeViewController ()
@property (nonatomic, strong) IBOutlet UITextView* cguTextView;
@end

@implementation LTLegalNoticeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _T(@"legal_informations.title");
    self.cguTextView.text = NSLocalizedStringFromTable(@"cgu.text", @"CGU", @"");
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
