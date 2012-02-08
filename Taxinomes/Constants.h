//
//  Constant.h
//  Taxinomes
//
//  Created by Pierre-Loup Tristant on 13/11/11.
//  Copyright (c) 2011 Les petits débrouillards Bretagne. All rights reserved.
//

#ifndef Taxinomes_Constant_h
#define Taxinomes_Constant_h

#define THUMBNAIL_MAX_HEIGHT 100.0
#define THUMBNAIL_MAX_WIDHT 100.0
#define MEDIA_MAX_WIDHT 512.0

static NSString *kHelloWorld = @"Hello, World";
static NSString *kIkooLol = @"Kikoo lol";
static NSString *kNoDescription = @"Pas de description";

//static NSString *kHost = @"www.lestaxinomes.org";
//static NSString *kXMLRCPWebServiceURL = @"http://www.lestaxinomes.org/spip.php?action=xmlrpc_serveur";

static NSString *kHost = @"taxinomes.arscenic.org";
static NSString *kXMLRCPWebServiceURL = @"http://taxinomes.arscenic.org/spip.php?action=xmlrpc_serveur";

static NSInteger kNbMediasStep = 10;
//XML-RPC
static NSInteger kDefaultLimit = 50;
static NSString *kLimitParamName = @"limite";
static NSString *kSortParamName = @"tri";

//Database
static NSString *kDatabaseFile = @"taxinomes-1.0.db";
static NSTimeInterval kAuthorCacheTime = 3600.0;
static NSTimeInterval kArticleCacheTime = 3600.0;



CGFloat kScreenScale;
#endif
