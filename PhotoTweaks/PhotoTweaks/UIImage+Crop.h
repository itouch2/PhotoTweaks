//
//  UIImage+Crop.h
//  PhotoTweaks
//
//  Created by TuYou on 14/12/5.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)cropImage:(CGRect)rect transform:(CGAffineTransform)transform;

@end
