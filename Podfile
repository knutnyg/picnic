source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def production
  pod 'BrightFutures', '5.0.1'
  pod 'SwiftHTTP', '2.0.1'
  pod 'JSONJoy-Swift', '2.0.1'
  pod 'SnapKit', '3.0.2'
  pod 'BButton', '4.0.2'
end

target 'picnic' do
  production
end

target 'picnicTests' do
  production
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end