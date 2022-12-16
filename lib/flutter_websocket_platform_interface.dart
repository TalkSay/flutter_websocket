import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_websocket_method_channel.dart';

abstract class FlutterWebsocketPlatform extends PlatformInterface {
  /// Constructs a FlutterWebsocketPlatform.
  FlutterWebsocketPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWebsocketPlatform _instance = MethodChannelFlutterWebsocket();

  /// The default instance of [FlutterWebsocketPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWebsocket].
  static FlutterWebsocketPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWebsocketPlatform] when
  /// they register themselves.
  static set instance(FlutterWebsocketPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> connect({required String url, int? connectionTimeout}) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> sendPing() {
    throw UnimplementedError('sendPing() has not been implemented.');
  }

  Future<void> connectClose() {
    throw UnimplementedError('connectClose() has not been implemented.');
  }

  Future<void> openHeart() async {
    throw UnimplementedError('openHeart() has not been implemented.');
  }

  Future<void> closeHeart() async {
    throw UnimplementedError('closeHeart() has not been implemented.');
  }

  Future<void> send({String? message}) async {
    throw UnimplementedError('send() has not been implemented.');
  }

  Future<bool> isOpen() async {
    throw UnimplementedError('isOpen() has not been implemented.');
  }
}
