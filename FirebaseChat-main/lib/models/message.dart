import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content; // The typed message or the url of the image
  final int
      type; // The type of message this is 0:Post 1:UploadedImage 2:Sticker
  final Timestamp createdAt; // Timestamp of message
  final String fromId; // User id of the creator

  Message(
      {required this.id,
      required this.content,
      required this.type,
      required this.createdAt,
      required this.fromId});

  factory Message.fromJson(String id, Map<String, dynamic> data) {
    return Message(
        id: id,
        content: data["content"],
        type: data["type"] ?? 0,
        createdAt: data["createdAt"],
        fromId: data["fromId"]);
  }

  Map<String, dynamic> toJSON() {
    return {
      "content": content,
      "type": type,
      "createdAt": createdAt,
      "fromId": fromId
    };
  }
}
