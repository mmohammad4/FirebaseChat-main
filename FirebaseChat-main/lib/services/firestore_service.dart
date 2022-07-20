import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/models/conversation.dart';
import 'package:create_social/models/message.dart';
import 'package:create_social/models/post.dart';
import 'package:create_social/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/cupertino.dart';

class FirestoreService {
  final fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;
  static Map<String, Users> userMap = {};
  static Map<String, Post> postMap = {};

  final Map<String, Conversation> _conversations = {};

  final usersCollection = FirebaseFirestore.instance.collection("users");
  final postsCollection = FirebaseFirestore.instance.collection("posts");
  static final chatsCollection = FirebaseFirestore.instance.collection("chats");
  final conversationCollection =
      FirebaseFirestore.instance.collection("conversations");
  final userConversationCollection =
      FirebaseFirestore.instance.collection("user_conversations");
  final messagesCollection = FirebaseFirestore.instance.collection("messages");

  final StreamController<Map<String, Users>> _usersController =
      StreamController<Map<String, Users>>();
  final StreamController<List<Post>> _postsController =
      StreamController<List<Post>>();
  final StreamController<List<Conversation>> _conversationsController =
      StreamController<List<Conversation>>();
  final StreamController<List<Conversation>> _userConversationsController =
      StreamController<List<Conversation>>();
  final StreamController<List<Message>> _messagesController =
      StreamController<List<Message>>();

  Stream<Map<String, Users>> get users => _usersController.stream;
  Stream<List<Post>> get posts => _postsController.stream;
  Stream<List<Conversation>> get userConvos =>
      _userConversationsController.stream;
  Stream<List<Message>> get messages => _messagesController.stream;

  FirestoreService() {
    usersCollection.snapshots().listen(_usersUpdated);
    postsCollection.snapshots().listen(_postsUpdated);
    messagesCollection.snapshots().listen(_messagesUpdated);
    conversationCollection.snapshots().listen(_conversationUpdated);
  }

  void setUserConvoserations(String userId) {
    userConversationCollection
        .doc(userId)
        .snapshots()
        .listen(_userConvosUpdated);
  }

  void _usersUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
    Map<String, Users> users = _getUserFromSnapshot(snapshot);
    _usersController.add(users);
  }

  void _postsUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Post> posts = _getPostsFromSnapshot(snapshot);
    _postsController.add(posts);
  }

  void _messagesUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Message> messages = []; // _getMessagesFromSnapshot(snapshot)
    _messagesController.add(messages);
  }

  void _conversationUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
    _getConversationsFromSnapshot(snapshot);
  }

  void _userConvosUpdated(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    List<Conversation> userConvo = _getUserConvosFromSnapshot(snapshot);
    _userConversationsController.add(userConvo);
  }

  Map<String, Users> _getUserFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (var doc in snapshot.docs) {
      Users user = Users.fromJson(doc.id, doc.data());
      userMap[user.id] = user;
    }

    return userMap;
  }

  List<Post> _getPostsFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Post> posts = [];
    for (var doc in snapshot.docs) {
      Post post = Post.fromJson(doc.id, doc.data());
      posts.add(post);
      postMap[post.id] = post;
    }
    return posts;
  }

  void _getConversationsFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (var doc in snapshot.docs) {
      Conversation convo = Conversation.fromJson(doc.id, doc.data());
      _conversations[convo.id] = convo;
    }
  }

  List<Conversation> _getUserConvosFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    List<Conversation> conversations = [];

    return conversations;
  }

  Future<bool> addUser(String userId, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addPost(Map<String, dynamic> data) async {
    data["createdAt"] = Timestamp.now();
    try {
      await postsCollection.add(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addConversation(List<String> users) async {
    users.add(_auth.currentUser!.uid);
    var data = {"users": users, "create_at": Timestamp.now()};
    try {
      var result = await conversationCollection.add(data);
      for (var user in users) {
        userConversationCollection
            .doc(user)
            .set({result.id: 1}, SetOptions(merge: true));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getChannelName(List<String> users) async{
    try{
      var channels = await chatsCollection
          .where("users.${users[0]}",isEqualTo: true)
          .where("users.${users[1]}",isEqualTo: true)
          .where("isGroup",isEqualTo: 0)
          .get();
      // debugPrint("CHANNEL: ${channels.toString()}");
      // debugPrint("CHANNEL: ${channels.docs.length}");
      if(channels.docs.isEmpty){
        String channelName = await createChannel(users);
        return channelName;
      }else{
        // debugPrint("CHANNEL: ${channels.docs.length}");
        return channels.docs[0]["channel"];
      }
    }catch(e){
      return "";
    }

  }

  static Future<String> createChannel(List<String> users) async {
    var createChannel = await chatsCollection.add({
      "isGroup": 0,
      "users" : {
        users[0] : true,
        users[1] : true,
      },
    });

    await chatsCollection.doc(createChannel.id).update({
      "channel": createChannel.id
    });
    return createChannel.id;
  }


}
