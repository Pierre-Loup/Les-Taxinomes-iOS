//
//  Annotation.h
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 25/04/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation> {
    NSString *_title;
    NSString *_subtitle;
    
    CLLocationCoordinate2D _coordinate;
}

// Getters and setters
- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

@end
