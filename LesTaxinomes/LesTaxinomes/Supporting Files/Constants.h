//
//  Constant.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant on 13/11/11.
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

//CORE DATA
//Entities
#define kLicenseEntityName @"License"
#define kAuthorEntityName @"Author"
#define kMediaEntityName @"Media"
#define kSectionEntityName @"Section"
//LicenseEntity
#define kLicenseEntityIdentifierField @"identifier"
//AuthorEntity
#define kAuthorEntityIdentifierField @"identifier"
//MediaEntity
#define kMediaEntityIdentifierField @"identifier"
#define kMediaEntityTitleField @"title"
#define kMediaEntityTextField @"text"
#define kMediaEntityStatusField @"status"
#define kMediaEntityDateField @"date"
#define kMediaEntityVisitsField @"visits"
#define kMediaEntityPopularityField @"popularity"
#define kMediaEntityUpdateDateField @"updateDate"
#define kMediaEntityMediaThumbnailUrlField @"mediaThumbnailUrl"
#define kMediaEntityMediaThumbnailLocalFileField @"mediaThumbnailLocalFile"
#define kMediaEntityMediaMediumLocalFileField @"mediaMediumLocalFile"
#define kMediaEntityMediaMediumURLField @"mediaMediumURL"
#define kMediaEntityMediaLargeURLField @"mediaLargeURL"
#define kMediaEntityMediaLargeLocalFileField @"mediaLargeLocalFile"
#define kMediaEntityLocalUpdateDateField @"localUpdateDate"
#define kMediaEntityLicenseField @"license"
#define kMediaEntityAuthorsField @"author"
#define kMediaEntitySectionField @"section"
//MediaEntity
#define kSectionEntityIdentifierField @"identifiant"
#define kSectionEntityDescriptionField @"desription"
#define kSectionEntityImageURLField @"imageURL"
#define kSectionEntityTitleField @"title"
#define kSectionEntityParentField @"parent"

//Color
#ifdef GEODIV
#define kPinColor MKPinAnnotationColorRed
#define kMainColor [UIColor colorWithRed:(29.0f/255.0f) green:(176.0f/255.0f) blue:(252.0f/255.0f) alpha:1.0f]
#define kSecondaryColor [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f]
#else
#define kPinColor MKPinAnnotationColorGreen
#define kNavigationBarColor [UIColor colorWithRed:(203.0f/255.0f) green:(203.0f/255.0f) blue:(203.0/255.0f) alpha:1.0f]
#define kMainColor [UIColor colorWithRed:(157.0f/255.0f) green:(125.0f/255.0f) blue:(66.0/255.0f) alpha:1.0f]
#define kSecondaryColor [UIColor colorWithRed:(255.0f/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:1.0f]
#endif
// Sizes
#define THUMBNAIL_MAX_HEIGHT 100.0f
#define THUMBNAIL_MAX_WIDHT 100.0f
#define MEDIA_MAX_WIDHT 512.0f
#define MEDIA_MAX_WIDHT_LARGE 1024.0f

// Texts
#define kPhotoGroupName @"LesTaxinomes"

// Times
#define kMediaCacheTime 3600.0f

#ifdef DEV
#define kHost @"taxinomes.arscenic.org"
#define kXMLRCPWebServiceURL @"http://taxinomes.arscenic.org/spip.php?action=xmlrpc_serveur"
#define kHTTPHost @"http://taxinomes.arscenic.org/"
#define kForgottenPasswordURL @"http://taxinomes.arscenic.org/spip.php?page=spip_pass"
#define kSignupURL @"http://taxinomes.arscenic.org/spip.php?page=inscription"
#endif
#ifdef PROD
    #define kHost @"www.lestaxinomes.org"
    #define kXMLRCPWebServiceURL @"http://www.lestaxinomes.org/spip.php?action=xmlrpc_serveur"
    #define kHTTPHost @"http://www.lestaxinomes.org"
    #define kForgottenPasswordURL @"http://www.lestaxinomes.org/spip.php?page=spip_pass"
    #define kSignupURL @"http://www.lestaxinomes.org/spip.php?page=inscription"
#endif
#ifdef GEODIV
#define kHost @"http://www.geodiversite.net/"
#define kXMLRCPWebServiceURL @"http://www.geodiversite.net/spip.php?action=xmlrpc_serveur"
#define kHTTPHost @"http://www.geodiversite.net/"
#define kForgottenPasswordURL @"http://www.geodiversite.net/spip.php?page=spip_pass"
#define kSignupURL @"http://www.geodiversite.net/spip.php?page=inscription"
#endif
#ifdef TESTS
#define kHost @"taxinomes.arscenic.org/"
#define kXMLRCPWebServiceURL @"http://taxinomes.arscenic.org//spip.php?action=xmlrpc_serveur"
#define kHTTPHost @"http://taxinomes.arscenic.org/"
#define kForgottenPasswordURL @"http://taxinomes.arscenic.org/spip.php?page=spip_pass"
#define kSignupURL @"http://taxinomes.arscenic.org/spip.php?page=inscription"
#endif


// WS
#define kLTMediasLoadingStep 20;
#define kLimitParamName @"limite"
#define kSortParamName @"tri"
#define kSessionCookieName @"spip_session"
#define kLTXMLRPCMethodKey @"LTXMLRPCMethodKey"
