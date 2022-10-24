Pod::Spec.new do |s|
  s.name         = "SDLocalize"
  s.version      = "1.0"
  s.summary      = 'Efficient iOS localization solution.(Objc, swift, NSLocalizedString, xib)'
  s.homepage     = 'https://github.com/Meterwhite/SDLocalize'
  s.license      = 'MIT'
  s.author       = { "Meterwhite" => "meterwhite@outlook.com" }
  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/Meterwhite/SDLocalize.git", :tag => s.version}
  s.source_files = 'SDLocalize/**/*.{h,m}'
end
