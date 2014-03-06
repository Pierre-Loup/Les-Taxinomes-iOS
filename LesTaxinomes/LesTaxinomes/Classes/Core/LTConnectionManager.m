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

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreLocation/CoreLocation.h>

#import "LTAuthor+Business.h"
#import "LTLicense+Business.h"
#import "LTSection.h"
#import "LTMedia+Business.h"
#import "LTXMLRPCClient.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "UIImage+Resize.h"
#import "XMLRPCResponse.h"

#define kLTConnectionManagerMaxItemsStep 20

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines & contants

NSString* const LTConnectionManagerErrorDomain = @"org.lestaxinomes.app.iphone.LesTaxinomes.LTConnectionManagerError";

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

+ (LTConnectionManager *)sharedManager {
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
                                              userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodSPIPListeLicences}];
             if(responseBlock) responseBlock(nil, error);
         }
     } failure:^(NSError *error) {
         if(responseBlock) responseBlock(nil, error);
     }];
    
}

- (void)getMediasSummariesByDateForAuthor:(LTAuthor *)author
                             nearLocation:(CLLocation *)location
                                withRange:(NSRange)range
                            responseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock {
    
    if(range.length == 0 || range.length > kLTConnectionManagerMaxItemsStep)
        range.length = kLTConnectionManagerMaxItemsStep;
    NSString* limite = [NSString stringWithFormat:@"%d,%d", range.location,range.length];
    NSArray *requestedFields = @[@"id_media", @"titre", @"date", @"statut", @"vignette", @"auteurs", @"gis"];
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
    
    NSNumber* authorId = author.identifier;
    if (author)
    {
        [parameters addEntriesFromDictionary:@{@"id_auteur": authorId}];
    }
    
    // Optional
    if (location) {
        [parameters setValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude]
                      forKey:@"lat"];
        [parameters setValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude]
                      forKey:@"lon"];
        [parameters setValue:@[@"distance"] forKey:@"tri"];
    } else {
        [parameters setValue:@[@"date DESC"] forKey:@"tri"];
    }
    
    BOOL cookieEnabled = ([LTConnectionManager sharedManager].authenticatedUser.identifier && author.identifier &&
                          [author.identifier isEqualToNumber:[LTConnectionManager sharedManager].authenticatedUser.identifier]);
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodGeoDivListeMedias
                     withObject:parameters
               authCookieEnable:cookieEnabled
                        success:^(id response)
     {
         if([response isKindOfClass:[NSArray  class]])
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                            {
                                NSMutableArray *medias = [NSMutableArray array];
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
                                        [medias addObject:mediaObject];
                                    }
                                    else
                                    {
                                        LogError(@"%@", mediaError);
                                    }
                                }
                                
                                NSError* coredataError;
                                [context save:&coredataError];
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
                                                       if(responseBlock) responseBlock(medias, nil);
                                                   });
                                }
                            });
         } else {
             NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                  code:LTConnectionManagerInternalError
                                              userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodGeoDivListeMedias}];
             
             
             if(responseBlock) responseBlock(nil, error);
             
         }
     } failure:^(NSError *error) {
         if(responseBlock) responseBlock(nil, error);
     }];
}

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(LTMedia *media, NSError *error))responseBlock
{
    
    if (!mediaIdentifier) {
        
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        if(responseBlock) responseBlock(nil, error);
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
                                                                 userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodGeoDivLireMedia}];
                                
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
                                                                 userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodGeoDivLireMedia}];
                                
                                
                                if(responseBlock) responseBlock(nil, error);
                                
                            }
                        } failure:^(NSError* error) {
                            
                            if(responseBlock) responseBlock(nil, error);
                        }];
}

