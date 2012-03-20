//
//  Section.m
//  Taxinomes
//
//  Created by Pierre-Loup Personnel on 19/03/12.
//  Copyright (c) 2012 Les petits débrouillards Bretagne. All rights reserved.
//

#import "Section.h"


@implementation Section

@dynamic identifier;
@dynamic desc;
@dynamic imageURL;
@dynamic title;
@dynamic parent;

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@]\n%@: %@\n%@: %@\n%@: %@\n%@: %@\n%@: %@\n",NSStringFromClass([self class]),
            kSectionEntityIdentifierField,
            self.identifier,
            kSectionEntityDescriptionField,
            self.desc,
            kSectionEntityImageURLField,
            self.imageURL,
            kSectionEntityTitleField,
            self.title,
            kSectionEntityParentField,
            [NSString stringWithFormat:@"[%@]%@",NSStringFromClass([self.parent class]) ,self.parent.title]];
}

@end
