//
//  LTConnectionManager.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 09/11/11.
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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imports

#import "LTConnectionManager.h"

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreLocation/CoreLocation.h>

#import "AFJSONRequestOperation.h"
#import "LTAuthor+Business.h"
#import "LTLicense+Business.h"
#import "LTSection+Business.h"
#import "LTMedia+Business.h"
#import "LTXMLRPCClient.h"
#import "LTJSONClient.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "UIImage+Resize.h"
#import "XMLRPCResponse.h"

#define LTConnectionManagerMaxItemsStep 20

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

NSString* const LTConnectionManagerErrorDomain = @"LTConnectionManagerErrorDomain";

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface

@interface LTConnectionManager ()
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LTConnectionManager

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Supermethods overrides


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods
#pragma mark Class Methods

+ (LTConnectionManager *)sharedManager
{
    static LTConnectionManager* connectionManager = nil;
    static dispatch_once_t  connectionManagerOnceToken;
    
    dispatch_once(&connectionManagerOnceToken, ^{
        connectionManager = [[LTConnectionManager alloc] init];
    });
    
    return connectionManager;
}

#pragma mark Instance Methods

- (void)getLicensesWithResponseBlock:(void (^)(NSArray* licenses, NSError *error))responseBlock
{
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodSPIPListeLicences
                     withObject:nil
               authCookieEnable:NO
                        success:^(XMLRPCResponse *response)
     {
         if([response isKindOfClass:[NSDictionary class]])
         {
             NSDictionary* responseDict = (NSDictionary*)response;
             NSMutableArray* licenses = [NSMutableArray array];
             for(NSString *key in (NSDictionary*)response)
             {
                 if ([[responseDict objectForKey:key] isKindOfClass:[NSDictionary class]])
                 {
                     NSDictionary *xmlLicenseDict = [responseDict objectForKey:key];
                     NSError* licenseError;
                     NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
                     LTLicense *license = [LTLicense licenseWithXMLRPCResponse:xmlLicenseDict
                                                                     inContext:context
                                                                         error:&licenseError];
                     if (license && ! licenseError)
                     {
                         [licenses addObject:license];
                         
                         NSError* coredataError;
                         [context save:&coredataError];
                         if (coredataError)
                         {
                             LogError(@"%@", coredataError);
                             if(responseBlock) responseBlock(nil, coredataError);
                         }
                         else
                         {
                             if(responseBlock) responseBlock(licenses, nil);
                         }
                         
                     }
                     else
                     {
                         LogError(@"%@", licenseError);
                         if(responseBlock) responseBlock(nil, licenseError);
                     }
                 }
             }
         }
         else
         {
             NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                  code:LTConnectionManagerInternalError
                                              userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodSPIPListeLicences}];
             if(responseBlock) responseBlock(nil, error);
         }
     } failure:^(NSError *error) {
         if(responseBlock) responseBlock(nil, error);
     }];
    
}

