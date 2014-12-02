//
//  PhotoView.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/1.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoView.h"

#define kInstruction

@interface PhotoContentView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGFloat distance;

@end

@implementation PhotoContentView

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        self.image = image;
        
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.image = self.image;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end

@interface PhotoScrollView : UIScrollView

@property (assign, nonatomic) CGFloat distance;
@property (assign, nonatomic) CGRect originalFrame;

@end

@implementation PhotoScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return self;
}

- (void)setContentOffsetY:(CGFloat)offsetY
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = offsetY;
    self.contentOffset = contentOffset;
}

- (void)setContentOffsetX:(CGFloat)offsetX
{
    CGPoint contentOffset = self.contentOffset;
    contentOffset.x = offsetX;
    self.contentOffset = contentOffset;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.originalFrame = frame;
    }
    return self;
}

- (CGFloat)realScale
{
    UIView *view = self.subviews[0];
    
    CGFloat heightRatio = self.bounds.size.height / view.bounds.size.height;
    CGFloat widthRatio = self.bounds.size.width / view.bounds.size.width;
    CGFloat maxRatio = heightRatio > widthRatio ? heightRatio : widthRatio;
    
    return maxRatio;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void)updateSubviews
{
    UIView *view = self.subviews[0];
    
    CGFloat heightRatio = self.bounds.size.height / view.bounds.size.height;
    CGFloat widthRatio = self.bounds.size.width / view.bounds.size.width;
    CGFloat maxRatio = heightRatio > widthRatio ? heightRatio : widthRatio;

    if (maxRatio > 1) {
        view.frame = CGRectMake(0, 0, maxRatio * view.bounds.size.width, maxRatio * view.bounds.size.height);
        
        if (heightRatio > widthRatio) {
            
            self.contentOffsetX = (view.frame.size.width - self.bounds.size.width) / 2;
            
            self.minimumZoomScale = maxRatio;
            NSLog(@"contentoffset x : %lf", self.contentOffset.x);
            
        } else {
            
        }
        
        NSLog(@"content offset %@", NSStringFromCGPoint(self.contentOffset));
    }
}

- (void)printParams
{
    UIView *view = self.subviews[0];
    NSLog(@"view bounds %@", NSStringFromCGRect(view.bounds));
    NSLog(@"self bounds %@", NSStringFromCGRect(self.bounds));
    
    NSLog(@"view frame %@", NSStringFromCGRect(view.frame));
    NSLog(@"self frame %@", NSStringFromCGRect(self.frame));
}

@end

@interface CropView : UIView

@end

@implementation CropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
        self.layer.borderWidth = 2;
    }
    return self;
}

@end

@interface PhotoView () <UIScrollViewDelegate>

@property (strong, nonatomic) PhotoScrollView *scrollView;
@property (strong, nonatomic) PhotoContentView *contentImageView;
@property (strong, nonatomic) CropView *cropView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UISlider *slider;
@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGSize originalSize;

@end

@implementation PhotoView

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        
#ifdef kInstruction
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
#endif
        self.image = image;
        
        // scale the image
        
        CGFloat scale = 0.65;
        
        CGFloat width = (int)(scale * image.size.width);
        CGFloat height = (int)(scale * image.size.height);
        self.frame = CGRectMake(0, 0, width, height + 50);
        
        self.originalSize = self.frame.size;
        
        CGRect bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 50);
        self.scrollView = [[PhotoScrollView alloc] initWithFrame:bounds];

        self.scrollView.bounces = YES;
        self.scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 4;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width / 2, self.scrollView.bounds.size.height / 2);
#ifdef kInstruction
        self.scrollView.layer.borderColor = [UIColor redColor].CGColor;
        self.scrollView.layer.borderWidth = 1;
        self.scrollView.showsVerticalScrollIndicator = YES;
        self.scrollView.showsHorizontalScrollIndicator = YES;
        self.scrollView.backgroundColor = [UIColor orangeColor];
#endif
        [self addSubview:self.scrollView];
        
        self.contentImageView = [[PhotoContentView alloc] initWithImage:image];
        self.contentImageView.frame = self.scrollView.bounds;
        self.contentImageView.backgroundColor = [UIColor clearColor];
        self.contentImageView.userInteractionEnabled = YES;
#ifdef kInstruction
        self.contentImageView.alpha = 0.35;
#endif
        [self.scrollView addSubview:self.contentImageView];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
        self.slider.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) - 25);
        self.slider.minimumValue = 0.0f;
        self.slider.maximumValue = 1.0f;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.slider.value = 0.5;
        [self addSubview:self.slider];
        
        self.cropView = [[CropView alloc] initWithFrame:self.scrollView.frame];
        self.cropView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2 - 50 / 2);
        [self addSubview:self.cropView];
    }
    return self;
}

- (void)zoom
{
    [self.scrollView setZoomScale:4.0];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = self.slider.frame;
    if (CGRectContainsPoint(rect, point)) {
        return self.slider;
    }
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentImageView;
}

- (void)sliderValueChanged:(id)sender
{
    self.angle = self.slider.value - 0.5;
    self.scrollView.transform = CGAffineTransformMakeRotation(self.angle);
    CGFloat rotateAngle = fabs(self.angle);
    
    self.scrollView.minimumZoomScale = [self.scrollView realScale];
    
    CGFloat width = cos(rotateAngle) * self.cropView.frame.size.width + sin(rotateAngle) * self.cropView.frame.size.height;
    CGFloat height = sin(rotateAngle) * self.cropView.frame.size.width + cos(rotateAngle) * self.cropView.frame.size.height;
    CGPoint center = self.scrollView.center;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    self.scrollView.contentOffset = contentOffset;

    self.scrollView.center = center;
    
    NSLog(@"....content offset: %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    NSLog(@"....bounds size : %@", NSStringFromCGRect(self.scrollView.bounds));
    NSLog(@"....frame size: %@", NSStringFromCGRect(self.scrollView.frame));
    
    if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
        self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    
    if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
        self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
    
    if (self.scrollView.contentSize.width / self.scrollView.bounds.size.width > 1.2) {
        return ;
    }
    
    [self.scrollView setZoomScale:[self.scrollView realScale] animated:NO];
    
//    CGFloat zoomScaleX = width / self.originalSize.width;
//    CGFloat zoomScaleY = height / self.originalSize.height;
//    CGFloat zoomScale = zoomScaleX > zoomScaleY ? zoomScaleX : zoomScaleY;
//    [self.scrollView setZoomScale:zoomScale];

    [self.scrollView updateSubviews];
}

@end
