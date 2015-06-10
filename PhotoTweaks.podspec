Pod::Spec.new do |spec|
  spec.name             = 'PhotoTweaks'
  spec.version          = '1.0.2'
  spec.license          = 'MIT' 
  spec.homepage         = 'https://github.com/itouch2/PhotoTweaks'
  spec.authors          = {'Tu You' => 'yoututouch@gmail.com'}
  spec.summary          = 'Drag, Rotate, Scale and Crop.'
  spec.source           = {:git => 'https://github.com/itouch2/PhotoTweaks.git', :tag => '1.0.2'}
  spec.source_files     = 'PhotoTweaks/PhotoTweaks/*.{h,m}'
  spec.framework        = 'Foundation', 'CoreGraphics', 'UIKit'
  spec.requires_arc     = true
  spec.platform         = :ios, '7.0'
  spec.screenshot       = 'https://cloud.githubusercontent.com/assets/4316898/6525485/ce2d65ae-c440-11e4-8a73-c461a3f31b5f.png'
end
