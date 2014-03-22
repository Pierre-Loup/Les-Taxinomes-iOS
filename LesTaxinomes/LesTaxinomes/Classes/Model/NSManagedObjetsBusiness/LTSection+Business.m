//
//  LTSection+Business.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "LTSection+Business.h"

#import "LTConnectionManagerError.h"

static NSString* const LTSectionJSONKeyId       = @"id";
static NSString* const LTSectionJSONKeyName     = @"name";
static NSString* const LTSectionJSONKeyData     = @"data";
static NSString* const LTSectionJSONKeyChildren = @"children";

@implementation LTSection (Business)

+ (LTSection *)sectonWithJSONResponse:(NSDictionary*)response inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    NSString* identifierString = response[LTSectionJSONKeyId];
    NSNumber* identifier = @([identifierString integerValue]);
    LTSection* section = [LTSection MR_findFirstByAttribute:@"identifier"
                                                  withValue:identifier
                                                  inContext:context];
    if (!section)
    {
        section = [LTSection MR_createInContext:context];
        section.identifier = identifier;
    }
    
    if (!section)
    {
        *error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                     code:0
                                 userInfo:nil];
    }
    
    section.title = response[LTSectionJSONKeyName];
    
    NSArray* childrenSections = response[LTSectionJSONKeyChildren];
    if ([childrenSections isKindOfClass:[NSArray class]])
    {
        NSMutableSet* localChidrenSections = [section.children mutableCopy];
        NSMutableSet* updatedChidrenSections = [NSMutableSet set];
        for (NSDictionary* sectionDict in childrenSections)
        {
            LTSection* childSection = [self sectonWithJSONResponse:sectionDict
                                                         inContext:context
                                                             error:error];
            if (*error != nil)
            {
                break;
            }
            
            childSection.parent = section;
            [updatedChidrenSections addObject:childSection];
        }
        
        if (!error)
        {
            // Removed the children sections that are no more linked to the curent section
            [localChidrenSections minusSet:updatedChidrenSections];
            for (LTSection* sectionToRemove in localChidrenSections)
            {
                [sectionToRemove MR_deleteInContext:context];
            }
        }
    }
    
    return section;
}


@end
