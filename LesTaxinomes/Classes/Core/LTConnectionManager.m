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

#import "LTConnectionManager.h"

#import <AssetsLibrary/ALAsset.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreLocation/CoreLocation.h>

#import "XMLRPCResponse.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "Media.h"
#import "Author.h"
#import "License.h"
#import "LTXMLRPCClient.h"


NSString* const LTConnectionManagerErrorDomain = @"org.lestaxinomes.app.iphone.LesTaxinomes.LTConnectionManagerError";

@implementation LTConnectionManager

- (void)dealloc {
    [_authenticatedUser release];
	[super dealloc];
}

+ (LTConnectionManager *)sharedConnectionManager {
    static LTConnectionManager* connectionManager = nil;
    static dispatch_once_t  connectionManagerOnceToken;
    
    dispatch_once(&connectionManagerOnceToken, ^{
        connectionManager = [[LTConnectionManager alloc] init];
    });
    
    return connectionManager;
}

- (void)getLicensesWithResponseBlock:(void (^)(NSArray* licenses, NSError *error))responseBlock {
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"spip.liste_licences"
                     withObject:nil
               authCookieEnable:NO
    success:^(XMLRPCResponse *response) {
        if([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary* responseDict = (NSDictionary*)response;
            NSMutableArray* licenses = [NSMutableArray array];
            for(NSString *key in (NSDictionary*)response){
                if ([[responseDict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *xmlLicenseDict = [responseDict objectForKey:key];
                    [licenses addObject:[License licenseWithXMLRPCResponse:xmlLicenseDict]];
                }
                
            }
            responseBlock(licenses, nil);
        } else {
            NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                 code:LTConnectionManagerInternalError
                                             userInfo:@{@"method":@"spip.liste_licences"}];
            responseBlock(nil, error);
        }
     } failure:^(NSError *error) {
         responseBlock(nil, error);
     }];
    
}

- (void)getShortMediasByDateForAuthor:(Author *)author
                         nearLocation:(CLLocation *)location
                            withRange:(NSRange)range
                        responseBlock:(void (^)(Author* author, NSRange range, NSArray* medias, NSError *error))responseBlock {
    
    if(range.length == 0 || range.length > kDefaultLimit)
        range.length = kDefaultLimit;
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
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"geodiv.liste_medias"
                     withObject:parameters
               authCookieEnable:author?YES:NO
    success:^(id response) {
        if([response isKindOfClass:[NSArray  class]]) {
            NSMutableArray *medias = [NSMutableArray array];
            for(NSDictionary *mediaXML in (NSArray *)response){
                Media * mediaObject = [Media mediaWithXMLRPCResponse:mediaXML];
                if (mediaObject) {
                    [medias addObject:mediaObject];
                }
            }
            responseBlock(author, range, medias, nil);
        } else {
            NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                 code:LTConnectionManagerInternalError
                                             userInfo:@{@"method":@"geodiv.liste_medias"}];
            responseBlock(author, range, nil, error);
        }
    } failure:^(NSError *error) {
        responseBlock(author, range, nil, error);
    }];
}

- (void)getMediaWithId:(NSNumber *)mediaIdentifier
         responseBlock:(void (^)(NSNumber* mediaIdentifier, Media* media, NSError *error))responseBlock {
    
    if (!mediaIdentifier) {
        
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        responseBlock(mediaIdentifier, nil, error);
    }
    
    NSNumber* mediaMaxHeight = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT];
    NSNumber* mediaMaxWidth = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT];
    NSDictionary* parameters =  @{
                                    @"id_article"       : mediaIdentifier,
                                    @"document_largeur" : mediaMaxWidth,
                                    @"document_hauteur" : mediaMaxHeight
                                };
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"geodiv.lire_media"
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {
                            
                            if([response isKindOfClass:[NSDictionary class]]) {
                                
                                Media * mediaObject = [Media mediaWithXMLRPCResponse:(NSDictionary *)response];
                                responseBlock(mediaIdentifier, mediaObject, nil);
                                
                            } else {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{@"method":@"geodiv.lire_media"}];
                                responseBlock(mediaIdentifier, nil, error);
                            }
                        } failure:^(NSError* error) {
                            
                            responseBlock(mediaIdentifier, nil, error);
                        }];
}

