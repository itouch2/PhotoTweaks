//
//  AppDelegate.m
//  PhotoTweaks
//
//  Created by Tu You on 14/11/28.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "AppDelegate.h"
#import "VellPhotoTweaksViewController.h"

@interface AppDelegate () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, VellPhotoTweaksViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  picker.delegate = self;
  picker.allowsEditing = NO;
  picker.navigationBarHidden = YES;
  self.window.rootViewController = picker;
  
  return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
  VellPhotoTweaksViewController *photoTweaksViewController = [[VellPhotoTweaksViewController alloc] initWithImage:image];
  photoTweaksViewController.delegate = self;
  photoTweaksViewController.autoSaveToLibray = YES;
  photoTweaksViewController.maxRotationAngle = M_PI;
  photoTweaksViewController.backGroundColor = [UIColor redColor];
  photoTweaksViewController.sliderAlpha = 1.0;
  [picker pushViewController:photoTweaksViewController animated:YES];
  photoTweaksViewController.sliderTintColor = [UIColor whiteColor];
  
//  UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 260, 20)];
//  slider.center = CGPointMake(150, 600);
//  slider.minimumValue = -M_PI_2;
//  slider.maximumValue = M_PI_2;
//  photoTweaksViewController.slider = slider;
}

- (void)vellPhotoTweaksController:(VellPhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
  [controller.navigationController popViewControllerAnimated:YES];
}

- (void)vellPhotoTweaksControllerDidCancel:(VellPhotoTweaksViewController *)controller
{
  [controller.navigationController popViewControllerAnimated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
