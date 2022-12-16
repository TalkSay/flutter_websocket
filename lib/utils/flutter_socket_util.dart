import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_websocket/flutter_websocket.dart';
import 'package:flutter_websocket/models/connect_close_model.dart';
import 'package:flutter_websocket/models/result_model.dart';

class FlutterWebSocketUtil {
  FlutterWebSocketUtil._();

  static final FlutterWebSocketUtil _instance = FlutterWebSocketUtil._();

  factory FlutterWebSocketUtil() => _instance;

  static FlutterWebSocketUtil get instance => FlutterWebSocketUtil();

  //-----------------------------------------------------

  final EventChannel _eventChannel =
      const EventChannel('flutter_websocket_event');
  late StreamSubscription _stream;

  //-----------------------------------------------------

  // connect
  Future<void> connect(
    String url, {
    int? connectionTimeout,
    ConnectError? onError,
    ConnectClose? onClose,
    ConnectOpen? onOpen,
    MessageHandle? onMessage,
  }) async {
    _stream = _eventChannel.receiveBroadcastStream().listen((event) {
      final json = event as String;
      if (json.isNotEmpty) {
        final result = socketResultModelFromJson(json);
        switch (result.messageType) {
          case 'connectError': // Connection failed
            if (onError != null) onError(result.data);
            break;
          case 'connectClose':
            final data = result.data!;
            final error = socketConnectCloseModelFromJson(data);
            if (onClose != null) onClose(error);
            break;
          case 'connectSuccess':
            if (onOpen != null) onOpen(result.data);
            break;
          case 'connectMessage':
            if (onMessage != null) onMessage(result.data);
            break;
          default:
            break;
        }
      }
    });
    await FlutterWebsocket().connect(
      url: url,
      connectionTimeout: connectionTimeout,
    );
  }

  /// Disconnect
  Future<void> close() async {
    await FlutterWebsocket().connectClose();
    _stream.cancel();
  }

  /// open heartbeat
  Future<void> openHeart() async {
    await FlutterWebsocket().openHeart();
  }

  /// send ping
  Future<void> sendPing() async {
    await FlutterWebsocket().sendPing();
  }

  /// turn off heartbeat
  Future<void> closeHeart() async {
    await FlutterWebsocket().closeHeart();
  }

  /// Send a message
  Future<void> send({String? message}) async {
    if (message != null) {
      await FlutterWebsocket().send(message: message);
    }
  }
}

/// Connection failure callback
typedef ConnectError = void Function(String? message);

/// The connection is closed callback
/// The server actively disconnects, or accidentally disconnects the callback
typedef ConnectClose = void Function(SocketConnectCloseModel closeDetail);

/// Connection success callback, only called once
typedef ConnectOpen = void Function(String? successUrl);

/// receive message callback
typedef MessageHandle = void Function(String? message);
