import 'dart:convert';

SocketResultModel socketResultModelFromJson(String str) =>
    SocketResultModel.fromJson(json.decode(str));

String socketResultModelToJson(SocketResultModel data) =>
    json.encode(data.toJson());

class SocketResultModel {
  SocketResultModel({
    this.data,
    this.messageType,
  });

  String? data;
  String? messageType;

  factory SocketResultModel.fromJson(Map<String, dynamic> json) =>
      SocketResultModel(
        data: json["data"],
        messageType: json["messageType"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "messageType": messageType,
      };
}
