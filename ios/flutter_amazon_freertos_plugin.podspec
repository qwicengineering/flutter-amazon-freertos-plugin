#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_amazon_freertos_plugin.podspec" to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = "flutter_amazon_freertos_plugin"
  s.version          = "0.0.1"
  s.summary          = "Flutter plugin for amazon freertos"
  s.description      = <<-DESC
This plugin uses amazon freertos ios sdk to connect to freertos devices via ble.
                       DESC
  s.homepage         = "https://qwic.nl"
  s.license          = { :file => "../LICENSE" }
  s.author           = { "QWIC" => "sri@sri.dev" }
  s.source           = { :path => "." }
  s.source_files = "Classes/**/*"
  s.public_header_files = "Classes/**/*.h"
  s.dependency "Flutter"
  s.platform = :ios, "11.0"

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64" }
  s.swift_version = "5.0"

  s.dependency "plugin_scaffold"
  s.dependency "AWSMobileClient", "~> 2.13.0"
  s.dependency "AmazonFreeRTOS", "~> 1.0.0"
end
