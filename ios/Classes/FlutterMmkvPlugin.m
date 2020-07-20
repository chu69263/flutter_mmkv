#import "FlutterMmkvPlugin.h"
#if __has_include(<flutter_mmkv/flutter_mmkv-Swift.h>)
#import <flutter_mmkv/flutter_mmkv-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_mmkv-Swift.h"
#endif

@implementation FlutterMmkvPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMmkvPlugin registerWithRegistrar:registrar];
}
@end
