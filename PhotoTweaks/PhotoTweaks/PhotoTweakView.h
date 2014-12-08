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

@property (strong, nonatomic) NSMutableArray *horizontalCropLines;
@property (strong, nonatomic) NSMutableArray *verticalCropLines;
@property (assign, nonatomic) BOOL cropLinesDismissed;

@property (strong, nonatomic) NSMutableArray *horizontalGridLines;
@property (strong, nonatomic) NSMutableArray *verticalGridLines;
@property (assign, nonatomic) BOOL gridLinesDismissed;

@property (weak, nonatomic) id<CropViewDelegate> delegate;

@end

@interface PhotoTweakView : UIView

@property (assign, nonatomic) CGFloat angle;
@property (strong, nonatomic) PhotoContentView *photoContentView;
@property (assign, nonatomic) CGPoint photoContentOffset;
@property (strong, nonatomic) CropView *cropView;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end
