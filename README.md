<p align="center"><img src="https://cloud.githubusercontent.com/assets/4316898/6525211/cef0bbce-c43d-11e4-9b64-deb65c64c683.png" height="200"/>

</p>
<h1 align="center">VellPhotoTweaks</h1>

VellPhotoTweaks is an interface to crop photos. It can let user drag, rotate, scale the image, and crop it. You will find it mimics the interaction of Photos.app on iOS 8. :]

[![Build Status](https://travis-ci.org/itouch2/PhotoTweaks.svg)](https://travis-ci.org/itouch2/PhotoTweaks)
[![Pod Version](http://img.shields.io/cocoapods/v/PhotoTweaks.svg?style=flat)](http://cocoapods.org/?q=PhotoTweaks)
[![Platform](http://img.shields.io/cocoapods/p/PhotoTweaks.svg?style=flat)](http://cocoapods.org/?q=PhotoTweaks)
[![License](http://img.shields.io/cocoapods/l/PhotoTweaks.svg?style=flat)](https://github.com/itouch2/PhotoTweaks/blob/master/LICENSE)

## Usage

PhotoTweaksViewController offers all the operations to crop the photo, which includes translation, rotate and scale.

- To use it,

```objective-c
UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:image];
photoTweaksViewController.delegate = self;
photoTweaksViewController.autoSaveToLibray = YES;
photoTweaksViewController.maxRotationAngle = M_PI;
[picker pushViewController:photoTweaksViewController animated:YES];
```

```maxRotationAngle``` is the property to set the maximum supported rotation angle and the default value is 180 degree.

- Get the cropped image
```objective-c
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
    // cropped image
}
```

### application usage

- change slider UI
```objective-c
UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 260, 20)];
slider.center = CGPointMake(150, 600);
slider.minimumValue = -M_PI_2;
slider.maximumValue = M_PI_2;
photoTweaksViewController.slider = slider;
```

You can change icons (reset button, save button, ...) like slider.

- change photo tweaks background color
```objective-c
photoTweaksViewController.backGroundColor = [UIColor redColor];
```

## Installation
Add the follwing to your Podfile:
```ruby
pod 'VellPhotoTweaks',:git => 'https://github.com/velljp/VellPhotoTweaks.git'
```
Alternatively, you can manually drag the ```VellPhotoTweaks``` folder into your Xcode project.

## Trouble Shooting
- button icon disappear

    set  ```Target -> VellPhotoTweaks -> Build Settting -> Build Activate Architecture Only -> No```


## A Quick Peek

![screenshots](https://cloud.githubusercontent.com/assets/4316898/6712965/84ab1d16-cdca-11e4-912a-f437bbb02d42.gif)

## Protip
If using with an existing UIImagePickerController, be sure to set ```allowsEditing = NO``` otherwise you may force the user to crop with the native editing tool before showing PhotoTweaksViewController.
