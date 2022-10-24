Pod::Spec.new do |s|
  s.name         = "SDLocalize"
  s.version      = "1.1"
  s.summary      = 'Efficient iOS localization solution.(Objc, swift, NSLocalizedString, xib)'
  s.homepage     = 'https://github.com/Meterwhite/SDLocalize'
  s.license      = 'MIT'
  s.author       = { "Meterwhite" => "meterwhite@outlook.com" }
  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '6.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/Meterwhite/SDLocalize.git", :tag => s.version}
  s.source_files = 'SDLocalize/**/*.{h,m}'
end
