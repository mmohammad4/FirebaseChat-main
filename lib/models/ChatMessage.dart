import 'dart:convert';

ChatMessage chatMessageFromJson(String str) => ChatMessage.fromJson(json.decode(str));

String chatMessageToJson(ChatMessage data) => json.encode(data.toJson());

class ChatMessage {
  ChatMessage({
    required this.userId,
    required this.msg,
    required this.fileName,
    required this.createdAt,
    required this.msgType,
  });

  final String userId;
  final String msg;
  final String fileName;
  final DateTime createdAt;
  final int msgType;

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) => ChatMessage(
    userId: json["userId"],
    msg: json["msg"],
    fileName: json["fileName"],
    createdAt: DateTime.parse(json["createdAt"]),
    msgType: json["msgType"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "msg": msg,
    "fileName": fileName,
    "createdAt": createdAt.toString(),
    "msgType": msgType,
  };
}
