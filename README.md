<p align="center"><img src="https://cloud.githubusercontent.com/assets/4316898/6525211/cef0bbce-c43d-11e4-9b64-deb65c64c683.png" height="200"/>

</p>
<h1 align="center">PhotoTweaks</h1>

PhotoTweaks is an interface to crop photo, and it can rotate and scale the image. You will find it mimics the interaction in photo library on iOS 7. :]

## Usage

PhotoTweaksViewController offers all the operations to crop the photo, which include crop and rotate the photo.

To use it, 

```objective-c
  UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
  PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:image];
  photoTweaksViewController.delegate = self;
  [picker pushViewController:photoTweaksViewController animated:YES];
```

## A Quick Peek

![screenshots](https://cloud.githubusercontent.com/assets/4316898/6525485/ce2d65ae-c440-11e4-8a73-c461a3f31b5f.png)

