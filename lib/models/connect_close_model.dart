// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

SocketConnectCloseModel socketConnectCloseModelFromJson(String str) =>
    SocketConnectCloseModel.fromJson(json.decode(str));

String socketConnectCloseModelToJson(SocketConnectCloseModel data) =>
    json.encode(data.toJson());

/// socket Connection failure details
class SocketConnectCloseModel {
  /// error code
  int? code;

  /// error details
  String? message;

  /// Whether to connect remotely
  bool? remote;

  SocketConnectCloseModel({
    this.code,
    this.message,
    this.remote,
  });

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

  @override
  bool operator ==(covariant SocketConnectCloseModel other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.message == message &&
        other.remote == remote;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ remote.hashCode;

  @override
  String toString() =>
      'SocketConnectCloseModel(code: $code, message: $message, remote: $remote)';
}
