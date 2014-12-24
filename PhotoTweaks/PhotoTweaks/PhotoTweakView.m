//
//  PhotoView.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/2.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoTweakView.h"
#import "UIColor+Tweak.h"
#import <math.h>

static const int kCropLines = 2;
static const int kGridLines = 9;

static const CGFloat kCropViewHotArea = 16;
static const CGFloat kMinimumCropArea = 60;
static const CGFloat kMaximumCanvasWidthRatio = 0.9;
static const CGFloat kMaximumCanvasHeightRatio = 0.7;
static const CGFloat kCanvasHeaderHeigth = 60;
static const CGFloat kCropViewCornerLength = 22;

static CGFloat distanceBetweenPoints(CGPoint point0, CGPoint point1)
{
    return sqrt(pow(point1.x - point0.x, 2) + pow(point1.y - point0.y, 2));
}

//#define kInstruction
#define kShowCanvas

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

- (CGFloat)realScale
{
    CGFloat scaleWidth = self.bounds.size.width / self.photoContentView.bounds.size.width;
    CGFloat scaleHeight = self.bounds.size.height / self.photoContentView.bounds.size.height;
    CGFloat max = MAX(scaleWidth, scaleHeight);
    
    return max;
}

- (void)updatePhotoContentView
{
    CGFloat scaleWidth = self.bounds.size.width / self.photoContentView.bounds.size.width;
    CGFloat scaleHeight = self.bounds.size.height / self.photoContentView.bounds.size.height;
    CGFloat max = MAX(scaleWidth, scaleHeight);
    
    if (max > 1) {
        self.photoContentView.frame = CGRectMake(0, 0, max * self.photoContentView.bounds.size.width, max * self.photoContentView.bounds.size.height);
        
        if (scaleHeight > scaleWidth) {
            self.contentOffsetX = (self.photoContentView.frame.size.width - self.bounds.size.width) / 2;
            self.minimumZoomScale = max;
        }
    }
}

@end

typedef NS_ENUM(NSInteger, CropCornerType) {
    CropCornerTypeUpperLeft,
    CropCornerTypeUpperRight,
    CropCornerTypeLowerRight,
    CropCornerTypeLowerLeft
};

@interface CropCornerView : UIView

@end

@implementation CropCornerView

- (instancetype)initWithCornerType:(CropCornerType)type
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kCropViewCornerLength, kCropViewCornerLength);
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat lineWidth = 2;
        UIView *horizontal = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropViewCornerLength, lineWidth)];
        horizontal.backgroundColor = [UIColor cropLineColor];
        [self addSubview:horizontal];
        
        UIView *vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, kCropViewCornerLength)];
        vertical.backgroundColor = [UIColor cropLineColor];
        [self addSubview:vertical];
        
        if (type == CropCornerTypeUpperLeft) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, lineWidth / 2);
            vertical.center = CGPointMake(lineWidth / 2, kCropViewCornerLength / 2);
        } else if (type == CropCornerTypeUpperRight) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, lineWidth / 2);
            vertical.center = CGPointMake(kCropViewCornerLength - lineWidth / 2, kCropViewCornerLength / 2);
        } else if (type == CropCornerTypeLowerRight) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, kCropViewCornerLength - lineWidth / 2);
            vertical.center = CGPointMake(kCropViewCornerLength - lineWidth / 2, kCropViewCornerLength / 2);
        } else if (type == CropCornerTypeLowerLeft) {
            horizontal.center = CGPointMake(kCropViewCornerLength / 2, kCropViewCornerLength - lineWidth / 2);
            vertical.center = CGPointMake(lineWidth / 2, kCropViewCornerLength / 2);
        }
    }
    return self;
}

@end

@interface CropView ()

@property (strong, nonatomic) CropCornerView *upperLeft;
@property (strong, nonatomic) CropCornerView *upperRight;
@property (strong, nonatomic) CropCornerView *lowerRight;
@property (strong, nonatomic) CropCornerView *lowerLeft;

@property (strong, nonatomic) NSMutableArray *horizontalCropLines;
@property (strong, nonatomic) NSMutableArray *verticalCropLines;

@property (strong, nonatomic) NSMutableArray *horizontalGridLines;
@property (strong, nonatomic) NSMutableArray *verticalGridLines;

@property (weak, nonatomic) id<CropViewDelegate> delegate;

@property (assign, nonatomic) BOOL cropLinesDismissed;
@property (assign, nonatomic) BOOL gridLinesDismissed;

@end

