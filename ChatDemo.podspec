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
s.summary      = "A fast and convenient conversion between JSON and model"
s.homepage     = "https://github.com/IOS-WangHuaiyou/ChatDemo"
s.license      = "MIT"
s.author       = { "wanghuaiyou" => "915325011@qq.com" }
s.source       = { :git => "https://github.com/IOS-WangHuaiyou/ChatDemo.git", :commit => "eb2973401dc443989dad8ed79a04cbf97f322b31" }
s.source_files  = "ChatDemo/**/*.{h,m}"
s.requires_arc = true
s.frameworks = "Foundation", "UIKit"
end
