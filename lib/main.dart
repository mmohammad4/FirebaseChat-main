
import 'package:create_social/pages/home.dart';
import 'package:create_social/style/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';

import 'pages/authentication.dart';
late FirebaseAuth firebaseAuth;

Future<void> main() async {
  //Always needed for firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(/*
      name: 'Firebase Chat',
      options: DefaultFirebaseOptions.currentPlatform*/);
  // FirestoreService _ = FirestoreService();
  firebaseAuth = FirebaseAuth.instance;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SocialApp());
  configLoading();
}
void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 35.0
    ..radius = 10.0
    ..progressColor = primaryColor
    ..backgroundColor = Colors.white
    ..lineWidth = 3
    ..indicatorColor = primaryColor
    ..textColor = primaryColor
    ..maskType = EasyLoadingMaskType.black
    ..textPadding = const EdgeInsets.fromLTRB(0, 0, 0, 12)
    ..contentPadding = const EdgeInsets.all(40)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class SocialApp extends StatelessWidget {
  const SocialApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SocialApp',
        debugShowCheckedModeBanner: false,
        home: firebaseAuth.currentUser == null ? (const Authentication()):(const HomePage()),
      builder: EasyLoading.init(),);
  }
}
