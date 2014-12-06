//
//  UIColor+Tweak.m
//  PhotoTweaks
//
//  Created by TuYou on 14/12/6.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "UIColor+Tweak.h"

@implementation UIColor (Tweak)

+ (UIColor *)cancelButtonColor
{
    return [UIColor colorWithRed:0.09 green:0.49 blue:1 alpha:1];
}

+ (UIColor *)cancelButtonHighlightedColor
{
    return [UIColor colorWithRed:0.11 green:0.17 blue:0.26 alpha:1];
}

+ (UIColor *)saveButtonColor
{
    return [UIColor colorWithRed:0.9 green:0.72 blue:0.16 alpha:1];
}

+ (UIColor *)saveButtonHighlightedColor
{
    return [UIColor colorWithRed:0.26 green:0.23 blue:0.13 alpha:1];
}

+ (UIColor *)cropLineColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *)photoTweakCanvasBackgroundColor
{
    return [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1];
}

@end
