import 'dart:async';
import 'dart:io';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/models/channel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import '../../Constant/utils.dart';
import '../../models/ChatMessage.dart';
import '../../models/users.dart';
import '../../style/style.dart';
import '../../widgets/DefaultPlayer.dart';
import '../../widgets/ImageViewPager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ChatScreen extends StatefulWidget {
  final Channel channel;

  const ChatScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? replyTo;
  TextEditingController chatController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  late ScrollController scrollController = ScrollController();

  String? loginUserId;
  String? channelName;
  late FocusNode inputNode;

  double fileHeightRatio = 3.4;
  double fileWidthRation = 2;
  Users? user;
  List<Users> userList = [];
  List<ChatMessage> list = [];
  List<String> stickerList = [
    "images/creativity.png",
    "images/creativity_1.png",
    "images/fox.png",
    "images/ideas.png",
    "images/light_bulb.png",
    "images/woman.png",
    "images/note_book.png",
    "images/rainbow.png",
    "images/angry_face.png",
  ];

  @override
  void initState() {
    inputNode = FocusNode();
    loginUserId = firebaseAuth.currentUser?.uid;

    if(loginUserId != null){
      channelName = widget.channel.channel;

      //Todo: get users details
      if(widget.channel.isGroup == 0){
        FirebaseFirestore.instance
            .collection("users")
            .doc(widget.channel.users.keys.toList()[0] == loginUserId
            ? widget.channel.users.keys.toList()[1]
            : widget.channel.users.keys.toList()[0])
            .get().then((value){
          if(value.exists){
            setState(() {
              userList.clear();
              userList.add(Users.fromJson(value.id, value.data()!));
            });
          }
        });
      }
      if(widget.channel.isGroup == 1){
        if(widget.channel.users.keys.toList().length < 10){
          FirebaseFirestore.instance
              .collection("users")
              .where("id", whereIn: widget.channel.users.keys.toList())
              .get().then((value){

            if(value.docs.isNotEmpty){
              setState(() {

                userList.clear();
                userList.addAll(value.docs.map((e) => Users.fromJson(e.id, e.data())));
              });
            }
          });
        }
        else{
          userList.clear();
          FirebaseFirestore.instance
              .collection("users")
              .where("id", whereIn: widget.channel.users.keys.toList().sublist(0,9))
              .get().then((value){
            if(value.docs.isNotEmpty){
              userList.addAll(value.docs.map((e) => Users.fromJson(e.id, e.data())));
            }
          });

          FirebaseFirestore.instance
              .collection("users")
              .where("id", whereIn: widget.channel.users.keys.toList().sublist(10))
              .get().then((value){
            if(value.docs.isNotEmpty){
              userList.addAll(value.docs.map((e) => Users.fromJson(e.id, e.data())));
            }
          });
        }
      }

      //Todo: Listener for chat
      FirebaseList(
          query: firebaseDatabase.ref("channels/${channelName!}").orderByKey(),
          onError: (error){

          },
          onChildAdded: (index, snapshot){
            // print("$index ${snapshot.key}  ${snapshot.value}");
            final json = snapshot.value as Map<dynamic, dynamic>;
            final message = ChatMessage.fromJson(json);
            setState(() {
              list.insert(0,message);
            });
          }
      );
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.channel.isGroup == 0
            ? userList.isNotEmpty ? userList[0].name : ""
            : widget.channel.groupName),
        backgroundColor: primaryColor,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Expanded(
            //   child: channelName!= null
            //       ? Align(
            //           alignment: Alignment.bottomCenter,
            //           child: FirebaseAnimatedList(
            //               shrinkWrap: true,
            //               reverse: true,
            //               controller: scrollController,
            //               query: firebaseDatabase.ref("channels/${channelName!}")/*.orderByKey()*//*.orderByChild("createdAt")*/,
            //               sort: (DataSnapshot a, DataSnapshot b){
            //                 // return 0;
            //                 return b.key.toString().compareTo(a.key.toString());
            //
            //
            //                 // try{
            //                 //   if(a.key != null && b.key != null) {
            //                 //     return b.key.toString().compareTo(a.key.toString());
            //                 //   } else {
            //                 //     return 0;
            //                 //   }
            //                 // }catch(e){
            //                 //   return 0;
            //                 // }
            //               },
            //               physics: const BouncingScrollPhysics(),
            //               padding: const EdgeInsets.only(top: 15),
            //               defaultChild: const Loading(),
            //               itemBuilder: (BuildContext context, DataSnapshot snapshot,
            //                   Animation<double> animation,int index) {
            //                 final json = snapshot.value as Map<dynamic, dynamic>;
            //                 final message = ChatMessage.fromJson(json);
            //                 return Material(
            //                   color: Colors.white,
            //                   child: buildItem(message),
            //                 );
            //               }
            //           ),
            //         )
            //       : Container(),
            // ),

            Expanded(
              child: channelName!= null
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          controller: scrollController,
                          itemCount: list.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 15),
                          itemBuilder: (BuildContext context, int index) {
                            return Material(
                              color: Colors.white,
                              child: buildItem(list[index]),
                            );
                          }
                      ),
                    )
                  : Container(),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.maxFinite,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 0.5,
                      color: Colors.grey,
                    ),
                    Container(
                      height: 55,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () async {
                                bottomSheetOfStickers(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Image.asset(
                                  "images/ic_sticker.png",
                                  height: 30,
                                  width: 30,
                                  color: primaryColor,
                                ),
                              )
                          ),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xffe7e7e7)
                              ),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: chatController,
                                minLines: 1,
                                maxLines: 100,
                                focusNode: inputNode,

                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                    hintText:'Send Message',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              if(loginUserId != null && channelName != null){
                                                showBottomSheetForVideoSelectionType(context);
                                              }
                                            },
                                            child: Icon(
                                              Icons.videocam_rounded,
                                              color: Colors.grey[800],
                                              size: 27,
                                            ),
                                          ),
                                          const SizedBox(width: 15,),
                                          InkWell(
                                            onTap: (){
                                              if(loginUserId != null && channelName != null){
                                                pickImage();
                                              }
                                            },
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey[800],
                                              size: 27,
                                            ),
                                          ),
                                          const SizedBox(width: 7,),

                                        ],
                                      ),
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7,),

                          InkWell(
                            onTap: () async {
                              if(chatController.text.trim().isEmpty){
                                return;
                              }
                              if(loginUserId != null && channelName != null){
                                ChatMessage chatMessage = ChatMessage(
                                    userId: loginUserId!,
                                    msg: chatController.text.toString().trim(),
                                    fileName: "",
                                    createdAt: DateTime.now(),
                                    msgType: 0);

                                await firebaseDatabase.ref("channels/${channelName!}").push().setWithPriority(chatMessage.toJson(),"new");
                                chatController.clear();
                                scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.linearToEaseOut);
                              }

                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.send_rounded,
                                size: 35,
                                color: primaryColor,
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Show the soft keyboard.
  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  /// Hide the soft keyboard.
  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Widget buildItem(ChatMessage? messageChat) {
    if (messageChat != null && loginUserId != null) {
      FileTypes fileType = messageChat.fileName.isEmpty
          ? FileTypes.text
          : Utils.getFileType(messageChat.msg);
      bool isLoginUser = (messageChat.userId == loginUserId)? true : false;
      int sender = ((widget.channel.isGroup == 1 && !isLoginUser)
          ? userList.indexWhere((element) => element.id == messageChat.userId)
          : -1);
        return Row(
          mainAxisAlignment: isLoginUser?MainAxisAlignment.end:MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: isLoginUser?CrossAxisAlignment.end:CrossAxisAlignment.start,
              children: [
                Container(
                    padding: (fileType == FileTypes.text)
                        ? const EdgeInsets.fromLTRB(5, 3, 5, 3)
                        : null,
                    decoration: BoxDecoration(
                        color: isLoginUser? const Color(0xffb4b4b4) : primaryColor,
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 3, right: 10,left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //Todo: check received msg is text or not
                        if(fileType == FileTypes.text)...[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(widget.channel.isGroup == 1 && !isLoginUser && sender != -1)...[
                                  Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 7,top: 7),
                                      child: Text(
                                        userList[sender].name,
                                        style: TextStyle(color: Utils.getColor(sender),fontWeight: FontWeight.bold, fontSize: 14),
                                      )
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 8),
                                  child: Text(
                                    messageChat.msg,
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(width: 2,),
                        ]else...[
                          InkWell(
                            onTap: (){
                              hideKeyboard();
                              if(fileType == FileTypes.image) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ImageViewPager(imageList:[messageChat.msg])
                                    )
                                );
                              }
                              else{
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DefaultPlayer(
                                            url: messageChat.msg,
                                        )
                                    )
                                );
                              }
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(widget.channel.isGroup == 1 && !isLoginUser && sender != -1)...[
                                        Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 7,top: 7,bottom: 7),
                                            child: Text(
                                              userList[sender].name,
                                              style: TextStyle(color: Utils.getColor(sender),fontWeight: FontWeight.bold, fontSize: 14),
                                            )
                                        ),
                                      ],
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                            height: MediaQuery.of(context).size.height/fileHeightRatio,
                                            width: MediaQuery.of(context).size.width / fileWidthRation,
                                            child: Stack(
                                              children: [
                                                if(fileType == FileTypes.image)...[
                                                  Container(
                                                      height: MediaQuery.of(context).size.height / fileHeightRatio,
                                                      width: MediaQuery.of(context).size.width/fileWidthRation,
                                                      color: Colors.black12,
                                                      child: Utils.loadCachedNetworkImage(messageChat.msg,
                                                        provider: 'images/no_images.png',height: 100,width: 100 )),
                                                ]else...[
                                                  CachedVideoPreviewWidget(
                                                    path: messageChat.msg,
                                                    type: SourceType.local,
                                                    placeHolder: Image.asset('images/no_images.png', fit: BoxFit.cover, height: MediaQuery.of(context).size.height/fileHeightRatio,
                                                      width: MediaQuery.of(context).size.width/fileWidthRation,),
                                                    remoteImageBuilder: (BuildContext context, url) {
                                                      return Image.network(url, fit: BoxFit.cover, height: MediaQuery.of(context).size.height/fileHeightRatio,
                                                        width: MediaQuery.of(context).size.width/fileWidthRation,);
                                                    },
                                                    fileImageBuilder: (BuildContext context, url) {
                                                      return Image.memory(url, fit: BoxFit.cover, height: MediaQuery.of(context).size.height/fileHeightRatio,
                                                        width: MediaQuery.of(context).size.width/fileWidthRation,);
                                                    }
                                                  ),
                                                  const Align(
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 60,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left:10, right: 10,bottom: 10),
                    child: Text(
                      Utils.convertToAgo(messageChat.createdAt),
                      style: const TextStyle(color: Colors.grey,fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

    } else {
      return const SizedBox.shrink();
    }
  }

  //Todo: pick Image from camera or gallery
  pickImage() async {
      List<Asset> images = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        selectedAssets: [],
        cupertinoOptions: const CupertinoOptions(takePhotoIcon: "Chat"),
        materialOptions: const MaterialOptions(
          actionBarColor: "#14444A",
          actionBarTitle: "Select",
          allViewTitle: "All Photos",
          useDetailsView: true,
          selectCircleStrokeColor: "#14444A",
        ),
      );

      if (images.isNotEmpty) {
        try{
          ByteData data = await images[0].getByteData();
          final buffer = data.buffer;
          final dir = await path_provider.getTemporaryDirectory();
          final targetPath = "${dir.absolute.path}/temp${Utils.generateRandomString1(6)}.jpg";
          File file = await File(targetPath).writeAsBytes(
              buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          // debugPrint(file.path);

          bool conn = await Utils.checkInternetConnection();
          if(conn){
            Utils.showLoader();
            String uploadedPath = await uploadImage(file.path);

            if(loginUserId != null && channelName != null && uploadedPath.isNotEmpty){
              ChatMessage chatMessage = ChatMessage(
                  userId: loginUserId!,
                  msg: uploadedPath,
                  fileName: Utils.getFileName(images[0].name!),
                  createdAt: DateTime.now(),
                  msgType: 1);

              await firebaseDatabase.ref("channels/${channelName!}").push().set(chatMessage.toJson());
              scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.linearToEaseOut);

            }else{
              snackBar(context, "Something went to wrong.");
            }
            Utils.hideLoader();
          }
        }catch(e){
          Utils.hideLoader();
          snackBar(context, "Something went to wrong.");
        }

      }
    }

  //Todo: pick Video from gallery
  pickVideo() async {
    dynamic videoFile;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mpeg',
        'mp4',
        'webm',
        'mkv',
        'wmv',
        'mov',
        'avi',
        'flv'
      ],
    );

    if (result != null) {
      // debugPrint(result.files.first.path);
      videoFile = result.files.first.path;
      if (videoFile != null) {
        bool conn = await Utils.checkInternetConnection();
        if(conn){
          Utils.showLoader();
          String uploadedPath = await uploadImage(videoFile);

          if(loginUserId != null && channelName != null && uploadedPath.isNotEmpty){
            ChatMessage chatMessage = ChatMessage(
                userId: loginUserId!,
                msg: uploadedPath,
                fileName: Utils.getFileName(videoFile),
                createdAt: DateTime.now(),
                msgType: 1);

            await firebaseDatabase.ref("channels/${channelName!}").push().set(chatMessage.toJson());
            scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.linearToEaseOut);
          }else{
            snackBar(context, "Something went to wrong.");
          }
          Utils.hideLoader();
        }
      }
    }
  }

  //Todo: pick Video from camera
  pickVideoFromCamera() async {
    dynamic videoFile;
    XFile? video = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (video != null) {
      // int size = File(video.path).lengthSync();
      videoFile = video.path;
      bool conn = await Utils.checkInternetConnection();
      if(conn){
        Utils.showLoader();
        String uploadedPath = await uploadImage(videoFile);

        if(loginUserId != null && channelName != null && uploadedPath.isNotEmpty){
          ChatMessage chatMessage = ChatMessage(
              userId: loginUserId!,
              msg: uploadedPath,
              fileName: Utils.getFileName(videoFile),
              createdAt: DateTime.now(),
              msgType: 1);

          await firebaseDatabase.ref("channels/${channelName!}").push().set(chatMessage.toJson());
          scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.linearToEaseOut);

        }else{
          snackBar(context, "Something went to wrong.");
        }
        Utils.hideLoader();
      }

    } else {
      videoFile = null;
    }
  }

  //Todo: upload image to firebase and return image URL
  Future<String> uploadImage(String imagePath) async {
    bool conn = await Utils.checkInternetConnection();
    if(conn){
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString(); //timestamp for post
      String uploadPath = "/chats/$timeStamp";
      uploadPath += Utils.getFileExtension(imagePath);
      // debugPrint(uploadPath);

      TaskSnapshot taskSnapshot = await firebaseStorage.ref(uploadPath).putFile(File(imagePath));

      if (taskSnapshot.state == TaskState.success) {
        return await taskSnapshot.ref.getDownloadURL();
      } else {
        return '';
      }
    }else{
      snackBar(context,'Check Internet Connection');
      return '';
    }

  }

  //Todo: Video type picker bottom sheet
  showBottomSheetForVideoSelectionType(context) async {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.only(top: 5, right: 15, left: 15, bottom: 10),
            height: 200,
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: const Text(
                    'Please select',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: const Text(
                      'Capture Video',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickVideoFromCamera();
                  },
                ),
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: const Text(
                      'Pick Video',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickVideo();
                  },
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          );
        });
  }

  //Todo: Sticker picker bottom sheet
  bottomSheetOfStickers(ctx) async {
    showModalBottomSheet(
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.only(top: 35, left: 20, right: 20),
            height: MediaQuery.of(context).size.height * 0.6,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    // maxCrossAxisExtent: MediaQuery.of(context).size.height/2,
                    childAspectRatio: 1 / 1.1,
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 7),
                itemCount: stickerList.length ,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  return Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            try{
                              final byteData = await rootBundle.load(stickerList[index]);

                              final file = await File('${(await path_provider.getApplicationDocumentsDirectory()).path}/${stickerList[index]}')
                                  .create(recursive: true);
                              await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

                              bool conn = await Utils.checkInternetConnection();
                              if(conn){
                                Utils.showLoader();
                                String uploadedPath = await uploadImage(file.path);

                                if(loginUserId != null && channelName != null && uploadedPath.isNotEmpty){
                                  ChatMessage chatMessage = ChatMessage(
                                      userId: loginUserId!,
                                      msg: uploadedPath,
                                      fileName: "sticker.png",
                                      createdAt: DateTime.now(),
                                      msgType: 1);

                                  await firebaseDatabase.ref("channels/${channelName!}").push().set(chatMessage.toJson());
                                  scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.linearToEaseOut);
                                }else{
                                  snackBar(context, "Something went to wrong.");
                                }
                                Utils.hideLoader();
                              }
                            }catch(e){
                              Utils.hideLoader();
                              snackBar(context, "Something went to wrong.");
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.asset(stickerList[index],fit: BoxFit.contain,),
                          ),
                        ),
                      ),
                    );
                }),
          );
        });
  }
}
