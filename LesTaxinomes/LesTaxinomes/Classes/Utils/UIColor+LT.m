//
//  UIColor+LT.m
//  LesTaxinomes
//
//  Created by Pierre-Loup Tristant Perso on 14/03/2014.
//  Copyright (c) 2014 Les Petits Débrouillards Bretagne. All rights reserved.
//

#import "UIColor+LT.h"

@implementation UIColor (LT)

+ (UIColor*)mainColor
{
    UIColor* mainColor;
    
#ifdef GEODIV
    mainColor = [UIColor colorWithRed:(29.0f/255.0f) green:(176.0f/255.0f) blue:(252.0f/255.0f) alpha:1.0f];
#endif
    
#ifdef LES_TAXINOMES
    mainColor = [UIColor colorWithRed:(157.0f/255.0f) green:(125.0f/255.0f) blue:(66.0/255.0f) alpha:1.0f];
#endif
    
    return mainColor;
}

+ (UIColor*)secondaryColor
{
    UIColor* secondaryColor;
#ifdef GEODIV
    secondaryColor : [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f];
#endif
    
#ifdef LES_TAXINOMES

    secondaryColor = [UIColor colorWithRed:(138.0f/255.0f) green:(140.0f/255.0f) blue:(142.0f/255.0f) alpha:1.0f];
#endif
    
    return secondaryColor;
}

+ (UIColor*)navigationBarColor
{
    UIColor* navigationBarColor;
#ifdef GEODIV
    navigationBarColor = [UIColor colorWithRed:(29.0f/255.0f) green:(176.0f/255.0f) blue:(252.0f/255.0f) alpha:1.0f];
#endif
    
#ifdef LES_TAXINOMES
    navigationBarColor = [UIColor colorWithRed:(29.0f/255.0f) green:(176.0f/255.0f) blue:(252.0f/255.0f) alpha:1.0f];
#endif
    
    return navigationBarColor;
}

@end
