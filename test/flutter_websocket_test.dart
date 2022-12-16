import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_websocket/flutter_websocket.dart';
import 'package:flutter_websocket/flutter_websocket_platform_interface.dart';
import 'package:flutter_websocket/flutter_websocket_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWebsocketPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWebsocketPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> closeHeart() {
    // TODO: implement closeHeart
    throw UnimplementedError();
  }

  @override
  Future<void> connect({required String url, int? connectionTimeout}) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<void> connectClose() {
    // TODO: implement connectClose
    throw UnimplementedError();
  }

  @override
  Future<bool> isOpen() {
    // TODO: implement isOpen
    throw UnimplementedError();
  }

  @override
  Future<void> openHeart() {
    // TODO: implement openHeart
    throw UnimplementedError();
  }

  @override
  Future<void> send({String? message}) {
    // TODO: implement send
    throw UnimplementedError();
  }
  
  @override
  Future<void> sendPing() {
    // TODO: implement sendPing
    throw UnimplementedError();
  }
}

void main() {
  final FlutterWebsocketPlatform initialPlatform =
      FlutterWebsocketPlatform.instance;

  test('$MethodChannelFlutterWebsocket is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWebsocket>());
  });

  test('getPlatformVersion', () async {
    FlutterWebsocket flutterWebsocketPlugin = FlutterWebsocket();
    MockFlutterWebsocketPlatform fakePlatform = MockFlutterWebsocketPlatform();
    FlutterWebsocketPlatform.instance = fakePlatform;

    expect(await flutterWebsocketPlugin.getPlatformVersion(), '42');
  });
}
