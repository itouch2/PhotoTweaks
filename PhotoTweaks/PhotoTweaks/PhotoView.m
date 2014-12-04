//
//  PhotoView.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/1.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoView.h"
#import <math.h>

static const int kGridLines = 2;
static const CGFloat kCenterY = 220;
static const CGFloat kCropVieHotArea = 16;

static CGFloat distanceBetweenPoints(CGPoint point0, CGPoint point1)
{
    return sqrt(pow(point1.x - point0.x, 2) + pow(point1.y - point0.y, 2));
}

#define kInstruction
#define kCanCrop
//#define kShowMask
//#define kShowGrid

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
        
        UIView *t = [UIView new];
        t.backgroundColor = [UIColor purpleColor];
        t.frame = CGRectMake(100, 100, 100, 100);
        [self addSubview:t];
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
@property (strong, nonatomic) PhotoContentView *photoContentView;

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
    CGFloat widthScale = self.bounds.size.width / self.photoContentView.bounds.size.width;
    CGFloat heigthScale = self.bounds.size.height / self.photoContentView.bounds.size.height;
    CGFloat maxScale = MAX(widthScale, heigthScale);
    return maxScale;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void)updatePhotoContentView
{
    CGFloat widthScale = self.bounds.size.width / self.photoContentView.bounds.size.width;
    CGFloat heightScale = self.bounds.size.height / self.photoContentView.bounds.size.height;
    CGFloat maxScale = MAX(widthScale, heightScale);

    if (maxScale > 1) {
        self.photoContentView.frame = CGRectMake(0, 0, maxScale * self.photoContentView.bounds.size.width, maxScale * self.photoContentView.bounds.size.height);
        
        if (heightScale > widthScale) {
            
            self.contentOffsetX = (self.photoContentView.frame.size.width - self.bounds.size.width) / 2;
            
            self.minimumZoomScale = maxScale;
            NSLog(@"contentoffset x : %lf", self.contentOffset.x);
            
        } else {
            
        }
    }
}

- (void)printParams
{
    NSLog(@"view bounds %@", NSStringFromCGRect(self.photoContentView.bounds));
    NSLog(@"self bounds %@", NSStringFromCGRect(self.photoContentView.bounds));
    
    NSLog(@"view frame %@", NSStringFromCGRect(self.frame));
    NSLog(@"self frame %@", NSStringFromCGRect(self.frame));
}

@end

@class CropView;

@protocol CropViewDelegate <NSObject>

- (void)cropEnded:(CropView *)cropView;
- (void)cropMoved:(CropView *)cropView;
- (void)cropViewBoundsChanged:(CropView *)cropView;

@end

@interface CropView : UIView

@property (weak, nonatomic) id<CropViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *horizontalLines;
@property (strong, nonatomic) NSMutableArray *verticalLines;

@end

