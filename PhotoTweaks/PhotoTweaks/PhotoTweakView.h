//
//  PhotoView.h
//  PhotoTweaks
//
//  Created by Tu You on 14/12/2.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CropView;

@interface PhotoContentView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@protocol CropViewDelegate <NSObject>

- (void)cropEnded:(CropView *)cropView;
- (void)cropMoved:(CropView *)cropView;

@end

@interface CropView : UIView
@end

@interface PhotoTweakView : UIView

@property (assign, nonatomic) CGFloat angle;
@property (strong, nonatomic) PhotoContentView *photoContentView;
@property (assign, nonatomic) CGPoint photoContentOffset;
@property (strong, nonatomic) CropView *cropView;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (CGPoint)photoTranslation;

@end
