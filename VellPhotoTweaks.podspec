Pod::Spec.new do |spec|
  spec.name             = 'VellPhotoTweaks'
  spec.version          = '2.0.1'
  spec.license          = 'MIT' 
  spec.homepage         = 'https://github.com/velljp/VellPhotoTweaks'
  spec.authors          = {'Tu You' => 'yoututouch@gmail.com'}
  spec.summary          = 'Drag, Rotate, Scale and Crop.'
  spec.source           = {:git => 'https://github.com/velljp/VellPhotoTweaks.git', :tag => '2.0.1'}
  spec.source_files     = 'VellPhotoTweaks/VellPhotoTweaks/*'
  spec.resources        = ['VellPhotoTweaks/VellPhotoTweaks/resource/VellPhotoTweaks.bundle']
  spec.framework        = 'Foundation', 'CoreGraphics', 'UIKit'
  spec.requires_arc     = true
  spec.platform         = :ios, '7.0'
  spec.screenshot       = 'https://cloud.githubusercontent.com/assets/4316898/6525485/ce2d65ae-c440-11e4-8a73-c461a3f31b5f.png'
end