@implementation CropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
        self.layer.borderWidth = 2;
        
        self.horizontalLines = [NSMutableArray array];
        for (int i = 0; i < kGridLines; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            [self.horizontalLines addObject:line];
            [self addSubview:line];
        }
        
        self.verticalLines = [NSMutableArray array];
        for (int i = 0; i < kGridLines; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            [self.verticalLines addObject:line];
            [self addSubview:line];
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        CGPoint location = [[touches anyObject] locationInView:self];
        CGRect frame = self.frame;
        
        CGPoint p0 = CGPointMake(0, 0);
        CGPoint p1 = CGPointMake(self.frame.size.width, 0);
        CGPoint p2 = CGPointMake(0, self.frame.size.height);
        CGPoint p3 = CGPointMake(self.frame.size.width, self.frame.size.height);
        
        if (distanceBetweenPoints(location, p0) < kCropVieHotArea) {
            frame.origin.x += location.x;
            frame.size.width -= location.x;
            frame.origin.y += location.y;
            frame.size.height -= location.y;
        } else if (distanceBetweenPoints(location, p1) < kCropVieHotArea) {
            frame.size.width = location.x;
            frame.origin.y += location.y;
            frame.size.height -= location.y;
        } else if (distanceBetweenPoints(location, p2) < kCropVieHotArea) {
            frame.origin.x += location.x;
            frame.size.width -= location.x;
            frame.size.height = location.y;
        } else if (distanceBetweenPoints(location, p3) < kCropVieHotArea) {
            frame.size.width = location.x;
            frame.size.height = location.y;
        } else if (fabs(location.x - p0.x) < kCropVieHotArea) {
            frame.origin.x += location.x;
            frame.size.width -= location.x;
        } else if (fabs(location.x - p1.x) < kCropVieHotArea) {
            frame.size.width = location.x;
        } else if (fabs(location.y - p0.y < kCropVieHotArea)) {
            frame.origin.y += location.y;
            frame.size.height -= location.y;
        } else if (fabs(location.y - p2.y) < kCropVieHotArea) {
            frame.size.height = location.y;
        }
        
        self.frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(cropMoved:)]) {
            [self.delegate cropMoved:self];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(cropEnded:)]) {
        [self.delegate cropEnded:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
#ifdef kShowGrid
    
    [self.horizontalLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *line = (UIView *)obj;
        line.frame = CGRectMake(0, (self.frame.size.height / (kGridLines + 1)) * (idx + 1), self.frame.size.width, 1);
    }];
    
    [self.verticalLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *line = (UIView *)obj;
        line.frame = CGRectMake((self.frame.size.width / (kGridLines + 1)) * (idx + 1), 0, 1, self.frame.size.height);
    }];
    
#endif
    
    if ([self.delegate respondsToSelector:@selector(cropViewBoundsChanged:)]) {
        [self.delegate cropViewBoundsChanged:self];
    }
}

@end

@interface PhotoView () <UIScrollViewDelegate, CropViewDelegate>

@property (strong, nonatomic) PhotoScrollView *scrollView;
@property (strong, nonatomic) PhotoContentView *contentImageView;
@property (strong, nonatomic) CropView *cropView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UISlider *slider;
@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGSize originalSize;

// masks
@property (strong, nonatomic) UIView *topMask;
@property (strong, nonatomic) UIView *leftMask;
@property (strong, nonatomic) UIView *bottomMask;
@property (strong, nonatomic) UIView *rightMask;

@end

@implementation PhotoView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    if (self = [super init]) {
        
#ifdef kInstruction
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
#endif
        self.image = image;
        self.frame = frame;
        
        // scale the image
        CGFloat scale = 0.90;
        
        CGFloat width = (int)(scale * image.size.width);
        CGFloat height = (int)(scale * image.size.height);
        
        CGRect bounds = CGRectMake(0, 0, width, height);
        
        self.originalSize = bounds.size;
        
        self.scrollView = [[PhotoScrollView alloc] initWithFrame:bounds];
        self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, kCenterY);
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
        
        self.scrollView.photoContentView = self.contentImageView;
#ifdef kInstruction
        self.contentImageView.alpha = 0.35;
#endif
        [self.scrollView addSubview:self.contentImageView];
        
        self.cropView = [[CropView alloc] initWithFrame:self.scrollView.frame];
        self.cropView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, kCenterY);
        self.cropView.delegate = self;
        [self addSubview:self.cropView];
        
        UIColor *maskColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.topMask = [UIView new];
        self.topMask.backgroundColor = maskColor;
        [self addSubview:self.topMask];
        self.leftMask = [UIView new];
        self.leftMask.backgroundColor = maskColor;
        [self addSubview:self.leftMask];
        self.bottomMask = [UIView new];
        self.bottomMask.backgroundColor = maskColor;
        [self addSubview:self.bottomMask];
        self.rightMask = [UIView new];
        self.rightMask.backgroundColor = maskColor;
        [self addSubview:self.rightMask];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
        self.slider.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) - 105);
        self.slider.minimumValue = 0.0f;
        self.slider.maximumValue = 1.0f;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.slider.value = 0.5;
        [self addSubview:self.slider];
    }
    return self;
}

