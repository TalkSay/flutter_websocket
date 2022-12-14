import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_websocket/flutter_websocket.dart';
import 'package:flutter_websocket/models/connect_close_model.dart';
import 'package:flutter_websocket/utils/flutter_socket_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final String _url = "wss://6f23-105-163-63-215.eu.ngrok.io/";
  Timer? _timer;
  final _flutterWebsocketPlugin = FlutterWebsocket();
  final _socketClient = FlutterWebSocketUtil();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterWebsocketPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            customButton(
              "Connect",
              () {
                _socketClient.connect(
                  _url,
                  onClose: (SocketConnectCloseModel detail) {
                    if (kDebugMode) {
                      print('ONCLOSE');
                      print(detail.toString());
                      print('ONCLOSE');
                    }
                  },
                  onMessage: (String? message) {
                    if (kDebugMode) {
                      print('ON MESSAGE');
                      print(message);
                      print('ON MESSAGE');
                    }
                  },
                  onOpen: (String? url) {
                    if (kDebugMode) {
                      print('ON OPEN');
                      print(url);
                      print('ON OPEN');
                    }
                    _socketClient.openHeart();
                    pingPong();
                  },
                  onError: (String? message) {
                    if (kDebugMode) {
                      print('ON ERROR');
                      print(message);
                      print('ON ERROR');
                    }
                  },
                );
              },
            ),
            customButton(
              "Disconnect",
              () {
                _socketClient.close();
              },
            ),
            customButton(
              "Open heartbeat",
              () {
                _socketClient.openHeart();
              },
            ),
            customButton(
              "Is connected?",
              () async {
                bool isConnected = await FlutterWebsocket().isOpen();
                print('IS CONNECTED');
                print(isConnected);
                print('IS CONNECTED');
              },
            ),
            customButton(
              "Sink message",
              () async {
                var encoded = DateTime.now().toIso8601String();
                await _socketClient.send(message: encoded);
              },
            ),
          ],
        ),
      ),
    );
  }

  void pingPong() {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var encoded = DateTime.now().toIso8601String();
      _socketClient.send(message: encoded);
    });
  }

  Widget customButton(String button, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 45),
        ),
        child: Text(button),
      ),
    );
  }
}
