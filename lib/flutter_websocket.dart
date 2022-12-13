
import 'flutter_websocket_platform_interface.dart';

class FlutterWebsocket {
  Future<String?> getPlatformVersion() {
    return FlutterWebsocketPlatform.instance.getPlatformVersion();
  }
}