- (AFHTTPRequestOperation*)fetchMediasSummariesByDateForAuthor:(LTAuthor *)author
                                                  nearLocation:(CLLocation *)location
                                                  searchFilter:(NSString *)searchFilter
                                                     withRange:(NSRange)range
                                                 responseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock
{
    
    if(range.length == 0 || range.length > LTConnectionManagerMaxItemsStep)
        range.length = LTConnectionManagerMaxItemsStep;
    NSString* limite = [NSString stringWithFormat:@"%ld,%ld", (long)range.location, (long)range.length];
    NSArray *requestedFields = @[@"id_media", @"titre", @"date", @"statut", @"vignette", @"auteurs", @"gis", @"extension"];
    NSNumber* thumbnailWidth = [NSNumber numberWithDouble:(THUMBNAIL_MAX_WIDHT)];
    NSNumber* thumbnailHeight = [NSNumber numberWithDouble:(THUMBNAIL_MAX_HEIGHT)];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       @{
                                         @"limite":              limite,
                                         @"champs_demandes":     requestedFields,
                                         @"vignette_format":     @"carre",
                                         @"vignette_largeur":    thumbnailWidth,
                                         @"vignette_hauteur":    thumbnailHeight,
                                         @"statut":              @"publie"
                                         }];

    NSMutableArray* sortKeys = [NSMutableArray new];
    NSNumber* authorId = author.identifier;
    if (author)
    {
        [parameters addEntriesFromDictionary:@{@"id_auteur": authorId}];
    }
    
    if (location)
    {
        [parameters setValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude]
                      forKey:@"lat"];
        [parameters setValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude]
                      forKey:@"lon"];
        [sortKeys addObject:@"distance"];
    }
    
    if ([searchFilter length])
    {
        [parameters setValue:searchFilter forKey:@"recherche"];
        [sortKeys addObject:@"titre"];
    }
    
    [sortKeys addObject:@"date DESC"];
    [parameters setValue:sortKeys forKey:@"tri"];
    
    BOOL cookieEnabled = ([LTConnectionManager sharedManager].authenticatedUser.identifier && author.identifier &&
                          [author.identifier isEqualToNumber:[LTConnectionManager sharedManager].authenticatedUser.identifier]);
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    AFHTTPRequestOperation* operation = [xmlrpcClient executeMethod:LTXMLRCPMethodGeoDivListeMedias
                                                         withObject:parameters
                                                   authCookieEnable:cookieEnabled
                                                            success:^(id response)
     {
         if([response isKindOfClass:[NSArray  class]])
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                            {
                                NSMutableArray* mediasInChildContext = [NSMutableArray array];
                                NSManagedObjectContext* context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
                                
                                for(NSDictionary *mediaXML in (NSArray *)response)
                                {
                                    NSError* mediaError;
                                    
                                    LTMedia *mediaObject = [LTMedia mediaWithXMLRPCResponse:mediaXML
                                                                                  inContext:context
                                                                                      error:&mediaError];
                                    if(authorId &&
                                       !mediaObject.author)
                                    {
                                        mediaObject.author = [LTAuthor authorWithIdentifier:authorId
                                                                                  inContext:context];
                                    }
                                    
                                    if (mediaObject && !mediaError)
                                    {
                                        [mediasInChildContext addObject:mediaObject];
                                    }
                                    else
                                    {
                                        LogError(@"%@", mediaError);
                                    }
                                }
                                
                                [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* coredataError)
                                {
                                    NSMutableArray* mediasInDefaultContext = [NSMutableArray new];
                                    NSManagedObjectContext* deflautContext = [NSManagedObjectContext MR_defaultContext];
                                    for (LTMedia* mediaInChildContext in mediasInChildContext)
                                    {
                                        LTMedia* mediaInDefalutContext = [mediaInChildContext MR_inContext:deflautContext];
                                        [mediasInDefaultContext addObject:mediaInDefalutContext];
                                    }
                                    [context reset];
                                    if (coredataError)
                                    {
                                        if(responseBlock) responseBlock(nil, coredataError);
                                    }
                                    else
                                    {
                                        if(responseBlock) responseBlock(mediasInDefaultContext, nil);
                                    }
                                }];
                                
                            });
         } else {
             NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                  code:LTConnectionManagerInternalError
                                              userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodGeoDivListeMedias}];
             
             
             if(responseBlock) responseBlock(nil, error);
             
         }
     } failure:^(NSError *error) {
         if(responseBlock) responseBlock(nil, error);
     }];
    return operation;
}

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock
{
    
    if (!mediaIdentifier) {
        
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        if(responseBlock) responseBlock(nil, error);
        return;
    }
    
    NSNumber* mediaMaxHeight = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT];
    NSNumber* mediaMaxWidth = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT];
    NSDictionary* parameters =  @{
                                  @"id_article"       : mediaIdentifier,
                                  @"document_largeur" : mediaMaxWidth,
                                  @"document_hauteur" : mediaMaxHeight
                                  };
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodGeoDivLireMedia
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {
                            
                            if([response isKindOfClass:[NSDictionary class]])
                            {
                                NSError* error;
                                NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
                                LTMedia *mediaObject = [LTMedia mediaWithXMLRPCResponse:(NSDictionary *)response
                                                                              inContext:context
                                                                                  error:&error];
                                
                                NSError* coredataError;
                                [context save:&coredataError];
                                if (coredataError)
                                {
                                    LogError(@"%@", coredataError);
                                    if(responseBlock) responseBlock(nil, coredataError);
                                }
                                else
                                {
                                    if(responseBlock) responseBlock(mediaObject, nil);
                                }
                            }
                            else
                            {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodGeoDivLireMedia}];
                                
                                if(responseBlock) responseBlock(nil, error);
                                
                            }
                        }
                        failure:^(NSError* error)
     {
         
         if(responseBlock) responseBlock(nil, error);
     }];
}

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier
                 responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock
{
    if (!mediaIdentifier)
    {
        
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        if(responseBlock) responseBlock(nil, error);
        return;
    }
    NSNumber* mediaMaxHeight = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT_LARGE];
    NSNumber* mediaMaxWidth = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT_LARGE];
    NSDictionary* parameters = @{   @"id_article"       : mediaIdentifier,
                                    @"champs_demandes"  : @[ @"id_media", @"document"],
                                    @"document_largeur" : mediaMaxWidth,
                                    @"document_hauteur" : mediaMaxHeight
                                    };
    
    
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodGeoDivLireMedia
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {
                            
                            if([response isKindOfClass:[NSDictionary class]]) {
                                
                                NSError* error;
                                NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
                                LTMedia *mediaObject = [LTMedia mediaLargeURLWithXMLRPCResponse:(NSDictionary *)response
                                                                                      inContext:context
                                                                                          error:&error];
                                
                                NSError* coredataError;
                                [context save:&coredataError];
                                if (coredataError)
                                {
                                    LogError(@"%@", coredataError);
                                    if(responseBlock) responseBlock(nil, coredataError);
                                }
                                else
                                {
                                    if(responseBlock) responseBlock(mediaObject, nil);
                                }
                            }
                            else
                            {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodGeoDivLireMedia}];
                                
                                
                                if(responseBlock) responseBlock(nil, error);
                                
                            }
                        } failure:^(NSError* error) {
                            
                            if(responseBlock) responseBlock(nil, error);
                        }];
}

