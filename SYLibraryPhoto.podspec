Pod::Spec.new do |s|
  s.name         = "SYLibraryPhoto"
  s.version      = "1.0.0"
  s.summary      = "SYLibraryPhoto used to select photo from AssetsLibrary."
  s.homepage     = "https://github.com/potato512/SYLibraryPhoto"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/potato512/SYLibraryPhoto.git", :tag => "#{s.version}" }
  s.source_files  = "SYLibraryPhoto/*.{h,m}"
  s.frameworks   = "UIKit", "AssetsLibrary"
  s.requires_arc = true
end