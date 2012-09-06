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
//#5F8237

#define kStandardGreenColor [UIColor colorWithRed:(95.0/255.0) green:(130.0/255.0) blue:(55.0/255.0) alpha:1.0]
#define kLightGreenColor [UIColor colorWithRed:(132.0/255.0) green:(211.0/255.0) blue:(58.0/255.0) alpha:1.0] 

// Sizes
#define THUMBNAIL_MAX_HEIGHT 100.0
#define THUMBNAIL_MAX_WIDHT 100.0
#define MEDIA_MAX_WIDHT 512.0
#define MEDIA_MAX_WIDHT_LARGE 1024.0

// Texts
#define kPhotoGroupName @"LesTaxinomes"

// Times
#define kMediaCacheTime 3600.0

#ifdef DEV 
    #define kHost @"axinomes.arscenic.org/"
    #define kXMLRCPWebServiceURL @"http://axinomes.arscenic.org//spip.php?action=xmlrpc_serveur"
    #define kHTTPHost @"http://axinomes.arscenic.org/"
    #define kForgottenPasswordURL @"http://axinomes.arscenic.org/spip.php?page=spip_pass"
    #define kSignupURL @"http://axinomes.arscenic.org/spip.php?page=inscription"
#endif
#ifdef PROD
    #define kHost @"www.lestaxinomes.org"
    #define kXMLRCPWebServiceURL @"http://www.lestaxinomes.org/spip.php?action=xmlrpc_serveur"
    #define kHTTPHost @"http://www.lestaxinomes.org"
    #define kForgottenPasswordURL @"http://www.lestaxinomes.org/spip.php?page=spip_pass"
    #define kSignupURL @"http://www.lestaxinomes.org/spip.php?page=inscription"
#endif
#ifdef TESTS
    #define kHost @"taxinomes.arscenic.org/"
    #define kXMLRCPWebServiceURL @"http://taxinomes.arscenic.org//spip.php?action=xmlrpc_serveur"
    #define kHTTPHost @"http://taxinomes.arscenic.org/"
    #define kForgottenPasswordURL @"http://taxinomes.arscenic.org/spip.php?page=spip_pass"
    #define kSignupURL @"http://taxinomes.arscenic.org/spip.php?page=inscription"
#endif


// WS
#define kDefaultLimit 20
#define kNbMediasStep 10
#define kLimitParamName @"limite"
#define kSortParamName @"tri"
#define kSessionCookieName @"spip_session"

// Errors
#define kLTWebServiceResponseErrorDomain @"LTWebServiceResponseErrorDomain"
#define kLTDefaultErrorDomain @"LTDefaultErrorDomain"
#define kLTConnectionManagerInternalError @"LTConnectionManagerInternalError"
#define kLTAuthenticationFailedError @"LTAuthenticationFailedError"
#define kNetworkRequestErrorDomain @"ASIHTTPRequestErrorDomain"