- (void)getHomeCoversWithResponseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock
{
    NSString* limite = [NSString stringWithFormat:@"%d,%d", 0, LTConnectionManagerMaxItemsStep];
    NSArray *requestedFields = @[@"id_media", @"titre", @"date", @"statut", @"vignette", @"auteurs", @"document", @"extension"];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary:
                                       @{
                                         @"limite":              limite,
                                         @"champs_demandes":     requestedFields,
                                         @"vignette_format":     @"carre",
                                         @"vignette_largeur":    @(THUMBNAIL_MAX_WIDHT),
                                         @"vignette_hauteur":    @(THUMBNAIL_MAX_HEIGHT),
                                         @"document_largeur" :   @(MEDIA_MAX_WIDHT_LARGE),
                                         @"document_hauteur" :   @(MEDIA_MAX_WIDHT_LARGE),
                                         @"tri":                 @[@"date DESC"],
                                         @"statut":              @"publie"
                                         }];
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodGeoDivListeMedias
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response)
     {
         if([response isKindOfClass:[NSArray  class]])
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
             {
                 NSMutableArray *mediasId = [NSMutableArray array];
                 NSManagedObjectContext* context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
                 
                 for(NSDictionary *mediaXML in (NSArray *)response)
                 {
                     NSError* mediaError;
                     
                     [LTMedia mediaWithXMLRPCResponse:mediaXML
                                            inContext:context
                                                error:&mediaError];
                     LTMedia *mediaObject = [LTMedia mediaLargeURLWithXMLRPCResponse:mediaXML
                                                                  inContext:context
                                                                      error:&mediaError];
                     
                     if (mediaObject)
                     {
                         [mediasId addObject:mediaObject.identifier];
                     }
                     else
                     {
                         LogError(@"%@", mediaError);
                     }
                 }
                 
                 NSError* coredataError;
                 [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError*vcoredataError)
                 {
                     [context reset];
                     if (coredataError)
                     {
                         LogError(@"%@", coredataError);
                         dispatch_async(dispatch_get_main_queue(), ^
                         {
                             if(responseBlock) responseBlock(nil, coredataError);
                         });
                     }
                     else
                     {
                         dispatch_async(dispatch_get_main_queue(), ^
                         {
                             NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.identifier IN %@", mediasId];
                             NSArray* medias = [LTMedia MR_findAllWithPredicate:predicate
                                                                      inContext:[NSManagedObjectContext MR_defaultContext]];
                             if(responseBlock) responseBlock(medias, nil);
                         });
                     }
                 }];
             });
         }
         else
         {
             NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                  code:LTConnectionManagerInternalError
                                              userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodGeoDivListeMedias}];
             
             
             if(responseBlock) responseBlock(nil, error);
         }
     }
     failure:^(NSError *error)
     {
         if(responseBlock) responseBlock(nil, error);
     }];
}

- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(LTAuthor *author, NSError *error))responseBlock
{
    if (!authorIdentifier) {
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        if(responseBlock) responseBlock(nil, error);
        return;
    }
    
    NSDictionary* parameters = @{ @"id_auteur" : authorIdentifier };
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodSPIPLireAuteur
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {
                            
                            if([response isKindOfClass:[NSDictionary class]]) {
                                
                                NSError *error;
                                NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
                                LTAuthor *authorObject = [LTAuthor authorWithXMLRPCResponse:response
                                                                                  inContext:context
                                                                                      error:&error];
                                
                                NSError* coredataError;
                                [context save:&coredataError];
                                if (coredataError)
                                {
                                    LogError(@"%@", coredataError);
                                    if(responseBlock) responseBlock(nil, coredataError);
                                }
                                else
                                {
                                    if(responseBlock) responseBlock(authorObject, nil);
                                }
                            }
                            else
                            {
                                NSError *error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodSPIPLireAuteur}];
                                
                                
                                if(responseBlock) responseBlock(nil, error);
                                
                            }
                        } failure:^(NSError* error) {
                            
                            if(responseBlock) responseBlock(nil, error);
                        }];
}

- (void)getAuthorsSummariesWithRange:(NSRange)range
                         withSortKey:(LTAuthorsSortType)sortType
                       responseBlock:(void (^)(NSArray* authors, NSError *error))responseBlock
{
    if(range.length == 0 || range.length > LTConnectionManagerMaxItemsStep)
        range.length = LTConnectionManagerMaxItemsStep;
    
    NSString* limite = [NSString stringWithFormat:@"%ld,%ld", (long)range.location, (long)range.length];
    NSString* sortKey;
    if (sortType == LTAuthorsSortAlphabeticOrder) {
        sortKey = @"nom";
    } else {
        sortKey = @"date_inscription";
    }
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodSPIPListeAuteurs
                     withObject:@{ @"limite": limite, @"tri" : sortKey}
               authCookieEnable:NO
    success:^(id response)
    {
        if([response isKindOfClass:[NSArray  class]])
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
            {
                NSMutableArray* authorsInChildContext = [NSMutableArray array];
                
                NSManagedObjectContext* childContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
                
                for(NSDictionary* authorDict in (NSArray *)response)
                {
                    
                    NSError *authorError;
                    LTAuthor *authorObject = [LTAuthor authorWithXMLRPCResponse:authorDict
                                                                      inContext:childContext
                                                                          error:&authorError];
                    
                    if (authorObject && !authorError)
                    {
                        [authorsInChildContext addObject:authorObject];
                    }
                    else
                    {
                        LogError(@"%@", authorError);
                    }
                }
                
                [childContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* coredataError)
                {
                     NSMutableArray* authorsInDefaultContext = [NSMutableArray new];
                     NSManagedObjectContext* deflautContext = [NSManagedObjectContext MR_defaultContext];
                     for (LTMedia* mediaInChildContext in authorsInChildContext)
                     {
                         LTMedia* mediaInDefalutContext = [mediaInChildContext MR_inContext:deflautContext];
                         [authorsInDefaultContext addObject:mediaInDefalutContext];
                     }
                     [childContext reset];
                     if (coredataError)
                     {
                         if(responseBlock) responseBlock(nil, coredataError);
                     }
                     else
                     {
                         if(responseBlock) responseBlock(authorsInDefaultContext, nil);
                     }
                }];
            });
        }
        else
        {
            NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                 code:LTConnectionManagerInternalError
                                             userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodGeoDivListeMedias}];
            
            
            if(responseBlock) responseBlock(nil, error);
            
        }
    }
    failure:^(NSError *error)
    {
        if(responseBlock) responseBlock(nil, error);
    }];
}

