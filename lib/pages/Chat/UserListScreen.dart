import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/models/channel.dart';
import 'package:create_social/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Constant/utils.dart';
import '../../constant/constants.dart';
import '../../models/SearchModel.dart';
import '../../models/users.dart';
import '../../services/firestore_service.dart';
import '../../style/style.dart';
import '../profile.dart';
import 'ChatScreen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key, this.screenType = 0}) : super(key: key);
  final int screenType;
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<Users> userList = [];
  List<Channel> groupList = [];
  List<SearchModel> filterList = [];
  String? loginUserId;
  bool isFirebaseCalled = false;
  List<String> selectedUserList = [];
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String searchText = "";
  int searchType = 0;
  late Widget appBarTitle;
  Icon icon = const Icon(
    Icons.search,
    color: Colors.white,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appBarTitle = Text(
      widget.screenType == 0?"Users":"Create Group",
      style: const TextStyle(color: Colors.white),
    );
    loginUserId = firebaseAuth.currentUser?.uid;
    filterList.clear();
    if(widget.screenType == 0){

      //Todo: get group list
      firebaseFirestore.collection("chats")
          .where("isGroup", isEqualTo: 1).get()
          .then((value){
        if(value.docs.isNotEmpty){
          setState(() {
            groupList = value.docs.map((e) => Channel.fromJson(e.id, e.data())).toList();
            filterList.addAll(groupList.map((e) => SearchModel(id: e.channel, title: e.groupName, desc: "${e.users.keys.length} members", profilePic: "", isGroup: 1)).toList());
          });
        }
      }).catchError((err) {
        debugPrint('Error111: $err');
      }).onError((error, stackTrace){
        debugPrint('Error112: $error');
      });
    }

    //Todo: get user list
    firebaseFirestore
        .collection("users")
        .where("id", isNotEqualTo: loginUserId)
        .get()
        .then((value){
          if(value.docs.isNotEmpty){
            setState(() {
              isFirebaseCalled = true;
              userList = value.docs.map((e) => Users.fromJson(e.id, e.data())).toList();
              filterList.addAll(userList.map((e) => SearchModel(id: e.id, title: e.name, desc: e.bio, profilePic: e.profilePic, isGroup: 0)).toList());
            });
          }else{
            setState(() {
              isFirebaseCalled = true;
            });
          }
        })
        .catchError((err) {
          debugPrint('Error1: $err'); // Prints 401.
            setState(() {
              isFirebaseCalled = true;
            });
          })
        .onError((error, stackTrace){
          debugPrint('Error2: $error'); // Prints 401.
          setState(() {
            isFirebaseCalled = true;
          });
        });



    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          // isSearching = false;
          // searchText = "";
        });
      } else {
        setState(() {
          isSearching = true;
          // searchText = searchController.text;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.screenType == 0)
          ? buildAppBar()
          : AppBar(
              title: Text(widget.screenType == 0?"Users":"Create Group"),
              backgroundColor: primaryColor,
            ),
      body: SafeArea(
        child: Column(
          children: [

            //Todo: for search user or group
            if(widget.screenType == 0 && isSearching)...[
              Padding(
                padding: const EdgeInsets.only(top: 15,left: 15),
                child: Row(
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          searchType = 0;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        decoration: BoxDecoration(
                          color: searchType == 0 ? primaryColor : Colors.grey,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),

                        child: const Text("Users",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 1.5),),

                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          searchType = 1;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 1, 8, 1),
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        decoration: BoxDecoration(
                          color: searchType == 1 ? primaryColor : Colors.grey,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),

                        child: const Text("Groups",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 1.5),),

                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          searchType = -1;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        decoration: BoxDecoration(
                          color: searchType == -1 ? primaryColor : Colors.grey,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: const Text("All",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 1.5),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: isFirebaseCalled
                  ? (filterList.isNotEmpty && loginUserId != null)
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: filterList.length,
                      itemBuilder: (context, index) {
                        if (loginUserId != filterList[index].id
                            && filterList[index].title.toLowerCase()
                                .contains(searchController.text.toString().toLowerCase())
                            && (filterList[index].isGroup == searchType || searchType == -1)) {
                          return buildItem(filterList[index]);

                        } else {
                          return Container();
                        }
                      },
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset(
                            'images/ic_no_photo.png',
                            height: 150,
                            width: 150,
                            color: Colors.grey,
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 20, 8, 4),
                            child: Text(
                              'No User Available',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Loading(),
            ),

            if(widget.screenType == 1)...[
              const Divider(
                height: 1,
                thickness: 1,
                color: primaryTransColor,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                color: primaryTransColor1,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: TextField(
                              controller: groupNameController,
                              decoration: const InputDecoration(
                                labelText: "Group Name",
                                hintText: "Group Name",
                                counterText: '',),
                              cursorColor: primaryColor,
                              maxLength: 30,
                            ),
                          ),
                        ),
                        TextButton(
                          child: const Text("Add Group",
                              style: TextStyle(
                                  color: primaryColor
                              )
                          ),
                          onPressed: () async {
                            if(groupNameController.text.trim().isEmpty){
                              snackBar(context, "Please enter group name.");
                              return;
                            }
                            if(selectedUserList.isEmpty){
                              snackBar(context, "Please select the users.");
                              return;
                            }
                            if(loginUserId != null){
                              Map<String,dynamic> data = {};
                              selectedUserList.add(loginUserId!);
                              for (var element in selectedUserList) {
                                data[element] = true;
                              }
                              // debugPrint(data.toString());
                              try{
                                Utils.showLoader();
                                var createChannel = await firebaseFirestore
                                    .collection('chats')
                                    .add({
                                  'isGroup': 1,
                                  'groupName': groupNameController.text.trim(),
                                  'users' : data,
                                });
                                await firebaseFirestore.collection('chats').doc(createChannel.id).update({
                                  "channel": createChannel.id
                                });
                                Utils.hideLoader();
                                Channel channel = Channel(channel: createChannel.id, isGroup: 1, groupName: groupNameController.text.trim(), users: data);
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder:(_) => ChatScreen(
                                      channel: channel,
                                    ))
                                );
                              }catch(e){
                                Utils.hideLoader();
                                snackBar(context, "Something went to wrong");
                              }
                            }else{
                              snackBar(context, "Something went to wrong");
                            }



                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  buildItem(SearchModel user) {
    return Material(
      color: selectedUserList.contains(user.id)?primaryTransColor:Colors.transparent,
      child: InkWell(
        onTap: () async {
          if(widget.screenType == 0){
            if(user.isGroup == 0){
              Utils.showLoader();
              String? channelI = await FirestoreService.getChannelName([loginUserId.toString(),user.id.toString()]);

              Utils.hideLoader();
              if(channelI != null && loginUserId != null){
                Channel channel = Channel(channel: channelI, isGroup: 0, groupName: "", users: {
                  user.id : true,
                  loginUserId.toString() : true,
                });

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder:(_) => ChatScreen(
                      channel: channel,
                    ))
                );
              }else{
                Navigator.of(context).pop();
              }
            }
            else{
              List<Channel> groups = groupList.where((element) => element.channel == user.id).toList();
              if(groups.isNotEmpty){
                Channel channel = groups[0];
                if(channel.users.keys.toList().contains(loginUserId)){
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder:(_) => ChatScreen(
                        channel: channel,
                      ))
                  );
                }
                else{
                  Utils.showTwoButtonAlertDialog(
                      context: context,
                      alertTitle: 'Are you sure?',
                      alertMsg: 'You want to add this group?',
                      positiveText: 'Yes',
                      negativeText: 'No',
                      yesTap: () async {
                        Utils.showLoader();
                        firebaseFirestore
                            .collection("chats")
                            .doc(channel.channel)
                            .update({
                          "users.$loginUserId": true
                        }).then((value) {
                          Utils.hideLoader();
                          if(groups.isNotEmpty){
                            channel.users[loginUserId!] = true;
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder:(_) => ChatScreen(
                                  channel: channel,
                                ))
                            );
                          }
                        }).catchError((e) {
                          Utils.hideLoader();

                        });
                      }
                  );

                }

              }

            }

          }else if (widget.screenType == 1){
            if(selectedUserList.contains(user.id)){
              setState(() {
                selectedUserList.remove(user.id);
              });
            }else{
              if(selectedUserList.length >= Constants.maxUserInGroup){
                snackBar(context, "You can add max. 15 user in Group.");
              }else{
                setState(() {
                  selectedUserList.add(user.id);
                });
              }
            }
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap:(){
                        if(user.isGroup == 0){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage(id: user.id)
                              )
                          );
                        }
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
                                provider: user.isGroup == 0
                                    ? 'images/no_photo.png'
                                    : 'images/no_group.png')
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedUserList.contains(user.id)?Colors.white:Colors.black
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2,),
                          Text(
                            user.desc.isNotEmpty ? user.desc : "-",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                                color: selectedUserList.contains(user.id)?Colors.white:Colors.grey
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
            Divider(
              color: selectedUserList.contains(user.id)? Colors.white : Colors.black12,
              height: 1,
              thickness: 1,
            )
          ],
        ),
      ),
    );
  }


  //Todo: search bar
  AppBar buildAppBar() {
    return AppBar(
        title: appBarTitle,
        backgroundColor: primaryColor,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: icon,
              onPressed: () {
                setState(() {
                  if (icon.icon == Icons.search) {
                    icon = const Icon(
                      Icons.close,
                      color: Colors.white,
                    );
                    appBarTitle = TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          hintText: "Search...",
                          hintStyle: TextStyle(color: Colors.white)),
                      onChanged: searchOperation,
                    );
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                });
              },
            ),
          ),
        ]);
  }
  void _handleSearchStart() {
    setState(() {
      isSearching = true;
      searchType = 0;
    });
  }
  void _handleSearchEnd() {
    setState(() {
      icon = const Icon(
        Icons.search,
        color: Colors.white,
      );
      appBarTitle = Text(
        widget.screenType == 0? "Users": "Create Group",
        style: const TextStyle(color: Colors.white),
      );
      isSearching = false;
      searchType = 0;
      searchController.clear();
      searchOperation("");
    });
  }
  void searchOperation(String searchText) {
    setState(() {
      // filterList.addAll(list.where((element) => element.name.contains(searchText)));

      // if(searchType == 0){
      //   filterList.clear();
      //   // filterList.addAll(list.where((element) => element.name.contains(searchText)));
      //   // filterList = list.map((e) => SearchModel(id: e.id, title: e.name, desc: e.bio, isGroup: 0)).toList().where((element) => false);
      //
      // }else if (searchType == -1){
      //   firebaseFirestore
      //       .collection("chats")
      //       .where("isGroup", isEqualTo: 1)
      //       .get();
      //   // filterList.addAll(list.where((element) => element.name.contains(searchText) && element.));
      // }
    });
  }
}
