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
#import "Constants.h"

//CORE DATA
//Entities
NSString* const LTLicenseEntityName = @"License";
NSString* const LTAuthorEntityName = @"Author";
NSString* const LTMediaEntityName = @"Media";
NSString* const LTSectionEntityName = @"Section";
//LicenseEntity
NSString* const LTLicenseEntityIdentifierField = @"identifier";
//AuthorEntity
NSString* const LTAuthorEntityIdentifierField = @"identifier";
//MediaEntity
NSString* const LTMediaEntityIdentifierField = @"identifier";
NSString* const LTMediaEntityTitleField = @"title";
NSString* const LTMediaEntityTextField = @"text";
NSString* const LTMediaEntityStatusField = @"status";
NSString* const LTMediaEntityDateField = @"date";
NSString* const LTMediaEntityVisitsField = @"visits";
NSString* const LTMediaEntityPopularityField = @"popularity";
NSString* const LTMediaEntityUpdateDateField = @"updateDate";
NSString* const LTMediaEntityMediaThumbnailUrlField = @"mediaThumbnailUrl";
NSString* const LTMediaEntityMediaThumbnailLocalFileField = @"mediaThumbnailLocalFile";
NSString* const LTMediaEntityMediaMediumLocalFileField = @"mediaMediumLocalFile";
NSString* const LTMediaEntityMediaMediumURLField = @"mediaMediumURL";
NSString* const LTMediaEntityMediaLargeURLField = @"mediaLargeURL";
NSString* const LTMediaEntityMediaLargeLocalFileField = @"mediaLargeLocalFile";
NSString* const LTMediaEntityLocalUpdateDateField = @"localUpdateDate";
NSString* const LTMediaEntityLicenseField = @"license";
NSString* const LTMediaEntityAuthorsField = @"author";
NSString* const LTMediaEntitySectionField = @"section";
//MediaEntity
NSString* const LTSectionEntityIdentifierField = @"identifier";
NSString* const LTSectionEntityDescriptionField = @"desription";
NSString* const LTSectionEntityImageURLField = @"imageURL";
NSString* const LTSectionEntityTitleField = @"title";
NSString* const LTSectionEntityParentField = @"parent";

#ifdef GEODIV
MKPinAnnotationColor const LTPinColor = MKPinAnnotationColorRed;
#endif

#ifdef LES_TAXINOMES
MKPinAnnotationColor const LTPinColor = MKPinAnnotationColorGreen;
#endif

// Sizes
#define THUMBNAIL_MAX_HEIGHT 100.0f
#define THUMBNAIL_MAX_WIDHT 100.0f
#define MEDIA_MAX_WIDHT 512.0f
#define MEDIA_MAX_WIDHT_LARGE 1024.0f

// UI
CGFloat const LTMediasListCommonRowHeight = 55.f;

// Texts
NSString* const LTPhotoGroupName = @"LesTaxinomes";

// Times
NSTimeInterval const LTMediaCacheTime = 3600.0f;

#ifdef LES_TAXINOMES
NSString* const LTPWebServiceURL = @"http://www.lestaxinomes.org/spip.php";
NSString* const LTHTTPHost = @"http://www.lestaxinomes.org";
NSString* const LTForgottenPasswordURL = @"http://www.lestaxinomes.org/spip.php?page=spip_pass";
NSString* const LTSignupURL = @"http://www.lestaxinomes.org/spip.php?page=inscription";
#endif

#ifdef GEODIV
NSString* const LTPWebServiceURL = @"http://www.geodiversite.net/spip.php";
NSString* const LTHTTPHost = @"http://www.geodiversite.net/";
NSString* const LTForgottenPasswordURL = @"http://www.geodiversite.net/spip.php?page=spip_pass";
NSString* const LTSignupURL = @"http://www.geodiversite.net/spip.php?page=inscription";
#endif

#ifdef TESTS
NSString* const LTPWebServiceURL = @"http://ws-base-ur";
NSString* const LTHTTPHost = @"http://www.lestaxinomes.org";
NSString* const LTForgottenPasswordURL = @"http://www.lestaxinomes.org/spip.php?page=spip_pass";
NSString* const LTSignupURL = @"http://www.lestaxinomes.org/spip.php?page=inscription";
#endif


// WS
NSInteger const LTMediasLoadingStep = 20;
NSInteger const LTMediasSearchStep = 10;
NSInteger const LTAuthorsLoadingStep = 20;
NSString* const LTLimitParamName = @"limite";
NSString* const LTSortParamName = @"tri";
NSString* const LTSessionCookieName = @"spip_session";
NSString* const LTXMLRPCMethodKey = @"LTXMLRPCMethodKey";