- (void)addMediaWithTitle:(NSString *)title
                     text:(NSString *)text
                  license:(LTLicense *)license
                 location:(CLLocation*)location
                  address:(NSDictionary*)addressDict
                 assetURL:(NSURL *)assetURL
            responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock
{
    
    if (!assetURL)
    {
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        if(responseBlock) responseBlock(nil, error);
    }
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    // Title
    
    if (title) {
        [parameters setValue:title forKey:@"titre"];
    } else {
        [parameters setValue:_T(@"media_upload_no_title") forKey:@"titre"];
    }
    
    //Text
    NSMutableString* fullText = [NSMutableString string];
    if (text) {
        [fullText appendString:text];
    }
    [fullText appendString:_T(@"media_upload.text_prefix")];
    [parameters setValue:fullText forKey:@"texte"];
    
    // License
    if (license)
    {
        [parameters setValue:[NSString stringWithFormat:@"%@",[license.identifier stringValue]] forKey:@"id_licence"];
    }
    
    [parameters setValue:@"publie" forKey:@"statut"];
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
         
         // Media location (GIS)
         NSMutableDictionary* gisDict = [NSMutableDictionary new];
         NSString* latitudeStr = nil;
         NSString* longitudeStr = nil;
         if (location)
         {
             latitudeStr = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
             longitudeStr = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
         }
         else
         {
             NSMutableDictionary* imageMetadata = [NSMutableDictionary dictionaryWithDictionary:[assetRepresentation metadata]];
             latitudeStr = [NSString stringWithFormat:@"%f", [imageMetadata location].coordinate.latitude];
             longitudeStr = [NSString stringWithFormat:@"%f", [imageMetadata location].coordinate.longitude];
         }
         [gisDict addEntriesFromDictionary:@{@"lat" : latitudeStr, @"lon" : longitudeStr}];
         
         if (addressDict)
         {
             NSString* city = addressDict[(NSString*)kABPersonAddressCityKey];
             if ([city length])
             {
                 [gisDict setValue:city forKey:@"ville"];
             }
             
             NSString* zipCode = addressDict[(NSString*)kABPersonAddressZIPKey];
             if ([zipCode length])
             {
                 [gisDict setValue:zipCode forKey:@"code_postal"];
             }
             
             NSString* country = addressDict[(NSString*)kABPersonAddressCountryKey];
             if ([country length])
             {
                 [gisDict setValue:country forKey:@"pays"];
             }
         }
         
         [parameters setValue:gisDict forKey:@"gis"];
         
         // Retrieve the image orientation from the ALAsset
         UIImageOrientation orientation = UIImageOrientationUp;
         NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
         if (orientationValue != nil) {
             orientation = [orientationValue intValue];
         }
         
         // Media
         CGImageRef iref = [assetRepresentation fullResolutionImage];
         if (iref)
         {
             UIImage* mediaImage = [UIImage imageWithCGImage:iref scale:1 orientation:orientation];
             if (mediaImage.size.width > MEDIA_MAX_WIDHT)
             {
                 CGFloat imageHeight = (MEDIA_MAX_WIDHT/mediaImage.size.width)*mediaImage.size.height;
                 CGSize newSize = CGSizeMake(MEDIA_MAX_WIDHT, imageHeight);
                 mediaImage = [mediaImage resizedImageToFitInSize:newSize scaleIfSmaller:YES];
             }
             NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(mediaImage, 1.0f)];
             NSDictionary *document = @{
                                        @"name" : [NSString stringWithFormat:@"%@.jpg",title],
                                        @"type" : @"image/jpeg",
                                        @"bits" : imageData,
                                        };
             
             [parameters setValue:document forKey:@"document"];
             
             LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
             [xmlrpcClient executeMethod:LTXMLRCPMethodGeoDivCreerMedia
                              withObject:parameters
                        authCookieEnable:YES
                     uploadProgressBlock:^(CGFloat progress)
              {
                  if ([self.delegate respondsToSelector:@selector(uploadDeterminationDidUpdate:)])
                  {
                      [self.delegate uploadDeterminationDidUpdate:progress];
                  }
              }
                   downloadProgressBlock:nil
                                 success:^(id response)
              {
                  if([response isKindOfClass:[NSDictionary class]])
                  {
                      NSError *error;
                      NSManagedObjectContext* context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
                      LTMedia *mediaObject = [LTMedia mediaWithXMLRPCResponse:response
                                                                    inContext:context
                                                                        error:&error];
                      
                      NSError *coredataError;
                      [[NSManagedObjectContext MR_contextForCurrentThread] save:&coredataError];
                      if (coredataError) LogError(@"%@",coredataError);
                      
                      if(responseBlock) responseBlock(mediaObject, error);
                      
                  } else {
                      NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                           code:LTConnectionManagerInternalError
                                                       userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodGeoDivCreerMedia}];
                      
                      
                      if(responseBlock) responseBlock(nil, error);
                      
                  }
              } failure:^(NSError* error) {
                  if(responseBlock) responseBlock(nil,error);
              }];
         }
     } failureBlock:^(NSError *error) {
         if(responseBlock) responseBlock(nil,error);
     }];
}

