import 'dart:convert';

SocketConnectCloseModel socketConnectCloseModelFromJson(String str) =>
    SocketConnectCloseModel.fromJson(json.decode(str));

String socketConnectCloseModelToJson(SocketConnectCloseModel data) =>
    json.encode(data.toJson());

/// socket Connection failure details
class SocketConnectCloseModel {
  SocketConnectCloseModel({
    this.code,
    this.message,
    this.remote,
  });

  /// error code
  int? code;

  /// error details
  String? message;

  /// Whether to connect remotely
  bool? remote;

  factory SocketConnectCloseModel.fromJson(Map<String, dynamic> json) =>
      SocketConnectCloseModel(
        code: json["code"],
        message: json["message"],
        remote: json["remote"].toString() == "true",
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "remote": remote,
      };
}