@implementation CropView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor cropLineColor].CGColor;
        self.layer.borderWidth = 1;
        
        self.horizontalCropLines = [NSMutableArray array];
        for (int i = 0; i < kCropLines; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor cropLineColor];
            [self.horizontalCropLines addObject:line];
            [self addSubview:line];
        }
        
        self.verticalCropLines = [NSMutableArray array];
        for (int i = 0; i < kCropLines; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor cropLineColor];
            [self.verticalCropLines addObject:line];
            [self addSubview:line];
        }
        
        self.horizontalGridLines = [NSMutableArray array];
        for (int i = 0; i < kGridLines; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor gridLineColor];
            [self.horizontalGridLines addObject:line];
            [self addSubview:line];
        }
        
        self.verticalGridLines = [NSMutableArray array];
        for (int i = 0; i < kGridLines; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor gridLineColor];
            [self.verticalGridLines addObject:line];
            [self addSubview:line];
        }
        
        self.cropLinesDismissed = YES;
        self.gridLinesDismissed = YES;
        
        self.upperLeft = [[CropCornerView alloc] initWithCornerType:CropCornerTypeUpperLeft];
        self.upperLeft.center = CGPointMake(kCropViewCornerLength / 2, kCropViewCornerLength / 2);
        self.upperLeft.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:self.upperLeft];
        
        self.upperRight = [[CropCornerView alloc] initWithCornerType:CropCornerTypeUpperRight];
        self.upperRight.center = CGPointMake(self.frame.size.width - kCropViewCornerLength / 2, kCropViewCornerLength / 2);
        self.upperRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.upperRight];
        
        self.lowerRight = [[CropCornerView alloc] initWithCornerType:CropCornerTypeLowerRight];
        self.lowerRight.center = CGPointMake(self.frame.size.width - kCropViewCornerLength / 2, self.frame.size.height - kCropViewCornerLength / 2);
        self.lowerRight.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.lowerRight];
        
        self.lowerLeft = [[CropCornerView alloc] initWithCornerType:CropCornerTypeLowerLeft];
        self.lowerLeft.center = CGPointMake(kCropViewCornerLength / 2, self.frame.size.height - kCropViewCornerLength / 2);
        self.lowerLeft.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.lowerLeft];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        [self updateCropLines:NO];
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
        
        // ....
        
        self.frame = frame;
        
        // update crop lines
        [self updateCropLines:NO];
        
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

- (void)updateCropLines:(BOOL)animate
{
    // show
    if (self.cropLinesDismissed) {
        [self showCropLines];
    }
    
    void (^animationBlock)(void) = ^(void) {
        [self updateLines:self.horizontalCropLines horizontal:YES];
        [self updateLines:self.verticalCropLines horizontal:NO];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)updateGridLines:(BOOL)animate
{
    // show
    if (self.gridLinesDismissed) {
        [self showGridLines];
    }
    
    void (^animationBlock)(void) = ^(void) {
        
        [self updateLines:self.horizontalGridLines horizontal:YES];
        [self updateLines:self.verticalGridLines horizontal:NO];
    };
    
    if (animate) {
        [UIView animateWithDuration:0.25 animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)updateLines:(NSArray *)lines horizontal:(BOOL)horizontal
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *line = (UIView *)obj;
        if (horizontal) {
            line.frame = CGRectMake(0,
                                    (self.frame.size.height / (lines.count + 1)) * (idx + 1),
                                    self.frame.size.width,
                                    1 / [UIScreen mainScreen].scale);
        } else {
            line.frame = CGRectMake((self.frame.size.width / (lines.count + 1)) * (idx + 1),
                                    0,
                                    1 / [UIScreen mainScreen].scale,
                                    self.frame.size.height);
        }
    }];
}

- (void)dismissCropLines
{
    [UIView animateWithDuration:0.2 animations:^{
        [self dismissLines:self.horizontalCropLines];
        [self dismissLines:self.verticalCropLines];
    } completion:^(BOOL finished) {
        self.cropLinesDismissed = YES;
    }];
}

- (void)dismissGridLines
{
    [UIView animateWithDuration:0.2 animations:^{
        [self dismissLines:self.horizontalGridLines];
        [self dismissLines:self.verticalGridLines];
    } completion:^(BOOL finished) {
        self.gridLinesDismissed = YES;
    }];
}

- (void)dismissLines:(NSArray *)lines
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UIView *)obj).alpha = 0.0f;
    }];
}

- (void)showCropLines
{
    self.cropLinesDismissed = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self showLines:self.horizontalCropLines];
        [self showLines:self.verticalCropLines];
    }];
}

- (void)showGridLines
{
    self.gridLinesDismissed = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self showLines:self.horizontalGridLines];
        [self showLines:self.verticalGridLines];
    }];
}

- (void)showLines:(NSArray *)lines
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UIView *)obj).alpha = 1.0f;
    }];
}

