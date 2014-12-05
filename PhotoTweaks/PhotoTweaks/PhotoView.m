//
//  PhotoView.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/2.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoView.h"
#import <math.h>

static const int kGridLines = 2;
static const CGFloat kCenterY = 220;
static const CGFloat kCropViewHotArea = 16;
static const CGFloat kMinimumCropArea = 40;

static CGFloat distanceBetweenPoints(CGPoint point0, CGPoint point1)
{
    return sqrt(pow(point1.x - point0.x, 2) + pow(point1.y - point0.y, 2));
}

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

@end

@class CropView;

@protocol CropViewDelegate <NSObject>

- (void)cropEnded:(CropView *)cropView;
- (void)cropMoved:(CropView *)cropView;

@end

@interface CropView : UIView

@property (strong, nonatomic) NSMutableArray *horizontalLines;
@property (strong, nonatomic) NSMutableArray *verticalLines;
@property (weak, nonatomic) id<CropViewDelegate> delegate;

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
        
        BOOL canChangeWidth = frame.size.width > kMinimumCropArea;
        BOOL canChangeHeight = frame.size.height > kMinimumCropArea;
        
        if (distanceBetweenPoints(location, p0) < kCropViewHotArea) {
            if (canChangeWidth) {
                frame.origin.x += location.x;
                frame.size.width -= location.x;
            }
            if (canChangeHeight) {
                frame.origin.y += location.y;
                frame.size.height -= location.y;
            }
        } else if (distanceBetweenPoints(location, p1) < kCropViewHotArea) {
            if (canChangeWidth) {
                frame.size.width = location.x;
            }
            if (canChangeHeight) {
                frame.origin.y += location.y;
                frame.size.height -= location.y;
            }
        } else if (distanceBetweenPoints(location, p2) < kCropViewHotArea) {
            if (canChangeWidth) {
                frame.origin.x += location.x;
                frame.size.width -= location.x;
            }
            if (canChangeHeight) {
                frame.size.height = location.y;
            }
        } else if (distanceBetweenPoints(location, p3) < kCropViewHotArea) {
            if (canChangeWidth) {
                frame.size.width = location.x;
            }
            if (canChangeHeight) {
                frame.size.height = location.y;
            }
        } else if (fabs(location.x - p0.x) < kCropViewHotArea) {
            if (canChangeWidth) {
                frame.origin.x += location.x;
                frame.size.width -= location.x;
            }
        } else if (fabs(location.x - p1.x) < kCropViewHotArea) {
            if (canChangeWidth) {
                frame.size.width = location.x;
            }
        } else if (fabs(location.y - p0.y < kCropViewHotArea)) {
            if (canChangeHeight) {
                frame.origin.y += location.y;
                frame.size.height -= location.y;
            }
        } else if (fabs(location.y - p2.y) < kCropViewHotArea) {
            if (canChangeHeight) {
                frame.size.height = location.y;
            }
        }
        
        self.frame = frame;
        
        [self updateLines:NO];
        
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

- (void)updateLines:(BOOL)animate
{
    void (^animationBlock)(void) = ^(void) {
        [self.horizontalLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *line = (UIView *)obj;
            line.frame = CGRectMake(0, (self.frame.size.height / (kGridLines + 1)) * (idx + 1), self.frame.size.width, 1);
        }];
        
        [self.verticalLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *line = (UIView *)obj;
            line.frame = CGRectMake((self.frame.size.width / (kGridLines + 1)) * (idx + 1), 0, 1, self.frame.size.height);
        }];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
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
    static BOOL flag = YES;
    if (flag) {
        [self.scrollView zoomToRect:CGRectMake(0, 0, 250, 241) animated:YES];
    } else {
        [self.scrollView zoomToRect:CGRectMake(0, 0, 100, 100) animated:YES];
    }
    flag = !flag;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.slider.frame, point)) {
        return self.slider;
    } else if (CGRectContainsPoint(CGRectInset(self.cropView.frame, -kCropViewHotArea, -kCropViewHotArea), point) && !CGRectContainsPoint(CGRectInset(self.cropView.frame, kCropViewHotArea, kCropViewHotArea), point)) {
        return self.cropView;
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
    [self updateMasks:NO];
}

