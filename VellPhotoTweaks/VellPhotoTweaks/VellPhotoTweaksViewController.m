//
//  PhotoTweaksViewController.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/5.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "VellPhotoTweaksViewController.h"
#import "VellPhotoTweakView.h"
#import "UIColor+Tweak.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface VellPhotoTweaksViewController ()

@property (strong, nonatomic) VellPhotoTweakView *photoView;
@property (assign, nonatomic) CGFloat btnOriginX;
@property (assign, nonatomic) CGFloat btnMargin;

@end

@implementation VellPhotoTweaksViewController

- (instancetype)initWithImage:(UIImage *)image
{
  if (self = [super init]) {
    _image = image;
    _autoSaveToLibray = YES;
    _maxRotationAngle = kMaxRotationAngle;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationController.navigationBarHidden = YES;
  
  if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
    self.automaticallyAdjustsScrollViewInsets = NO;
  }
  
  self.view.clipsToBounds = YES;
  self.view.backgroundColor = [UIColor photoTweakCanvasBackgroundColor];
  
  [self setupSubviews];
}

- (void)setupSubviews
{
  self.btnOriginX = self.view.frame.size.width * 0.10;
  self.btnMargin = self.view.frame.size.width * 0.07;
  
  [self setupPhotoViews];
  
  UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  cancelBtn.frame = CGRectMake(self.btnOriginX, CGRectGetHeight(self.view.frame)*(1-0.08), self.btnMargin, self.btnMargin);
  UIImage *img = [UIImage imageNamed:@"back" inBundle:[NSBundle bundleForClass:self] compatibleWithTraitCollection:nil];
  [cancelBtn setImage:img forState:UIControlStateNormal];
  cancelBtn.tintColor = [UIColor whiteColor];
  [cancelBtn addTarget:self action:@selector(cancelBtnTapped) forControlEvents:UIControlEventTouchUpInside];
  
  self.cancelBtn = cancelBtn;
  [self.view addSubview:self.cancelBtn];
  
  UIButton *cropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  cropBtn.frame = CGRectMake(5*self.btnOriginX + 4*self.btnMargin, CGRectGetHeight(self.view.frame)*(1-0.08), self.btnMargin, self.btnMargin);
  img = [UIImage imageNamed:@"save" inBundle:[NSBundle bundleForClass:self] compatibleWithTraitCollection:nil];
  [cropBtn setImage:img forState:UIControlStateNormal];
  cropBtn.tintColor = [UIColor whiteColor];
  [cropBtn addTarget:self action:@selector(saveBtnTapped) forControlEvents:UIControlEventTouchUpInside];
  self.saveBtn = cropBtn;
  [self.view addSubview:self.saveBtn];
}

- (void)setupPhotoViews
{
  VellPhotoTweakView *pv = [[VellPhotoTweakView alloc] initWithFrame:self.view.bounds image:self.image maxRotationAngle:self.maxRotationAngle];
  pv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  pv.slider.alpha = 0.0;
  
  self.photoView = pv;
  [self.view addSubview:pv];
}

- (void)cancelBtnTapped
{
  [self.delegate vellPhotoTweaksControllerDidCancel:self];
}

- (void)saveBtnTapped
{
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  // translate
  CGPoint translation = [self.photoView photoTranslation];
  transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
  
  // rotate
  transform = CGAffineTransformRotate(transform, self.photoView.angle);
  
  // scale
  CGAffineTransform t = self.photoView.photoContentView.transform;
  CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
  CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
  transform = CGAffineTransformScale(transform, xScale, yScale);
  
  CGImageRef imageRef = [self newTransformedImage:transform
                                      sourceImage:self.image.CGImage
                                       sourceSize:self.image.size
                                sourceOrientation:self.image.imageOrientation
                                      outputWidth:self.image.size.width
                                         cropSize:self.photoView.cropView.frame.size
                                    imageViewSize:self.photoView.photoContentView.bounds.size];
  
  UIImage *image = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  
  if (self.autoSaveToLibray) {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
      if (!error) {
      }
    }];
  }
  
  [self.delegate vellPhotoTweaksController:self didFinishWithCroppedImage:image];
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
  CGSize srcSize = size;
  CGFloat rotation = 0.0;
  
  switch(orientation)
  {
    case UIImageOrientationUp: {
      rotation = 0;
    } break;
    case UIImageOrientationDown: {
      rotation = M_PI;
    } break;
    case UIImageOrientationLeft:{
      rotation = M_PI_2;
      srcSize = CGSizeMake(size.height, size.width);
    } break;
    case UIImageOrientationRight: {
      rotation = -M_PI_2;
      srcSize = CGSizeMake(size.height, size.width);
    } break;
    default:
      break;
  }
  
  CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
  
  CGContextRef context = CGBitmapContextCreate(NULL,
                                               size.width,
                                               size.height,
                                               8,  //CGImageGetBitsPerComponent(source),
                                               0,
                                               rgbColorSpace,//CGImageGetColorSpace(source),
                                               kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big//(CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                               );
  CGColorSpaceRelease(rgbColorSpace);
  
  CGContextSetInterpolationQuality(context, quality);
  CGContextTranslateCTM(context,  size.width/2,  size.height/2);
  CGContextRotateCTM(context,rotation);
  
  CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                         -srcSize.height/2,
                                         srcSize.width,
                                         srcSize.height),
                     source);
  
  CGImageRef resultRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  
  return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
  CGImageRef source = [self newScaledImage:sourceImage
                           withOrientation:sourceOrientation
                                    toSize:sourceSize
                               withQuality:kCGInterpolationNone];
  
  CGFloat aspect = cropSize.height/cropSize.width;
  CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
  
  CGContextRef context = CGBitmapContextCreate(NULL,
                                               outputSize.width,
                                               outputSize.height,
                                               CGImageGetBitsPerComponent(source),
                                               0,
                                               CGImageGetColorSpace(source),
                                               CGImageGetBitmapInfo(source));
  CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
  CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
  
  CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                          outputSize.height / cropSize.height);
  uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
  uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
  CGContextConcatCTM(context, uiCoords);
  
  CGContextConcatCTM(context, transform);
  CGContextScaleCTM(context, 1.0, -1.0);
  
  CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                         -imageViewSize.height/2.0,
                                         imageViewSize.width,
                                         imageViewSize.height)
                     , source);
  
  CGImageRef resultRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGImageRelease(source);
  return resultRef;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

@end