@end

@interface PhotoTweakView () <UIScrollViewDelegate, CropViewDelegate>

@property (strong, nonatomic) PhotoScrollView *scrollView;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UISlider *slider;
@property (assign, nonatomic) CGSize originalSize;

@property (assign, nonatomic) BOOL manualZoomed;

// masks
@property (strong, nonatomic) UIView *topMask;
@property (strong, nonatomic) UIView *leftMask;
@property (strong, nonatomic) UIView *bottomMask;
@property (strong, nonatomic) UIView *rightMask;

// constants
@property (assign, nonatomic) CGSize maximumCanvasSize;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGPoint originalPoint;

@end

@implementation PhotoTweakView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    if (self = [super init]) {
        
#ifdef kInstruction
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
#endif
        self.image = image;
        self.frame = frame;
        
        // scale the image
        
        self.maximumCanvasSize = CGSizeMake(kMaximumCanvasWidthRatio * self.frame.size.width,
                                            kMaximumCanvasHeightRatio * self.frame.size.height - kCanvasHeaderHeigth);
        
        CGFloat scaleX = image.size.width / self.maximumCanvasSize.width;
        CGFloat scaleY = image.size.height / self.maximumCanvasSize.height;
        CGFloat scale = MAX(scaleX, scaleY);
        CGRect bounds = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale);
        self.originalSize = bounds.size;
        
        self.centerY = self.maximumCanvasSize.height / 2 + kCanvasHeaderHeigth;
        
#ifdef kShowCanvas
        UIView *canvas = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.maximumCanvasSize.width, self.maximumCanvasSize.height)];
        canvas.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        [self addSubview:canvas];
#endif
        
        self.scrollView = [[PhotoScrollView alloc] initWithFrame:bounds];
        self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        self.scrollView.bounces = YES;
        self.scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 10;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        
#ifdef kInstruction
        self.scrollView.layer.borderColor = [UIColor redColor].CGColor;
        self.scrollView.layer.borderWidth = 1;
        self.scrollView.showsVerticalScrollIndicator = YES;
        self.scrollView.showsHorizontalScrollIndicator = YES;
#endif
        [self addSubview:self.scrollView];
        
        self.photoContentView = [[PhotoContentView alloc] initWithImage:image];
        self.photoContentView.frame = self.scrollView.bounds;
        self.photoContentView.backgroundColor = [UIColor clearColor];
        self.photoContentView.userInteractionEnabled = YES;
        self.scrollView.photoContentView = self.photoContentView;
        [self.scrollView addSubview:self.photoContentView];
        
        self.cropView = [[CropView alloc] initWithFrame:self.scrollView.frame];
        self.cropView.center = self.scrollView.center;
        self.cropView.delegate = self;
        [self addSubview:self.cropView];
        
        UIColor *maskColor = [UIColor maskColor];
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
        [self updateMasks:NO];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
        self.slider.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) - 105);
        self.slider.minimumValue = 0.0f;
        self.slider.maximumValue = 1.0f;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        self.slider.value = 0.5;
        [self addSubview:self.slider];
        
        self.originalPoint = [self convertPoint:self.scrollView.center toView:self];
    }
    return self;
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
    return self.photoContentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.manualZoomed = YES;
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
        scaleFrame.size.width = self.scrollView.bounds.size.width - 1;
    }
    if (scaleFrame.size.height >= self.scrollView.bounds.size.height) {
        scaleFrame.size.height = self.scrollView.bounds.size.height - 1;
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2);
    CGRect bounds = self.scrollView.bounds;
    bounds.size.width = width;
    bounds.size.height = height;
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2);
    self.scrollView.contentOffset = newContentOffset;
    
    [UIView animateWithDuration:0.25 animations:^{
        // animate crop view
        cropView.bounds = CGRectMake(0, 0, newCropBounds.size.width, newCropBounds.size.height);
        cropView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        
        // zoom the specified area of scroll view
        CGRect zoomRect = [self convertRect:scaleFrame toView:self.scrollView.photoContentView];
        [self.scrollView zoomToRect:zoomRect animated:NO];
    }];

    self.manualZoomed = YES;
    
    // update masks
    [self updateMasks:YES];
    
    [self.cropView dismissCropLines];
    
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
    self.scrollView.contentOffsetX = MAX(self.scrollView.contentOffset.x, 0);
    self.scrollView.contentOffsetY = MAX(self.scrollView.contentOffset.y, 0);
    
    if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
        self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    
    if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
        self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
}

