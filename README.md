<p align="center"><img src="https://cloud.githubusercontent.com/assets/4316898/6525211/cef0bbce-c43d-11e4-9b64-deb65c64c683.png" height="200"/>

</p>
<h1 align="center">PhotoTweaks</h1>

PhotoTweaks is an interface to crop photos. It can let user drag, rotate, scale the image, and crop it. You will find it mimics the interaction of Photos.app on iOS 8. :]

[![Build Status](https://travis-ci.org/itouch2/PhotoTweaks.svg)](https://travis-ci.org/itouch2/PhotoTweaks)
[![Pod Version](http://img.shields.io/cocoapods/v/PhotoTweaks.svg?style=flat)](http://cocoapods.org/?q=PhotoTweaks)
[![Platform](http://img.shields.io/cocoapods/p/PhotoTweaks.svg?style=flat)](http://cocoapods.org/?q=PhotoTweaks)
[![License](http://img.shields.io/cocoapods/l/PhotoTweaks.svg?style=flat)](https://github.com/itouch2/PhotoTweaks/blob/master/LICENSE)

## Usage

PhotoTweaksViewController offers all the operations to crop the photo, which includes translation, rotate and scale..

To use it,

```objective-c
UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:image];
photoTweaksViewController.delegate = self;
[picker pushViewController:photoTweaksViewController animated:YES];
```
Get the cropped image
```objective-c
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
    // cropped image
}
```
## Installation
PhotoTweaks is available on [CocoaPods](http://cocoapods.org). Add the follwing to your Podfile:
```ruby
pod 'PhotoTweaks', '~> 1.0.1'
```
Alternatively, you can manually drag the ```PhotoTweaks``` folder into your Xcode project.


## A Quick Peek

![screenshots](https://cloud.githubusercontent.com/assets/4316898/6712965/84ab1d16-cdca-11e4-912a-f437bbb02d42.gif)

## Protip
If using with an existing UIImagePickerController, be sure to set ```allowsEditing = NO``` otherwise you may force the user to crop with the native editing tool before showing PhotoTweaksViewController.
