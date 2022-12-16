// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

SocketResultModel socketResultModelFromJson(String str) =>
    SocketResultModel.fromJson(json.decode(str));

String socketResultModelToJson(SocketResultModel data) =>
    json.encode(data.toJson());

class SocketResultModel {
  String? data;
  String? messageType;

  SocketResultModel({
    this.data,
    this.messageType,
  });

  factory SocketResultModel.fromJson(Map<String, dynamic> json) =>
      SocketResultModel(
        data: json["data"],
        messageType: json["messageType"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "messageType": messageType,
      };

  @override
  String toString() => 'SocketResultModel(data: $data, messageType: $messageType)';

  @override
  bool operator ==(covariant SocketResultModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.data == data &&
      other.messageType == messageType;
  }

  @override
  int get hashCode => data.hashCode ^ messageType.hashCode;
}
