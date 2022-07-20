import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/model/user.dart';
import 'package:create_social/pages/authentication.dart';
import 'package:create_social/style/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constant/AuthExceptionHandler.dart';
import '../constant/utils.dart';
import '../pages/Chat/UsersChatListScreen.dart';
import '../pages/home.dart';
import '../widgets/CustomHeader.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _bio = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      'images/back.png',
                      color: primaryColor,
                    )),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage(
                              'images/app_logo1.png',
                            ),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const CustomHeader(
                            middleChild: Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 30,
                                  letterSpacing: 1.5),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: _email,
                            decoration: inputStyling("Email"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email cannot be empty";
                              }
                              if (!value.contains('@')) {
                                return "Email in wrong format";
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _password,
                            decoration: inputStyling("Password"),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password cannot be empty";
                              }
                              if (value.length < 7) {
                                return "Password too short.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _username,
                            decoration: inputStyling("Username"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Username cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _bio,
                            decoration: inputStyling("Biography"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Biography cannot be empty";
                              }
                              if (value.length < 7) {
                                return "Biography too short.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 65,
                          ),
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                  register(context);
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "REGISTER",
                                  style: TextStyle(color: primaryColor,letterSpacing: 2, fontSize: 20),
                                ),
                              )),

                          Padding(
                            padding: const EdgeInsets.only(top: 40, bottom: 40),
                            child: Row(
                              children: const [
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                  ),
                                )
                              ],
                            ),
                          ),
                          buildSocialBtn(() {
                            signInWithGoogle();
                          },
                              const AssetImage(
                                'images/ic_google.png',
                              ),
                              Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // register to firebase
  Future<void> register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      AuthStatus? status;
      try {
        Utils.showLoader();
        UserCredential registerResponse =
            await _auth.createUserWithEmailAndPassword(
                email: _email.text, password: _password.text);

        _db
            .collection("users")
            .doc(registerResponse.user!.uid)
            .set({
          "name": _username.text,
          "bio": _bio.text,
          "latitude": 0,
          "longitude": 0,
          "address": "",
          "profilePic": ""}).then((value) {
          Utils.hideLoader();
          status = AuthStatus.successful;
          registerResponse.user!.sendEmailVerification();
          setState(() {
            loading = false;
          });
          snackBar(context, "User registered successfully.");
          Navigator.pop(context);
        }).catchError((e) {
          Utils.hideLoader();
          status = AuthExceptionHandler.handleAuthException(e);
          snackBar(context, AuthExceptionHandler.generateErrorMessage(status));
        });
      } catch (e) {
        Utils.hideLoader();
        setState(() {
          snackBar(context, e.toString());
          loading = false;
        });
      }

      Utils.hideLoader();
    }
  }

  //social button
  Widget buildSocialBtn(void Function() onTap, AssetImage logo, color,
      {logoColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Image(
          image: logo,
          width: 28,
          height: 28,
          color: logoColor,
        ),
      ),
    );
  }


  //TODO: Google Authentication
  Future<void> signInWithGoogle() async {
    bool checkInternet = await Utils.checkInternetConnection();
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    if (checkInternet) {
      AuthStatus? status;

      try {
        Utils.showLoader();
        signOut();
        final GoogleSignInAccount? googleSignInAccount =
        (await googleSignIn.signIn());
        if (googleSignIn.currentUser != null) {
          GoogleSignInAuthentication auth =
          await googleSignInAccount!.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: auth.accessToken,
            idToken: auth.idToken,
          );
          UserCredential authResult =
          await _auth.signInWithCredential(credential);
          _db
              .collection("users")
              .doc(authResult.user!.uid)
              .update({
                "name": authResult.user?.displayName,
                "bio": '',
                "id": authResult.user!.uid})
              .then((value) {
                Utils.hideLoader();
                status = AuthStatus.successful;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const HomePage()));
                snackBar(context, "User logged in successfully.");
              }).catchError((e) {
                Utils.hideLoader();
                status = AuthExceptionHandler.handleAuthException(e);
                snackBar(context, AuthExceptionHandler.generateErrorMessage(status));
              });

        } else {
          debugPrint('error');
          Utils.hideLoader();
        }
      } catch (e) {
        debugPrint('error: $e');
        Utils.hideLoader();
      }
    } else {}
  }

  // sign out from app
  Future<void> signOut() async {
    if (_auth.currentUser != null) {
      await googleSignIn.signOut();
      await _auth.signOut();
    }
  }

}
