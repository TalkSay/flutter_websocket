import 'flutter_websocket_platform_interface.dart';

class FlutterWebsocket {
  Future<String?> getPlatformVersion() {
    return FlutterWebsocketPlatform.instance.getPlatformVersion();
  }

  Future<void> connect({required String url, int? connectionTimeout}) {
    return FlutterWebsocketPlatform.instance.connect(
      url: url,
      connectionTimeout: connectionTimeout,
    );
  }

  Future<void> sendPing() {
    return FlutterWebsocketPlatform.instance.sendPing();
  }

  Future<void> connectClose() {
    return FlutterWebsocketPlatform.instance.connectClose();
  }

  Future<void> openHeart() async {
    return FlutterWebsocketPlatform.instance.openHeart();
  }

  Future<void> closeHeart() async {
    return FlutterWebsocketPlatform.instance.closeHeart();
  }

  Future<void> send({String? message}) async {
    return FlutterWebsocketPlatform.instance.send(message: message);
  }

  Future<bool> isOpen() async {
    return FlutterWebsocketPlatform.instance.isOpen();
  }
}