- (void)sliderValueChanged:(id)sender
{
    // update masks
    [self updateMasks:NO];
    
    // update grids
    [self.cropView updateGridLines:NO];
    
    // rotate scroll view
    self.angle = self.slider.value - 0.5;
    self.scrollView.transform = CGAffineTransformMakeRotation(self.angle);
    
    // position scroll view
    CGFloat width = cos(fabs(self.angle)) * self.cropView.frame.size.width + sin(fabs(self.angle)) * self.cropView.frame.size.height;
    CGFloat height = sin(fabs(self.angle)) * self.cropView.frame.size.width + cos(fabs(self.angle)) * self.cropView.frame.size.height;
    CGPoint center = self.scrollView.center;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2);
    self.scrollView.bounds = CGRectMake(0, 0, width, height);
    CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2);
    self.scrollView.contentOffset = newContentOffset;
    self.scrollView.center = center;
    
    // scale scroll view
    BOOL shouldScale = self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0;
    if (!self.manualZoomed || shouldScale) {
        [self.scrollView setZoomScale:[self.scrollView realScale] animated:NO];
        self.scrollView.minimumZoomScale = [self.scrollView realScale];
        [self.scrollView updatePhotoContentView];
        self.manualZoomed = NO;
    }
    
    [self checkScrollViewContentOffset];
}

- (void)sliderTouchEnded:(id)sender
{
    [self.cropView dismissGridLines];
}

- (CGPoint)photoContentOffset
{
    CGPoint point = [self convertPoint:self.scrollView.center toView:self];
    point = CGPointMake(self.scrollView.contentSize.width / 2 - self.scrollView.contentOffset.x,
                        self.scrollView.contentSize.height / 2 - self.scrollView.contentOffset.y);
    
    CGPoint scrollOrigin = CGPointMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y);
    
    // calculate the coordinate of center of content image view
    CGFloat angleToOrigin = atan(fabs(point.y) / fabs(point.x));
    
    CGFloat offsetX, offsetY;
    if (self.angle > 0) {
        offsetX = cos(self.angle + angleToOrigin) * distanceBetweenPoints(point, CGPointZero) + sin(self.angle) * self.scrollView.bounds.size.height;
        offsetY = sin(self.angle + angleToOrigin) * distanceBetweenPoints(point, CGPointZero);
        
        if (point.x < 0 && point.y > 0) {
            offsetX = -sin(M_PI_2 + self.angle - angleToOrigin) * distanceBetweenPoints(point, CGPointZero) + sin(self.angle) * self.scrollView.bounds.size.height;
            offsetY = cos(M_PI_2 + self.angle - angleToOrigin) * distanceBetweenPoints(point, CGPointZero);
        } else if (point.x > 0 && point.y < 0) {
            offsetX = offsetX;
            offsetY = offsetY;
        } else {
            if (point.x < 0) {
                offsetX = -cos(self.angle + angleToOrigin) * distanceBetweenPoints(point, CGPointZero) + sin(self.angle) * self.scrollView.bounds.size.height;
            }
            if (point.y < 0) {
                offsetY = -offsetY;
            }
        }
    } else {
        offsetX = cos(self.angle + angleToOrigin) * distanceBetweenPoints(point, CGPointZero);
        offsetY = sin(self.angle + angleToOrigin) * distanceBetweenPoints(point, CGPointZero) + sin(fabs(self.angle)) * self.scrollView.bounds.size.width;
        if (point.x < 0 && point.y > 0) {
            offsetX = -sin(self.angle + M_PI_2 - angleToOrigin) * distanceBetweenPoints(point, CGPointZero);
            offsetY = cos(self.angle + M_PI_2 - angleToOrigin) * distanceBetweenPoints(point, CGPointZero) + sin(fabs(self.angle)) * self.scrollView.bounds.size.width;
        } else if (point.x > 0 && point.y < 0) {
            offsetX = offsetX;
            offsetY = offsetY;
        } else {
            if (point.x < 0) {
                offsetX = -offsetX;
            }
            if (point.y < 0) {
                offsetY = -sin(self.angle + angleToOrigin) * distanceBetweenPoints(point, CGPointZero) + sin(fabs(self.angle)) * self.scrollView.bounds.size.width;
            }
        }
    }
    
    point = CGPointMake(scrollOrigin.x + offsetX, scrollOrigin.y + offsetY);
    _photoContentOffset = CGPointMake(point.x - self.originalPoint.x, point.y - self.originalPoint.y);
    return _photoContentOffset;
}

- (CGPoint)photoAnchorPoint
{
    CGFloat x = self.scrollView.contentSize.width / 2 - self.photoContentOffset.x;
    CGFloat y = self.scrollView.contentSize.height / 2 - self.photoContentOffset.y;
    return CGPointMake(x / self.scrollView.contentSize.width, y / self.scrollView.contentSize.height);
}

@end
