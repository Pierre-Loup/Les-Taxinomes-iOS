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

#import <MapKit/MapKit.h>

//CORE DATA
//Entities
extern NSString* const LTLicenseEntityName;
extern NSString* const LTAuthorEntityName;
extern NSString* const LTMediaEntityName;
extern NSString* const LTSectionEntityName;
//LicenseEntity
extern NSString* const LTLicenseEntityIdentifierField;
//AuthorEntity
extern NSString* const LTAuthorEntityIdentifierField;
//MediaEntity
extern NSString* const LTMediaEntityIdentifierField;
extern NSString* const LTMediaEntityTitleField;
extern NSString* const LTMediaEntityTextField;
extern NSString* const LTMediaEntityStatusField;
extern NSString* const LTMediaEntityDateField;
extern NSString* const LTMediaEntityVisitsField;
extern NSString* const LTMediaEntityPopularityField;
extern NSString* const LTMediaEntityUpdateDateField;
extern NSString* const LTMediaEntityMediaThumbnailUrlField;
extern NSString* const LTMediaEntityMediaThumbnailLocalFileField;
extern NSString* const LTMediaEntityMediaMediumLocalFileField;
extern NSString* const LTMediaEntityMediaMediumURLField;
extern NSString* const LTMediaEntityMediaLargeURLField;
extern NSString* const LTMediaEntityMediaLargeLocalFileField;
extern NSString* const LTMediaEntityLocalUpdateDateField;
extern NSString* const LTMediaEntityLicenseField;
extern NSString* const LTMediaEntityAuthorsField;
extern NSString* const LTMediaEntitySectionField;
//MediaEntity
extern NSString* const LTSectionEntityIdentifierField;
extern NSString* const LTSectionEntityDescriptionField;
extern NSString* const LTSectionEntityImageURLField;
extern NSString* const LTSectionEntityTitleField;
extern NSString* const LTSectionEntityParentField;

#ifdef GEODIV
extern MKPinAnnotationColor const LTPinColor;
#endif

#ifdef LES_TAXINOMES
extern MKPinAnnotationColor const LTPinColor;
#endif

// Sizes
#define THUMBNAIL_MAX_HEIGHT 100.0f
#define THUMBNAIL_MAX_WIDHT 100.0f
#define MEDIA_MAX_WIDHT 512.0f
#define MEDIA_MAX_WIDHT_LARGE 1024.0f

// Texts
extern NSString* const LTPhotoGroupName;

// Times
extern NSTimeInterval const LTMediaCacheTime;

#ifdef LES_TAXINOMES
extern NSString* const LTPWebServiceURL;
extern NSString* const LTXMLRCPTreeURL;
extern NSString* const LTHTTPHost;
extern NSString* const LTForgottenPasswordURL;
extern NSString* const LTSignupURL;
#endif

#ifdef GEODIV
extern NSString* const LTPWebServiceURL;
extern NSString* const LTHTTPHost;
extern NSString* const LTForgottenPasswordURL;
extern NSString* const LTSignupURL;
#endif

#ifdef TESTS
extern NSString* const LTPWebServiceURL;
extern NSString* const LTHTTPHost;
extern NSString* const LTForgottenPasswordURL;
extern NSString* const LTSignupURL;
#endif


// WS
extern NSInteger const LTMediasLoadingStep;
extern NSInteger const LTAuthorsLoadingStep;
extern NSString* const LTLimitParamName;
extern NSString* const LTSortParamName;
extern NSString* const LTSessionCookieName;
extern NSString* const LTXMLRPCMethodKey;
