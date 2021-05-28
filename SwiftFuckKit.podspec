
Pod::Spec.new do |s|
  s.name             = 'SwiftFuckKit'
  s.version          = '1.1.0'
  s.summary          = 'A short description of SwiftFuckKit.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DanboDuan/FuckKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bob' => 'bob170731@gmail.com' }
  s.source           = {
    :git => 'git@github.com:DanboDuan/FuckKit.git',
    :tag => s.version.to_s
  }
  s.requires_arc = true
  s.static_framework = true
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = {
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }
  
  s.subspec 'SectionFunction' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/SectionFunction'
    d.source_files = 'SwiftFuckKit/SectionFunction/*.{swift}'
  end
  
  s.subspec 'Service' do |d|
    d.frameworks =  'Foundation'
    d.dependency 'FuckKit/Service'
    d.source_files = 'SwiftFuckKit/Service/*.{swift}'
  end
  
  s.subspec 'Codable' do |d|
    d.frameworks =  'Foundation'
    d.source_files = 'SwiftFuckKit/Codable/*.{swift}'
  end
  
end
# if STRIP_INSTALLED_PRODUCT and STRIP_STYLE=all lead to exported symbols striped
# set STRIP_STYLE=non-global
