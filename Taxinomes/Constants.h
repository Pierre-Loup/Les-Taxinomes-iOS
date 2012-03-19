//
//  Constant.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 13/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

/*
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 */

//CORE DATA
#define kEntityLicenseName @"License"

//Color
//#5F8237

#define kStandardGreenColor [UIColor colorWithRed:(95.0/255.0) green:(130.0/255.0) blue:(55.0/255.0) alpha:1.0] 

#define THUMBNAIL_MAX_HEIGHT 100.0
#define THUMBNAIL_MAX_WIDHT 100.0
#define MEDIA_MAX_WIDHT 512.0

#define kHelloWorld @"Hello, World"
#define kIkooLol @"Kikoo lol"
#define kNoDescription @"Pas de description"
#define kPhotoGroupName @"Les Taxinomes"



#ifdef TAXINOMES_DEV
    #define kHost @"taxinomes.arscenic.org"
    #define kXMLRCPWebServiceURL @"http://taxinomes.arscenic.org/spip.php?action=xmlrpc_serveur"
#else
    #define kHost @"www.lestaxinomes.org"
    #define kXMLRCPWebServiceURL @"http://www.lestaxinomes.org/spip.php?action=xmlrpc_serveur"
#endif

#define kNbMediasStep 10
//XML-RPC
#define kDefaultLimit 50
#define kLimitParamName @"limite"
#define kSortParamName @"tri"

//Database
#define kDatabaseFile @"taxinomes-1.0.db"
#define kAuthorCacheTime 3600.0
#define kmediaCacheTime 3600.0
