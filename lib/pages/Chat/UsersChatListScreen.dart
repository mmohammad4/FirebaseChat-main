import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/pages/Chat/UserListScreen.dart';
import 'package:create_social/pages/profile.dart';
import 'package:create_social/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../constant/utils.dart';
import '../../models/channel.dart';
import '../../models/users.dart';
import '../../style/style.dart';
import 'ChatScreen.dart';


class UsersChatListScreen extends StatefulWidget {
  const UsersChatListScreen({Key? key}) : super(key: key);

  @override
  State<UsersChatListScreen> createState() => _UsersChatListScreenState();
}

class _UsersChatListScreenState extends State<UsersChatListScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream;
  QuerySnapshot<Map<String, dynamic>>? snapshot;
  String? loginUserId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginUserId = firebaseAuth.currentUser?.uid;

    _userStream = FirebaseFirestore.instance
        .collection("chats")
        .where("users.$loginUserId", isEqualTo: true)
        .snapshots(includeMetadataChanges: true);

    determinePosition();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversations"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                      ProfilePage(id: FirebaseAuth.instance.currentUser!.uid
                      )
                  )
              );
            },
            icon: Image.asset(
              'images/account.png',
              height: 23,
              width: 23,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserListScreen(screenType: 1,)
                      )
                  );
                },
                icon: const Icon(Icons.group_add_rounded)),
          ),
          // IconButton(onPressed: () {
          //   Navigator.of(context).push(MaterialPageRoute(
          //       builder: (context) => const CreateConversationsPage()));
          // }, icon: const Icon(Icons.settings))
        ],
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserListScreen()
              )
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _userStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                    snapshots) {
                  if (snapshots.hasError) {
                    return Text(snapshots.error.toString());
                  } else if (snapshots.connectionState == ConnectionState.waiting) {
                    return const Loading();
                  }
                  else{
                    snapshot = snapshots.data;
                    // debugPrint("<<<<<<<<<<<<<<snapshots.data>>>>>>>>>>>>>>");
                    // debugPrint(snapshots.data!.size.toString());
                  }
                  return (snapshots.data != null)
                      ? snapshots.data!.docs.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          itemCount: snapshots.data!.docs.length,
                          itemBuilder: (context, index) {
                            // debugPrint(snapshots.data!.docs[index].data().toString());
                            Channel channel = Channel.fromJson(
                                snapshots.data!.docs[index].id,
                                snapshots.data!.docs[index].data());
                            return buildItem(channel, snapshots.data!);
                          },
                        )
                      : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 150),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/no_account.png',
                                height: 150,
                                width: 150,
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(8, 30, 8, 4),
                                child: Text(
                                  'Start Conversion',
                                  style: TextStyle( fontSize: 22),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.only(top:100),
                            child: const Text("Something went wrong"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  buildItem(Channel channel, QuerySnapshot<Map<String, dynamic>> snapshot) {
    return Material(
      child: InkWell(
        onTap: (){
          // debugPrint(channel.channel);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) =>  ChatScreen(
                channel: channel,
              ))
          );
        },
        child: Column(
          children: [
            if(channel.isGroup == 0)...[
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                  future: FirebaseFirestore.instance.collection("users").doc(channel.users.keys.toList()[0] == loginUserId
                      ? channel.users.keys.toList()[1]
                      : channel.users.keys.toList()[0]).get(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
                    if (snapshot.hasData) {
                      try{
                        Users user = Users.fromJson(
                            snapshot.data!.id,
                            snapshot.data!.data()!);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap:(){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProfilePage(id: user.id)
                                          )
                                      );
                                  },
                                  child: Container(
                                    width: 45.0,
                                    height: 45.0,
                                    alignment: Alignment.topCenter,
                                    decoration: const BoxDecoration(
                                        color: Colors.white, shape: BoxShape.circle),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child:Utils.loadCachedNetworkImage(user.profilePic,
                                            provider: 'images/no_photo.png')
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          ),
                        );
                      }catch(e){
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap:(){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProfilePage(id: channel.users.keys.toList()[0] == loginUserId
                                                  ? channel.users.keys.toList()[1]
                                                  : channel.users.keys.toList()[0])
                                          )
                                      );
                                  },
                                  child: Container(
                                    width: 45.0,
                                    height: 45.0,
                                    margin: const EdgeInsets.only(right: 20),
                                    alignment: Alignment.topCenter,
                                    decoration: const BoxDecoration(
                                        color: Colors.white, shape: BoxShape.circle),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child:Utils.loadCachedNetworkImage("",
                                            provider: 'images/no_photo.png')
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "loading ...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    ],
                                  ),
                                ),
                              ]
                          ),
                        );
                      }
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap:(){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfilePage(id: channel.users.keys.toList()[0] == loginUserId
                                                ? channel.users.keys.toList()[1]
                                                : channel.users.keys.toList()[0])
                                        )
                                    );
                                },
                                child: Container(
                                  width: 45.0,
                                  height: 45.0,
                                  margin: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.topCenter,
                                  decoration: const BoxDecoration(
                                      color: Colors.white, shape: BoxShape.circle),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child:Utils.loadCachedNetworkImage("",
                                          provider: channel.isGroup == 0
                                              ? 'images/no_photo.png'
                                              : 'images/no_group.png')
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "loading ...",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                  ],
                                ),
                              ),
                            ]
                        ),
                      );
                    }
                  }
              ),
            ]else...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 45.0,
                        height: 45.0,
                        margin: const EdgeInsets.only(right: 20),
                        alignment: Alignment.topCenter,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child:Utils.loadCachedNetworkImage("",
                                provider: 'images/no_group.png')
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              channel.groupName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                                "${channel.users.keys.length} members",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ]
                ),
              ),
            ],
            const Divider(
              color: Colors.black12,
              height: 1,
              thickness: 1,
            )
          ],
        ),
      ),
    );
  }

  //Todo: get user current location
  Future<Position> determinePosition() async {
    LocationPermission requestPermission = await Geolocator.requestPermission();
    if(requestPermission == LocationPermission.whileInUse || requestPermission == LocationPermission.whileInUse){
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      Position position = await Geolocator.getCurrentPosition();
      String address = await Utils.getAddress(position.latitude,position.longitude);

      FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseAuth.currentUser!.uid)
          .update({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "address": address
      }).then((value) {
      }).catchError((e) {
      });

      return position;
    }else{
      snackBar(context, "Please enable permission from the setting.");
      return Future.error('Please enable permission from the setting.');
    }
  }

}