- (void)cropEnded:(CropView *)cropView
{
    CGFloat scaleX = self.originalSize.width / cropView.bounds.size.width;
    CGFloat scaleY = self.originalSize.height / cropView.bounds.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    
    // calculate the new bounds of crop view
    CGRect newCropBounds = CGRectMake(0, 0, scale * cropView.frame.size.width, scale * cropView.frame.size.height);
    
    // calculate the new bounds of scroll view
    CGFloat width = cos(fabs(self.angle)) * newCropBounds.size.width + sin(fabs(self.angle)) * newCropBounds.size.height;
    CGFloat height = sin(fabs(self.angle)) * newCropBounds.size.width + cos(fabs(self.angle)) * newCropBounds.size.height;
    
    // calculate the zoom area of scroll view
    CGRect scaleFrame = cropView.frame;
    if (scaleFrame.size.width >= self.scrollView.bounds.size.width) {
        scaleFrame.size.width -= 1;
    }
    if (scaleFrame.size.height >= self.scrollView.bounds.size.height) {
        scaleFrame.size.height -= 1;
    }
    CGRect zoomRect = [self convertRect:scaleFrame toView:self.scrollView.photoContentView];
    
    [UIView animateWithDuration:0.25 animations:^{
        // animate crop view
        cropView.bounds = CGRectMake(0, 0, newCropBounds.size.width, newCropBounds.size.height);
        cropView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, kCenterY);
        
        // zoom the specified area of scroll view
        [self.scrollView zoomToRect:zoomRect animated:NO];
        
        // animate the new bounds of scroll view
        CGPoint center = self.scrollView.center;
        CGPoint contentOffset = self.scrollView.contentOffset;
        self.scrollView.bounds = CGRectMake(0, 0, width, height);
        self.scrollView.contentOffset = contentOffset;
        self.scrollView.center = center;
    }];
    
    // update masks
    [self updateMasks:YES];
    
    // update lines in crop view
    [self.cropView updateLines:YES];
    
    CGFloat scaleH = self.scrollView.bounds.size.height / self.scrollView.contentSize.height;
    CGFloat scaleW = self.scrollView.bounds.size.width / self.scrollView.contentSize.width;
    __block CGFloat scaleM = MAX(scaleH, scaleW);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (scaleM > 1) {
            scaleM = scaleM * self.scrollView.zoomScale;
            [self.scrollView setZoomScale:scaleM animated:NO];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self checkScrollViewContentOffset];
        }];
    });
}

- (void)updateMasks:(BOOL)animate
{
    void (^animationBlock)(void) = ^(void) {
        self.topMask.frame = CGRectMake(0, 0, self.cropView.frame.origin.x + self.cropView.frame.size.width, self.cropView.frame.origin.y);
        self.leftMask.frame = CGRectMake(0, self.cropView.frame.origin.y, self.cropView.frame.origin.x, self.frame.size.height - self.cropView.frame.origin.y);
        self.bottomMask.frame = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y + self.cropView.frame.size.height, self.frame.size.width - self.cropView.frame.origin.x, self.frame.size.height - (self.cropView.frame.origin.y + self.cropView.frame.size.height));
        self.rightMask.frame = CGRectMake(self.cropView.frame.origin.x + self.cropView.frame.size.width, 0, self.frame.size.width - (self.cropView.frame.origin.x + self.cropView.frame.size.width), self.cropView.frame.origin.y + self.cropView.frame.size.height);
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
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
    // rotate scoll view
    self.angle = self.slider.value - 0.5;
    self.scrollView.transform = CGAffineTransformMakeRotation(self.angle);
    
    // position scroll view
    CGFloat width = cos(fabs(self.angle)) * self.cropView.frame.size.width + sin(fabs(self.angle)) * self.cropView.frame.size.height;
    CGFloat height = sin(fabs(self.angle)) * self.cropView.frame.size.width + cos(fabs(self.angle)) * self.cropView.frame.size.height;
    CGPoint center = self.scrollView.center;
    CGPoint contentOffset = self.scrollView.contentOffset;
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    self.scrollView.contentOffset = contentOffset;
    self.scrollView.center = center;
    
    self.scrollView.minimumZoomScale = [self.scrollView realScale];
    
    [self checkScrollViewContentOffset];
    
    if (self.scrollView.contentSize.width / self.scrollView.bounds.size.width > 1.2) {
        return ;
    }
    
    [self.scrollView setZoomScale:[self.scrollView realScale] animated:NO];
    
    [self.scrollView updatePhotoContentView];
}

@end
