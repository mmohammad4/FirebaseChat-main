import 'package:create_social/models/users.dart';
import 'package:create_social/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CreateConversationsPage extends StatefulWidget {
  const CreateConversationsPage({Key? key}) : super(key: key);

  @override
  State<CreateConversationsPage> createState() => _CreateState();
}

class _CreateState extends State<CreateConversationsPage> {
  List<Users> userList = FirestoreService.userMap.values.toList();
  List<String> recipients = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Conversation"),
        actions: recipients.isEmpty
            ? []
            : [
                IconButton(
                    onPressed: createConvo, icon: const Icon(Icons.check))
              ],
      ),
      body: ListView.builder(
          itemCount: userList.length,
          itemBuilder: (BuildContext context, int index) {
            var added = recipients.contains(userList[index].id);
            return ListTile(
              title: Text(userList[index].name),
              trailing: added
                  ? const Icon(
                      Icons.verified,
                      color: Colors.green,
                    )
                  : null,
              onTap: () {
                setState(() {
                  if (added) {
                    recipients.remove(userList[index].id);
                  } else {
                    recipients.add(userList[index].id);
                  }
                });
              },
            );
          }),
    );
  }

  void createConvo() async {
    FirestoreService fs = FirestoreService();
    fs.addConversation(recipients);
  }
}
