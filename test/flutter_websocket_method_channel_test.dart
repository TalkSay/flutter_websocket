import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_websocket/flutter_websocket_method_channel.dart';

void main() {
  MethodChannelFlutterWebsocket platform = MethodChannelFlutterWebsocket();
  const MethodChannel channel = MethodChannel('flutter_websocket');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
