import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/forms/registerform.dart';
import 'package:create_social/pages/home.dart';
import 'package:create_social/style/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constant/AuthExceptionHandler.dart';
import '../constant/utils.dart';
import '../pages/Chat/UsersChatListScreen.dart';
import '../widgets/CustomHeader.dart';
import 'dart:ui' as ui show ParagraphBuilder, PlaceholderAlignment;

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 80, 30, 20),
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
                  height: 20,
                ),
                const CustomHeader(
                  middleChild: Text(
                    'Login',
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(
                  height: 20,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        forgotPasswordDialog(context);
                      },
                      child: const Text("Forgot My Password?",
                          style: TextStyle(color: primaryColor))),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                    onPressed: () {
                      login(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "LOGIN",
                        style: TextStyle(letterSpacing: 2, fontSize: 20, color: primaryColor),
                      ),
                    )),
                const SizedBox(
                  height: 30,
                ),
                Text.rich(
                  TextSpan(
                      text: 'Don\'t have an account ? ',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      children: [
                        WidgetSpan(
                            alignment: ui.PlaceholderAlignment.middle,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const RegisterForm()));
                                },
                                child: const Text("SIGN UP",style: TextStyle(color: primaryColor,fontWeight: FontWeight.w800,),))),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                            color: primaryColor,
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
    );
  }

  // social button for sign in
  Widget buildSocialBtn(void Function() onTap, AssetImage logo, color, {logoColor}) {
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

  //TODO: Login with email and password
  Future<void> login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      AuthStatus? status;
      try {
        Utils.showLoader();
        _auth
            .signInWithEmailAndPassword(
                email: _email.text.trim(), password: _password.text.trim())
            .then((value) {
          Utils.hideLoader();
          status = AuthStatus.successful;
          setState(() {
            if (value.user!.emailVerified) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const HomePage()));
            } else {
              snackBar(context, "User logged in but email is not verified.");
              value.user!.sendEmailVerification();
            }
          });
        }).catchError((e) {
          Utils.hideLoader();
          status = AuthExceptionHandler.handleAuthException(e);
          snackBar(context, AuthExceptionHandler.generateErrorMessage(status));
        });
      } catch (e) {
        Utils.hideLoader();
        setState(() {
          snackBar(context, e.toString());
        });
      }
    }
  }

  //TODO: Google Authentication
  Future<void> signInWithGoogle() async {
    bool checkInternet = await Utils.checkInternetConnection();
    final FirebaseFirestore db = FirebaseFirestore.instance;

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
          db
              .collection("users")
              .doc(authResult.user!.uid)
              .update({"name": authResult.user?.displayName, "bio": '' ,"id": authResult.user!.uid}).then((value) {
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

  Future<void> signOut() async {
    if (_auth.currentUser != null) {
      await googleSignIn.signOut();
      await _auth.signOut();
    }
  }

  //TODO: forgot password
  Future<AuthStatus> forgotPassword({required String email}) async {
    Utils.showLoader();
    AuthStatus? status;
    await _auth.sendPasswordResetEmail(email: email).then((value) {
      Utils.hideLoader();
      snackBar(context, "Password reset sent to email.");
      status = AuthStatus.successful;
    }).catchError((e) {
      Utils.hideLoader();
      status = AuthExceptionHandler.handleAuthException(e);
      snackBar(context, AuthExceptionHandler.generateErrorMessage(status));
    });
    return status!;
  }

  // forgot password dialog
  Future<void> forgotPasswordDialog(BuildContext context) async {
    TextEditingController forgotEmailController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              height: 300,
              padding: const EdgeInsets.only(left: 20, right: 20),
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'arial',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: forgotEmailController,
                      decoration: inputStyling("Enter email address"),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        if (Utils.isValidEmail(
                            forgotEmailController.text.trim())) {
                          await forgotPassword(
                              email: forgotEmailController.text.trim());
                          Navigator.of(context).pop();
                        } else {
                          snackBar(
                              context, "Please enter valid email address.");
                        }
                      },
                      child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "SEND",
                            style: TextStyle(letterSpacing: 2, fontSize: 20),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
