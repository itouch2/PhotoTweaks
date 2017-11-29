//
//  PhotoTweaksViewController.h
//  PhotoTweaks
//
//  Created by Tu You on 14/12/5.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VellPhotoTweakView.h"

@protocol VellPhotoTweaksViewControllerDelegate;

/**
 The photo tweaks controller.
 */
@interface VellPhotoTweaksViewController : UIViewController

@property (strong, nonatomic) VellPhotoTweakView *photoView;

/**
 Image to process.
 */
@property (nonatomic, strong, readonly) UIImage *image;

/**
 Flag indicating whether the image cropped will be saved to photo library automatically. Defaults to YES.
 */
@property (nonatomic, assign) BOOL autoSaveToLibray;

/**
 Max rotation angle
 */
@property (nonatomic, assign) CGFloat maxRotationAngle;

/**
 The optional photo tweaks controller delegate.
 */
@property (nonatomic, weak) id<VellPhotoTweaksViewControllerDelegate> delegate;

/**
 Save action button's default title color
 */
@property (nonatomic, strong) UIColor *saveButtonTitleColor;

/**
 Save action button's highlight title color
 */
@property (nonatomic, strong) UIColor *saveButtonHighlightTitleColor;

/**
 Cancel action button's default title color
 */
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;

/**
 Cancel action button's highlight title color
 */
@property (nonatomic, strong) UIColor *cancelButtonHighlightTitleColor;

/**
 Reset action button's default title color
 */
@property (nonatomic, strong) UIColor *resetButtonTitleColor;

/**
 Reset action button's highlight title color
 */
@property (nonatomic, strong) UIColor *resetButtonHighlightTitleColor;

/**
 Slider tint color
 */
@property (nonatomic, strong) UIColor *sliderTintColor;

@property (nonatomic, assign) CGFloat sliderAlpha;

@property (nonatomic, strong) UIColor *backGroundColor;

@property (nonatomic, strong) UIButton *cancelBtn; // cancel button
@property (nonatomic, strong) UIButton *saveBtn; // save button
/**
 Creates a photo tweaks view controller with the image to process.
 */
- (instancetype)initWithImage:(UIImage *)image;

@end

/**
 The photo tweaks controller delegate
 */
@protocol VellPhotoTweaksViewControllerDelegate <NSObject>

/**
 Called on image cropped.
 */
- (void)vellPhotoTweaksController:(VellPhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage;

/**
 Called on cropping image canceled
 */
- (void)vellPhotoTweaksControllerDidCancel:(VellPhotoTweaksViewController *)controller;

@end
