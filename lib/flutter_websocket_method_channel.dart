import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_websocket_platform_interface.dart';

/// An implementation of [FlutterWebsocketPlatform] that uses method channels.
class MethodChannelFlutterWebsocket extends FlutterWebsocketPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_websocket_method');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> sendPing() async {
    await methodChannel.invokeMethod<String>('sendPing');
  }

  @override
  Future<void> connect({required String url, int? connectionTimeout}) async {
    assert(url.isNotEmpty, "Connection url can't be empty");
    await methodChannel.invokeMethod('connect', {
      'url': url,
      "connectionTimeout": connectionTimeout ?? 60,
    });
  }

  @override
  Future<void> connectClose() async {
    await methodChannel.invokeMethod("closeConnect");
  }

  @override
  Future<void> openHeart() async {
    await methodChannel.invokeMethod("openHeart");
  }

  @override
  Future<void> closeHeart() async {
    await methodChannel.invokeMethod("closeHeart");
  }

  @override
  Future<void> send({String? message}) async {
    if (message != null) {
      await methodChannel.invokeMethod("send", {"message": message});
    }
  }

  @override
  Future<bool> isOpen() async {
    final result = await methodChannel.invokeMethod("isOpen");
    return result.toString() == "true";
  }
}