- (void)authWithLogin:(NSString *)login
             password:(NSString *)password
        responseBlock:(void (^)(LTAuthor *authenticatedUser, NSError *error))responseBlock
{
    
    NSMutableArray* identifiers = [NSMutableArray array];
    if (login)
    {
        [identifiers addObject:login];
    }
    if (password)
    {
        [identifiers addObject:password];
    }
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodSPIPAuth
                     withObject:identifiers
               authCookieEnable:YES
                        success:^(id response)
    {
        if([response isKindOfClass:[NSDictionary class]])
        {
            NSError* error;
            NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
            self.authenticatedUser = [LTAuthor authorWithXMLRPCResponse:response
                                                              inContext:context
                                                                  error:&error];
            
            NSError* coredataError;
            [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
             {
                 if (coredataError)
                 {
                     LogError(@"%@", coredataError);
                     if(responseBlock) responseBlock(nil, coredataError);
                 }
                 else
                 {
                     if(responseBlock) responseBlock(self.authenticatedUser, nil);
                 }
             }];
            
        } else {
            NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                 code:LTConnectionManagerInternalError
                                             userInfo:@{LTXMLRPCMethodKey:LTXMLRCPMethodSPIPAuth}];
            
            
            if(responseBlock) responseBlock(nil, error);
            
        }
    }
    failure:^(NSError* error)
    {
        if(responseBlock) responseBlock(nil, error);
    }];
}

- (void)unAuthenticate
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[NSURL URLWithString:LTHTTPHost] absoluteURL]];
    for (NSHTTPCookie * cookie in cookies)
    {
        if([cookie.name isEqualToString:LTSessionCookieName])
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    self.authenticatedUser = nil;
}

- (void)fetchFullTreeWithCompletion:(void (^)(NSError *error))completion
{
    LTJSONClient* jsonClient = [LTJSONClient sharedClient];
    NSDictionary* parameters = @{@"page" : @"arbre.json"};
    NSURLRequest* request = [jsonClient requestWithMethod:@"GET"
                                                     path:nil
                                               parameters:parameters];
    AFJSONRequestOperation* jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if([JSON isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* jsonDict = JSON;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
            {
                NSManagedObjectContext* defaultContext = [NSManagedObjectContext MR_defaultContext];
                NSManagedObjectContext* context = [NSManagedObjectContext MR_contextWithParent:defaultContext];
                
                NSError* error;
                [LTSection sectonWithJSONResponse:jsonDict inContext:context error:&error];
                if (error)
                {
                    LogError(@"%@", error);
                    // Dispatch the result on the main thread
                    dispatch_async(dispatch_get_main_queue(), ^
                                   {
                                       if(completion) completion(error);
                                   });
                }
                else
                {
                    NSError* coredataError;
                    [context save:&coredataError];
                    [context reset];
                    if (coredataError)
                    {
                        LogError(@"%@", coredataError);
                        // Dispatch the result on the main thread
                        dispatch_async(dispatch_get_main_queue(), ^
                                       {
                                           if(completion) completion(coredataError);
                                       });
                    }
                    else
                    {
                        // Dispatch the result on the main thread
                        dispatch_async(dispatch_get_main_queue(), ^
                                       {
                                           if(completion) completion(nil);
                                       });
                    }
                }
            });
        }
        else
        {
            NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                 code:LTConnectionManagerBadResponse
                                             userInfo:nil];
            
            
            if(completion) completion(error);
            
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *afError, id JSON)
    {
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadResponse
                                         userInfo:@{NSUnderlyingErrorKey:afError}];
        
        if(completion) completion(error);
    }];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/plain", nil]];
    [jsonOperation start];
}

@end
