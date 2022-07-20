import 'package:create_social/models/post.dart';
import 'package:create_social/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _fs = FirestoreService();
  final TextEditingController _content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: _content,
            minLines: 5,
            maxLines: 5,
          ),
          OutlinedButton(
              onPressed: _submitPost, child: const Text("Submit Post"))
        ],
      ),
    );
  }

  void _submitPost() {
    _fs.addPost({
      "content": _content.text,
      "creator": _auth.currentUser!.uid
    }).then((value) => Navigator.of(context).pop());
  }
}
