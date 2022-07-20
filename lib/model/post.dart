            // model class for post

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/model/user.dart';

class Post {
  final String id;
  final String content; // The typed message or the url of the image
  final String postFile; // The typed message or the url of the image
  final String postType; // The typed message or the url of the image
  final Timestamp createdAt; // Timestamp of message
  final String creator;

  Post(
      {required this.id,
      required this.content,
      required this.createdAt,
      required this.creator,
      required this.postFile,
      required this.postType});

  factory Post.fromJson(
      String id, Map<String, dynamic> data) {
    return Post(
        id: id,
        content: data["content"],
        createdAt: data["createdAt"],
        creator: data["creator"],
        postFile: data["postFile"]??"",
        postType: data["postType"] ?? '');
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "content": content,
      "createdAt": createdAt,
      "creator": creator,
      "postFile": postFile,
      "postType": postType
    };
  }
}
