#import "FlutterWebsocketPlugin.h"
#if __has_include(<flutter_websocket/flutter_websocket-Swift.h>)
#import <flutter_websocket/flutter_websocket-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_websocket-Swift.h"
#endif

@implementation FlutterWebsocketPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWebsocketPlugin registerWithRegistrar:registrar];
}
@end