- (void)getMediaLargeURLWithId:(NSNumber *)mediaIdentifier
                 responseBlock:(void (^)(NSNumber* mediaIdentifier, Media* media, NSError *error))responseBlock {
    if (!mediaIdentifier) {
        
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        responseBlock(mediaIdentifier, nil, error);
        return;
    }
    NSNumber* mediaMaxHeight = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT_LARGE];
    NSNumber* mediaMaxWidth = [NSNumber numberWithDouble:MEDIA_MAX_WIDHT_LARGE];
    NSDictionary* parameters = @{   @"id_article"       : mediaIdentifier,
                                    @"champs_demandes"  : @[ @"id_media", @"document" ],
                                    @"document_largeur" : mediaMaxWidth,
                                    @"document_hauteur" : mediaMaxHeight
                                };
    
    
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"geodiv.lire_media"
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {

                            if([response isKindOfClass:[NSDictionary class]]) {
                                
                                Media * mediaObject = [Media mediaWithXMLRPCResponse:(NSDictionary *)response];
                                responseBlock(mediaIdentifier, mediaObject, nil);
                            } else {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{@"method":@"geodiv.lire_media"}];
                                responseBlock(mediaIdentifier, nil, error);
                            }
                        } failure:^(NSError* error) {
                            
                            responseBlock(mediaIdentifier, nil, error);
                        }];
}

- (void)getAuthorWithId:(NSNumber *)authorIdentifier
          responseBlock:(void (^)(NSNumber* authorIdentifier, Author* author, NSError *error))responseBlock {
    if (!authorIdentifier) {
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        responseBlock(authorIdentifier, nil, error);
        return;
    }
    
    NSDictionary* parameters = @{ @"id_auteur" : authorIdentifier };
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"spip.lire_auteur"
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {
                            
                            if([response isKindOfClass:[NSDictionary class]]) {
                                
                                Author* authorObject = [Author authorWithXMLRPCResponse:(NSDictionary *)response];
                                responseBlock(authorIdentifier, authorObject, nil);
                            } else {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{@"method":@"spip.lire_auteur"}];
                                responseBlock(authorIdentifier, nil, error);
                            }
                        } failure:^(NSError* error) {
                            
                            responseBlock(authorIdentifier, nil, error);
                        }];
}

