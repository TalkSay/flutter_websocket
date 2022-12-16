import 'dart:convert';
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
  final String _url =
      "wss://devapi.talksay.live/socket"; //"wss://6f23-105-163-63-215.eu.ngrok.io/";
  Timer? _timer;
  final _flutterWebsocketPlugin = FlutterWebsocket();
  final _socketClient = FlutterWebSocketUtil();
  String accessToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJKb2tlbiIsImV4cCI6MTY3MTE5MjU2MSwiaGFzUGVybWl0Ijp0cnVlLCJpYXQiOjE2NzExODg5NjEsImluc2VydGVkQXQiOiIyMDIyLTA1LTMxVDEzOjM1OjIzLjgzMDU3NVoiLCJpc0d1ZXN0IjpmYWxzZSwiaXNzIjoiSm9rZW4iLCJqdGkiOiIyc29rMzBkOGNkNTZicHZmamswM2NjbjMiLCJuYmYiOjE2NzExODg5NjEsInVzZXJJZCI6ImNmZDBkOTRkLTk0MWMtNDI5Zi1hYjdmLTk3YTVjZmY4YjIxZCIsInVzZXJuYW1lIjoiZGVtbyJ9.38HdIc-Om_hvg2d0kdrfa91I8QM5CI290aga2Al3KAs";
  String refresToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJKb2tlbiIsImV4cCI6MTY3Mzc4MDk2MSwiaWF0IjoxNjcxMTg4OTYxLCJpc3MiOiJKb2tlbiIsImp0aSI6IjJzb2szMGQ4Y202a2RwdmZqazAzY2NvMyIsIm5iZiI6MTY3MTE4ODk2MSwidG9rZW5WZXJzaW9uIjoxLCJ1c2VySWQiOiJjZmQwZDk0ZC05NDFjLTQyOWYtYWI3Zi05N2E1Y2ZmOGIyMWQifQ.y80GWDXszKslQ-N5g5fEIiBQPAR4EAOUNlRZm-_32Pk";

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

  Map<String, dynamic> authMap() => {
        "op": "auth",
        "d": {
          "accessToken": accessToken,
          "refreshToken": refresToken,
          "reconnectToVoice": true,
          "currentRoomId": null,
          "muted": false,
          "deafened": false,
          "fcmToken": null
        }
      };

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
                connect();
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
            customButton(
              "Send ping",
              () async {
                await _socketClient.sendPing();
              },
            ),
            customButton(
              "Send ping 2",
              () async {
                await _socketClient.send(message: "ping");
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> connect() async {
    _socketClient.connect(
      _url,
      connectionTimeout: 8,
      onClose: (SocketConnectCloseModel detail) {
        if (kDebugMode) {
          print('ONCLOSE');
          print(detail.toString());
          print('ONCLOSE');
        }
      },
      onMessage: (String? message) {
        if (kDebugMode) {
          print('\n\nON MESSAGE');
          print(message);
          print('ON MESSAGE');
          if (message != null && message != "pong") {
            Map<String, dynamic> json = jsonDecode(message);
            if (json.containsKey("op") && json["op"] == "new-tokens") {
              final acessToken = json["d"]["accessToken"];
              final rereshToken = json["d"]["refreshToken"];
              setState(() {
                accessToken = acessToken;
                refresToken = rereshToken;
              });
              _socketClient.close();
              connect();
            }
          }
        }
      },
      onOpen: (String? url) {
        if (kDebugMode) {
          print('ON OPEN');
          print(url);
          print('ON OPEN');
        }
        final map = jsonEncode(authMap());
        print(map);
        _socketClient.send(message: map);
        _socketClient.openHeart();
        // pingPong();
      },
      onError: (String? message) {
        if (kDebugMode) {
          print('ON ERROR');
          print(message);
          print('ON ERROR');
        }
      },
    );
  }

  void pingPong() {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      // var encoded = DateTime.now().toIso8601String();
      _socketClient.send(message: "ping");
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
