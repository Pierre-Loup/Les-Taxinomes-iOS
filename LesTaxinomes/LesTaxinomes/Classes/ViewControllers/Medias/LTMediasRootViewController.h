//
//  MediasListViewController.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 07/11/11.
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

#import <UIKit/UIKit.h>
#import "LTAuthor.h"
#import "LTSection.h"
#import "LTViewController.h"

@interface LTMediasRootViewController : LTViewController

@property (nonatomic, strong) LTAuthor *currentUser;
@property (nonatomic, strong) LTSection *section;
@property (nonatomic, readonly) NSArray* medias;
@property (nonatomic, readonly) BOOL isFetchingMedias;

- (void)loadMoreMediaWithCompletion:(void (^)(NSArray* medias, NSError *error))completion;
- (void)refreshMediasWithCompletion:(void (^)(NSArray* medias, NSError *error))completion;

@end

