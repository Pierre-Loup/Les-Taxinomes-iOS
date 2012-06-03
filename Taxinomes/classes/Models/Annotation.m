//
//  Annotation.m
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 25/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 Les Taxinomes iPhone is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Les Taxinomes iPhone is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

#import "Annotation.h"

@implementation Annotation

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [self setTitle:nil];
    [self setSubtitle:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    return _subtitle;
}

- (void)setTitle:(NSString *)title {    
    if (_title != title) {
        [_title release];
        _title = [title retain];
    }
}

- (void)setSubtitle:(NSString *)subtitle {
    if (_subtitle != subtitle) {
        [_subtitle release];
        _subtitle = [subtitle retain];
    }
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

@end
