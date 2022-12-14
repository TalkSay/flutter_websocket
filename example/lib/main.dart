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
  String _url = "";
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
              () {},
            ),
            customButton(
              "Open heartbeat",
              () {},
            ),
            customButton(
              "Is connected?",
              () {},
            ),
          ],
        ),
      ),
    );
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