- (void)zoom
{
//    [self.scrollView setZoomScale:4.0];
    
    static BOOL flag = YES;
    if (flag) {
         [self.scrollView zoomToRect:CGRectMake(100, 100, 100, 100) animated:YES];
    } else {
        [self.scrollView zoomToRect:CGRectMake(0, 0, 100, 100) animated:YES];
    }
    flag = !flag;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.slider.frame, point)) {
        return self.slider;
    } else if (CGRectContainsPoint(CGRectInset(self.cropView.frame, -kCropVieHotArea, -kCropVieHotArea), point) && !CGRectContainsPoint(CGRectInset(self.cropView.frame, kCropVieHotArea, kCropVieHotArea), point)) {
#ifdef kCanCrop
        return self.cropView;
#endif
    }
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentImageView;
}

#pragma mark - Crop View Delegate

- (void)cropMoved:(CropView *)cropView
{
    
}

- (void)cropEnded:(CropView *)cropView
{
    CGFloat scaleX = self.originalSize.width / cropView.bounds.size.width;
    CGFloat scaleY = self.originalSize.height / cropView.bounds.size.height;
    
    CGFloat scale = MIN(scaleX, scaleY);
    CGRect frame = cropView.frame;
    
    CGRect zoomRect = [self convertRect:frame toView:self.scrollView.photoContentView];
    NSLog(@"zoomRect %@", NSStringFromCGRect(zoomRect));
//    [self.scrollView zoomToRect:zoomRect animated:YES];

    CGRect newCropBounds = CGRectMake(0, 0, scale * frame.size.width, scale * frame.size.height);
    CGRect newCropRect = CGRectOffset(newCropBounds, CGRectGetWidth(self.frame) / 2 - newCropBounds.size.width / 2, kCenterY - newCropBounds.size.height / 2);
    
    CGFloat width = cos(self.angle) * newCropBounds.size.width + sin(self.angle) * newCropBounds.size.height;
    CGFloat height = sin(self.angle) * newCropBounds.size.width + cos(self.angle) * newCropBounds.size.height;
    
    CGRect frameToTransform = CGRectMake((CGRectGetWidth(self.frame) - width) / 2, kCenterY - height / 2, width, height);
    UIView *tmp = [[UIView alloc] initWithFrame:frameToTransform];
    tmp.transform = CGAffineTransformMakeRotation(self.angle);
    CGRect rect = tmp.frame;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView zoomToRect:zoomRect animated:NO];
        self.scrollView.frame = rect;
//        CGPoint contentOffset = self.scrollView.contentOffset;
//        self.scrollView.bounds = CGRectMake(0, 0, width, height);
//        self.scrollView.contentOffset = contentOffset;
        cropView.bounds = CGRectMake(0, 0, cropView.bounds.size.width * scale, cropView.bounds.size.height * scale);
        cropView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, kCenterY);

    }];
    
    return ;
//    self.scrollView.minimumZoomScale = [self.scrollView realScale];
    

    CGPoint center = self.scrollView.center;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    self.scrollView.contentOffset = contentOffset;
    self.scrollView.center = center;
    
//    [self sliderValueChanged:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.cropView setNeedsLayout];
//        [self checkScrollViewContentOffset];
//    });
}

- (void)cropViewBoundsChanged:(CropView *)cropView
{
#ifdef kShowMask
    self.topMask.frame = CGRectMake(0, 0, cropView.frame.origin.x + cropView.frame.size.width, cropView.frame.origin.y);
    self.leftMask.frame = CGRectMake(0, cropView.frame.origin.y, cropView.frame.origin.x, self.frame.size.height - cropView.frame.origin.y);
    self.bottomMask.frame = CGRectMake(cropView.frame.origin.x, cropView.frame.origin.y + cropView.frame.size.height, self.frame.size.width - cropView.frame.origin.x, self.frame.size.height - (cropView.frame.origin.y + cropView.frame.size.height));
    self.rightMask.frame = CGRectMake(cropView.frame.origin.x + cropView.frame.size.width, 0, self.frame.size.width - (cropView.frame.origin.x + cropView.frame.size.width), cropView.frame.origin.y + cropView.frame.size.height);
#endif
}

- (void)checkScrollViewContentOffset
{
    if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
        self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    
    if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
        self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
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

    [self.scrollView updatePhotoContentView];
}

@end