- (void)addMediaWithTitle:(NSString *)title
                     text:(NSString *)text
                  license:(License *)license
                 assetURL:(NSURL *)assetURL
            responseBlock:(void (^)(NSString* title, NSString* text, License* license, NSURL* assetURL, Media* media, NSError *error))responseBlock {
    
    if (!assetURL) {
        NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                             code:LTConnectionManagerBadArgsError
                                         userInfo:nil];
        responseBlock(title, text, license, assetURL, nil, error);
    }
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    // Title

    if (title) {
        [parameters setValue:title forKey:@"titre"];
    } else {
        [parameters setValue:TRANSLATE(@"media_upload_no_title") forKey:@"titre"];
    }
    
    //Text
    NSMutableString* fullText = [NSMutableString string];
    if (text) {
        [fullText appendString:text];
    }
    [fullText appendString:TRANSLATE(@"media_upload.text_prefix")];
    [parameters setValue:fullText forKey:@"texte"];
    
    // License
    if (license) {
        [parameters setValue:[NSString stringWithFormat:@"%@",[license.identifier stringValue]] forKey:@"id_licence"];
    }

    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];

            // Media location (GIS)
            NSMutableDictionary* imageMetadata = [NSMutableDictionary dictionaryWithDictionary:[assetRepresentation metadata]];
            NSString* latitudeStr = [NSString stringWithFormat:@"%f", [imageMetadata location].coordinate.latitude];
            NSString* longitudeStr = [NSString stringWithFormat:@"%f", [imageMetadata location].coordinate.longitude];
            [parameters setValue:@{@"lat" : latitudeStr, @"lon" : longitudeStr} forKey:@"gis"];
            
            // Retrieve the image orientation from the ALAsset
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
            if (orientationValue != nil) {
                orientation = [orientationValue intValue];
            }
            
            // Media
            CGImageRef iref = [assetRepresentation fullResolutionImage];
            if (iref) {
                UIImage* mediaImage = [[UIImage imageWithCGImage:iref scale:1 orientation:orientation] retain];
                if (mediaImage.size.width > MEDIA_MAX_WIDHT) {
                    CGFloat imageHeight = (MEDIA_MAX_WIDHT/mediaImage.size.width)*mediaImage.size.height;
                    CGSize newSize = CGSizeMake(MEDIA_MAX_WIDHT, imageHeight);
                    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
                    [mediaImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    mediaImage = newImage;
                }
                
                NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(mediaImage, 1.0f)];
                NSDictionary *document = @{
                @"name" : [NSString stringWithFormat:@"%@.jpg",title],
                @"type" : @"image/jpeg",
                @"bits" : imageData,
                };

                [parameters setValue:document forKey:@"document"];
            }
        }
    } failureBlock:^(NSError *error) {
        responseBlock(title,text,license,assetURL,nil,error);
    }];
    [library release];
    
    [parameters setValue:@"publie" forKey:@"statut"];

    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"geodiv.creer_media"
                     withObject:parameters
               authCookieEnable:NO
                        success:^(id response) {
                            if([response isKindOfClass:[NSDictionary class]]) {
                                
                                Media * mediaObject = [Media mediaWithXMLRPCResponse:(NSDictionary *)response];
                                responseBlock(title, text, license, assetURL, mediaObject, nil);
                            } else {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{@"method":@"geodiv.creer_media"}];
                                responseBlock(title, text, license, assetURL, nil, error);
                            }
                        } failure:^(NSError* error) {
                            responseBlock(title,text,license,assetURL,nil,error);
                        }];
}

- (void)authWithLogin:(NSString *)login
             password:(NSString *)password
        responseBlock:(void (^)(NSString* login, NSString* password, Author* authenticatedUser, NSError *error))responseBlock {
    
    NSMutableArray* identifiers = [NSMutableArray array];
    if (login) {
        [identifiers addObject:login];
    }
    if (password) {
        [identifiers addObject:password];
    }
    
    LTXMLRPCClient* xmlrpcClient = [LTXMLRPCClient sharedClient];
    [xmlrpcClient executeMethod:@"spip.auth"
                     withObject:identifiers
               authCookieEnable:YES
                        success:^(id response) {
                            if([response isKindOfClass:[NSDictionary class]]){
                                self.authenticatedUser = [Author authorWithXMLRPCResponse:(NSDictionary *)response];
                                responseBlock(login, password, self.authenticatedUser, nil);
                            } else {
                                NSError* error = [NSError errorWithDomain:LTConnectionManagerErrorDomain
                                                                     code:LTConnectionManagerInternalError
                                                                 userInfo:@{@"method":@"spip.auth"}];
                                responseBlock(login, password, nil, error);
                            }
                        } failure:^(NSError* error) {
                            responseBlock(login, password, nil, error);
                        }];
}

- (void)unAuthenticate {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[NSURL URLWithString:kHTTPHost] absoluteURL]];
    for (NSHTTPCookie * cookie in cookies) {
        if([cookie.name isEqualToString:kSessionCookieName]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    self.authenticatedUser = nil;
}

@end
