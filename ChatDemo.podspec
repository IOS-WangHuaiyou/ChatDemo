#
#  Be sure to run `pod spec lint ChatDemo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
s.name         = "ChatDemo"
s.version      = "1.0.0"
s.ios.deployment_target = '6.0'
s.osx.deployment_target = '10.8'
s.summary      = "A fast and convenient conversion between JSON and model"
s.homepage     = "https://github.com/IOS-WangHuaiyou/ChatDemo"
s.license      = "MIT"
s.author       = { "wanghuaiyou" => "915325011@qq.com" }
s.source       = { :git => "https://github.com/IOS-WangHuaiyou/ChatDemo.git", :tag => s.version }
s.source_files  = "ChatDemo"
s.requires_arc = true
end
