import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:create_social/pages/authentication.dart';
import 'package:create_social/models/users.dart';
import 'package:create_social/style/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

import '../Constant/utils.dart';
import '../widgets/CustomHeader.dart';
import '../widgets/loading.dart';
import 'package:path_provider/path_provider.dart' as path_provider;



class ProfilePage extends StatefulWidget {
  final String id;
  const ProfilePage({Key? key, required this.id}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Users? user;
  bool isLoginUserProfile = false;
  double rating = -1;
  @override
  void initState() {
    super.initState();
    isLoginUserProfile = widget.id == firebaseAuth.currentUser!.uid ? true : false;

    firebaseFirestore.collection("users").doc(widget.id).get().then((value){
      if( value.data() != null){
        setState(() {
          user = Users.fromJson(value.id, value.data()!);
        });
      }
    });

    firebaseFirestore
        .collection("chats")
        .where("users.${widget.id}", isEqualTo: true)
        .get()
        .then((value){
      if(value.docs.isNotEmpty){
        setState(() {
          rating = value.docs.length.toDouble();
        });
      }else{
        setState(() {
          rating = 0;
        });
      }
    }).catchError((err) {
      debugPrint('Error1: $err'); // Prints 401.
    }).onError((error, stackTrace){
    });
    if(isLoginUserProfile){
      determinePosition();
    }
  }

  //UI for profile screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: user == null
            ? const Loading()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.4,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.4,
                            width: double.maxFinite,
                            child: Utils.loadCachedNetworkImage(user!.profilePic,
                                provider: 'images/no_account.png'),
                          ),
                          CustomHeader(
                            leftChild: IconButton(
                              color: Colors.black,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.asset('images/back.png',
                                color: Colors.black,
                              ),
                            ),
                            middleChild: Container(),
                            rightChild: isLoginUserProfile ? IconButton(
                                onPressed: () async {                   // sign out function
                                  Utils.showTwoButtonAlertDialog(
                                      context: context,
                                      alertTitle: 'Sign Out',
                                      alertMsg: 'Are you sure to Sign out?',
                                      positiveText: 'OK',
                                      negativeText: 'Cancel',
                                      yesTap: () async {
                                        Utils.showLoader();
                                        await FirebaseAuth.instance.signOut().then((value) {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context)=> const Authentication()),
                                                  (route) => false);
                                        });
                                        Utils.hideLoader();
                                      }
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout_outlined,
                                  color: Colors.black,
                                  size: 40,
                                )
                            ): const SizedBox(width: 30,),
                          ),
                          if(isLoginUserProfile)...[
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(bottom: 5,right: 5),
                                child: TextButton.icon(
                                  onPressed: () {
                                    pickImage();
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: primaryColor
                                          .withOpacity(0.5)),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Edit  ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 30,),
                    const Padding(
                      padding:  EdgeInsets.only(left: 15.0),
                      child: Text(
                        "Basic Info",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        user!.name,
                        style:const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                      subtitle:  Text(
                        user!.bio,
                        style:const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),

                    if(user!.address.isNotEmpty)...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        child: Text("Address",
                          style:TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900
                          ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(user!.address,
                          style:const TextStyle(
                              fontSize: 16,
                          ),),
                      ),
                      const SizedBox(height: 20,),
                    ],
                    if(rating != -1)...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        child: Text("Rank",
                          style:TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900
                          ),),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: RatingBar.builder(
                            initialRating: rating >5 ? 5 : rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star_rate_rounded,
                              color: primaryColor,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15,),
                    ],
                  ],
          ),
        ),
      ),
    );
  }
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
          // debugPrint("<<<uploadedPath>>>");
          // debugPrint(uploadedPath);
          if(isLoginUserProfile && uploadedPath.isNotEmpty){
            firebaseFirestore
                .collection("users")
                .doc(firebaseAuth.currentUser!.uid)
                .update({"profilePic": uploadedPath}).then((value) {
              Utils.hideLoader();
              setState(() {
                user!.profilePic = uploadedPath;
              });
              snackBar(context, "Profile Picture updated successfully.");
            }).catchError((e) {
              Utils.hideLoader();
              snackBar(context, "Something went to wrong.");
            });
          }else{
            Utils.hideLoader();

            snackBar(context, "Something went to wrong.");
          }
        }
      }catch(e){
        Utils.hideLoader();
        snackBar(context, "Something went to wrong.");
      }

    }
  }
  // upload image to firebase and return image URL
  Future<String> uploadImage(String imagePath) async {
    bool conn = await Utils.checkInternetConnection();
    if(conn){
      String uploadPath = "/users/${firebaseAuth.currentUser!.uid}";
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

  Future<Position> determinePosition() async {
    LocationPermission requestPermission = await Geolocator.requestPermission();
    if(requestPermission == LocationPermission.whileInUse || requestPermission == LocationPermission.whileInUse){
      // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // if (!serviceEnabled) {
      //   return Future.error('Location services are disabled.');
      // }

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

      /*debugPrint("<<<<<<<<<position>>>>>>>>>");
      debugPrint(position.latitude.toString());
      debugPrint(position.longitude.toString());
      debugPrint(position.toJson().toString());
      debugPrint("<<<<<<<<<position>>>>>>>>>");

      debugPrint(address);*/

      firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser!.uid)
          .update({
            "latitude": position.latitude,
            "longitude": position.longitude,
            "address": address
          }).then((value) {
            setState(() {
              user!.latitude = position.latitude;
              user!.longitude = position.longitude;
              user!.address = address;
            });
          }).catchError((e) {
          });

      return position;
    }else{
      snackBar(context, "Please enable permission from the setting.");
      return Future.error('Please enable permission from the setting.');
    }

    // return await Geolocator.getCurrentPosition();
  }
}

