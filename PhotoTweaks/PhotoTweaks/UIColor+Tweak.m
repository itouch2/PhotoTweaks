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
    return [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
}

+ (UIColor *)saveButtonHighlightedColor
{
    return [UIColor colorWithRed:0.26 green:0.23 blue:0.13 alpha:1];
}

+ (UIColor *)resetButtonColor
{
    return [UIColor colorWithRed:0.09 green:0.49 blue:1 alpha:1];
}

+ (UIColor *)resetButtonHighlightedColor
{
    return [UIColor colorWithRed:0.11 green:0.17 blue:0.26 alpha:1];
}

+ (UIColor *)maskColor
{
    return [UIColor colorWithWhite:0.0 alpha:0.6];
}

+ (UIColor *)cropLineColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *)gridLineColor
{
    return [UIColor colorWithRed:0.52 green:0.48 blue:0.47 alpha:0.8];
}

+ (UIColor *)photoTweakCanvasBackgroundColor
{
    return [UIColor colorWithWhite:0.0 alpha:1.0];
}

@end
