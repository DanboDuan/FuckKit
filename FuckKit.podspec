Pod::Spec.new do |s|
  s.name             = 'FuckKit'
  s.version          = '1.1.0'
  s.summary          = 'Rangers Kit.'
  s.description      = 'Rangers Kit.'
  s.homepage         = 'https://github.com/DanboDuan'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bob' => 'bob170731@gmail.com' }
  s.source           = {
    :git => 'git@github.com:DanboDuan/FuckKit.git',
    :tag => s.version.to_s
  }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.static_framework = true
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }
  
  s.subspec 'Macros' do |d|
    d.frameworks =  'Foundation'
    d.source_files = 'FuckKit/Macros/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Macros/*.h'
  end
  
  s.subspec 'GZIP' do |d|
    d.library = 'z'
    d.frameworks =  'Foundation'
    d.source_files = 'FuckKit/GZIP/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/GZIP/**/*.h'
  end
  
  s.subspec 'Keychain' do |d|
    d.frameworks =  'Foundation', 'Security'
    d.source_files = 'FuckKit/Keychain/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Keychain/**/*.h'
  end
  
  s.subspec 'Timer' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.source_files = 'FuckKit/Timer/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Timer/**/*.h'
  end
  
  s.subspec 'Foundation' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.source_files = 'FuckKit/Foundation/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Foundation/**/*.h'
  end
  
  s.subspec 'Security' do |d|
    d.source_files = 'FuckKit/Security/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Security/**/*.h'
  end
  
  s.subspec 'IDFA' do |d|
    d.dependency 'FuckKit/Foundation'
    d.frameworks =  'AdSupport'
    d.source_files = 'FuckKit/IDFA/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/IDFA/**/*.h'
  end
  
  s.subspec 'Defaults' do |d|
    d.dependency 'FuckKit/Foundation'
    d.dependency 'FuckKit/Macros'
    d.frameworks =  'Foundation'
    d.source_files = 'FuckKit/Defaults/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Defaults/**/*.h'
  end
  
  s.subspec 'Reachability' do |d|
    d.frameworks =  'Foundation', 'CoreTelephony', 'SystemConfiguration', 'CoreFoundation', 'UIKit'
    d.source_files = 'FuckKit/Reachability/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Reachability/**/*.h'
  end
  
  s.subspec 'Service' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.dependency 'FuckKit/SectionFunction'
    d.dependency 'FuckKit/SectionBlock'
    d.dependency 'FuckKit/SectionMethod'
    d.source_files = 'FuckKit/Service/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Service/**/*.h'
  end
  
  ## 前端需要引入bridge.js minify后的bridge.min.js，在组件目录下JS
  s.subspec 'JSBridge' do |d|
    d.frameworks =  'Foundation','WebKit'
    d.dependency 'FuckKit/Macros'
    d.dependency 'FuckKit/Foundation'
    d.source_files = 'FuckKit/JSBridge/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/JSBridge/**/*.h'
  end
  
  s.subspec 'SectionData' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.source_files = 'FuckKit/SectionData/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/SectionData/**/*.h'
  end
  
  s.subspec 'SectionBlock' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.source_files = 'FuckKit/SectionBlock/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/SectionBlock/**/*.h'
  end
  
  s.subspec 'SectionFunction' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.source_files = 'FuckKit/SectionFunction/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/SectionFunction/**/*.h'
  end
  
  s.subspec 'SectionMethod' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Macros'
    d.source_files = 'FuckKit/SectionMethod/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/SectionMethod/**/*.h'
  end
  
  s.subspec 'Notification' do |d|
    d.dependency 'FuckKit/Macros'
    d.dependency 'FuckKit/Foundation'
    d.source_files = 'FuckKit/Notification/**/*.{h,m,c}'
    d.public_header_files = 'FuckKit/Notification/**/*.h'
  end
  
end
