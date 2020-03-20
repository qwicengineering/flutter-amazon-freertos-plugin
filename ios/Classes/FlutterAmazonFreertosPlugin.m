#import "FlutterAmazonFreeRTOSPlugin.h"
#if __has_include(<flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin-Swift.h>)
#import <flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_amazon_freertos_plugin-Swift.h"
#endif

@implementation FlutterAmazonFreeRTOSPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAmazonFreeRTOSPlugin registerWithRegistrar:registrar];
}
@end
