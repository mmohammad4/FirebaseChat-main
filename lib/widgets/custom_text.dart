import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String userId;
  const CustomText({Key? key, required this.userId}) : super(key: key);
  @override
  Widget build(context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
          if (snapshot.hasData) {
            try{
              return Text(snapshot.data!.data()!['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,);
            }catch(e){
              return const Text("",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,);
            }
          } else {
            return const Text("",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,);
          }
        }
    );
  }
}