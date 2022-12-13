import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_websocket_platform_interface.dart';

/// An implementation of [FlutterWebsocketPlatform] that uses method channels.
class MethodChannelFlutterWebsocket extends FlutterWebsocketPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_websocket');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
