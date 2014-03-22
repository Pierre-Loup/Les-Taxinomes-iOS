//
//  LTConnectionManagerError.h
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 22/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

extern NSString* const LTConnectionManagerErrorDomain;

typedef enum
{
    LTConnectionManagerBadArgsError     = 77001,
    LTConnectionManagerBadResponse      = 77002,
    LTConnectionManagerParsingError     = 77003,
    LTConnectionManagerInternalError    = 77004
    
} LTConnectionManagerError;