platform :ios, '15.0'
use_frameworks!

target 'Call&Message' do
  pod 'SQLite.swift', '~> 0.13.3'
  pod 'SVProgressHUD'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    end
  end
end
