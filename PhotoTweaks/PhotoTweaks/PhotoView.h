//
//  PhotoView.h
//  PhotoTweaks
//
//  Created by Tu You on 14/12/1.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoView : UIView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)zoom;

@end