- (void)getHomeCoversWithResponseBlock:(void (^)(NSArray* medias, NSError *error))responseBlock
{
    NSString* limite = [NSString stringWithFormat:@"%d,%d", 0, kLTConnectionManagerMaxItemsStep];
    NSArray *requestedFields = @[@"id_media", @"titre", @"date", @"statut", @"vignette", @"auteurs", @"document"];
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
                     
                     LTMedia *mediaObject = [LTMedia mediaWithXMLRPCResponse:mediaXML
                                                                   inContext:context
                                                                       error:&mediaError];
                     mediaObject = [LTMedia mediaLargeURLWithXMLRPCResponse:mediaXML
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
                                              userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodGeoDivListeMedias}];
             
             
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
                                                                 userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodSPIPLireAuteur}];
                                
                                
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
    if(range.length == 0 || range.length > kLTConnectionManagerMaxItemsStep)
        range.length = kLTConnectionManagerMaxItemsStep;
    
    NSString* limite = [NSString stringWithFormat:@"%d,%d", range.location,range.length];
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
                        success:^(id response) {
                            if([response isKindOfClass:[NSArray  class]]) {
                                
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                                               {
                                                   NSMutableArray* authors = [NSMutableArray array];
                                                   
                                                   NSManagedObjectContext* context = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
                                                   
                                                   for(NSDictionary* authorDict in (NSArray *)response){
                                                       
                                                       NSError *authorError;
                                                       LTAuthor *authorObject = [LTAuthor authorWithXMLRPCResponse:authorDict
                                                                                                         inContext:context
                                                                                                             error:&authorError];
                                                       
                                                       if (authorObject && !authorError) {
                                                           
                                                           [authors addObject:authorObject];
                                                       } else {
                                                           
                                                           LogError(@"%@", authorError);
                                                       }
                                                   }
                                                   
                                                   NSError* coredataError;
                                                   [context save:&coredataError];
                                                   [context reset];
                                                   if (coredataError)
                                                   {
                                                       LogError(@"%@", coredataError);
                                                       // Dispatch the result on the main thread
                                                       dispatch_async(dispatch_get_main_queue(), ^
                                                                      {
                                                                          if(responseBlock) responseBlock(nil, coredataError);
                                                                      });
                                                   }
                                                   else
                                                   {
                                                       // Dispatch the result on the main thread
                                                       dispatch_async(dispatch_get_main_queue(), ^
                                                                      {
                                                                          if(responseBlock) responseBlock(authors, nil);
                                                                      });
                                                   }
                                               });
                            }
                            else
                            {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodGeoDivListeMedias}];
                                
                                
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
    if (license) {
        [parameters setValue:[NSString stringWithFormat:@"%@",[license.identifier stringValue]] forKey:@"id_licence"];
    }
    
    [parameters setValue:@"publie" forKey:@"statut"];
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
         
         // Media location (GIS)
         NSString* latitudeStr = nil;
         NSString* longitudeStr = nil;
         if (location) {
             latitudeStr = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
             longitudeStr = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
         } else {
             NSMutableDictionary* imageMetadata = [NSMutableDictionary dictionaryWithDictionary:[assetRepresentation metadata]];
             latitudeStr = [NSString stringWithFormat:@"%f", [imageMetadata location].coordinate.latitude];
             longitudeStr = [NSString stringWithFormat:@"%f", [imageMetadata location].coordinate.longitude];
         }
         [parameters setValue:@{@"lat" : latitudeStr, @"lon" : longitudeStr} forKey:@"gis"];
         
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
                      NSLog(@"progress: %f",progress);
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
                                                       userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodGeoDivCreerMedia}];
                      
                      
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
    if (login) {
        [identifiers addObject:login];
    }
    if (password) {
        [identifiers addObject:password];
    }
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:LTXMLRCPMethodSPIPAuth
                     withObject:identifiers
               authCookieEnable:YES
                        success:^(id response) {
                            if([response isKindOfClass:[NSDictionary class]])
                            {
                                NSError* error;
                                NSManagedObjectContext* context = [NSManagedObjectContext MR_defaultContext];
                                self.authenticatedUser = [LTAuthor authorWithXMLRPCResponse:response
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
                                    if(responseBlock) responseBlock(self.authenticatedUser, nil);
                                }
                                
                            } else {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{kLTXMLRPCMethodKey:LTXMLRCPMethodSPIPAuth}];
                                
                                
                                if(responseBlock) responseBlock(nil, error);
                                
                            }
                        } failure:^(NSError* error) {
                            if(responseBlock) responseBlock(nil, error);
                        }];
}

- (void)unAuthenticate
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[NSURL URLWithString:kHTTPHost] absoluteURL]];
    for (NSHTTPCookie * cookie in cookies) {
        if([cookie.name isEqualToString:kSessionCookieName]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    self.authenticatedUser = nil;
}

@end
