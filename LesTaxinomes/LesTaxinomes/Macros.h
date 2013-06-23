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

#define _T(x) NSLocalizedString((x),@"")

/*
 LEVELS
 
 0 => pas de logs
 1 => affiche les logs d'erreur
 2 => affiche les logs d'erreur et de warning
 3 => affiche les logs d'erreur, de warning et d'info
 4 => affiche les logs d'erreur, de warning, d'info et de debug
 */

#define LOGS_LEVEL			4

#ifdef DEBUG

#define LogError(format, ...)		NSLog(@"[ERROR] : %@",[NSString stringWithFormat:format,## __VA_ARGS__])
#define LogWarning(format, ...)		NSLog(@"[Warn]  : %@",[NSString stringWithFormat:format,## __VA_ARGS__])
#define LogInfo(format, ...)		NSLog(@"[info]  : %@",[NSString stringWithFormat:format,## __VA_ARGS__])
#define LogDebug(format, ...)		NSLog(@"[debug] : %@", [NSString stringWithFormat:format,## __VA_ARGS__])
#define LogCmd()					NSLog(@"[cmd]: [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

#if LOGS_LEVEL < 1
#undef LogError
#define LogError(format, ...)
#endif

#if LOGS_LEVEL < 2
#undef LogWarning
#define LogWarning(format, ...)
#endif

#if LOGS_LEVEL < 3
#undef LogInfo
#define LogInfo(format, ...)
#endif

#if LOGS_LEVEL < 4
#undef LogDebug
#define LogDebug(format, ...)
#undef LogCmd
#define LogCmd()
#endif

#endif


#ifndef DEBUG

#define LogError(format, ...)
#define LogWarning(format, ...)
#define LogInfo(format, ...)
#define LogDebug(format, ...)
#define LogCmd()

#endif

#define DEVICE_SYSTEM_MAJOR_VERSION [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue]
#define IOS7_OR_GREATER (DEVICE_SYSTEM_MAJOR_VERSION >= 7)