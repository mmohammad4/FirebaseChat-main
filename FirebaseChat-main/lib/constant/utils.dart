import 'dart:math';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:create_social/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
class Utils{
  // internet connection status
  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  // app loader
  static void showLoader() {
    EasyLoading.show(status: 'Loading ...');
  }

  static void hideLoader() {
    EasyLoading.dismiss();
  }

  // regex for email validation
  static bool isValidEmail(String em) {
    String p = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(em);
  }

  //get random color
  static Color getColor(int position) {
    switch(position){
      case 0:
        return const Color(0xffFA8072);
      case 1:
        return const Color(0xffFFA07A);
      case 2:
        return const Color(0xffD2691E);
      case 3:
        return const Color(0xffFFFF00);
      case 4:
        return const Color(0xffCCEEFF);
      case 5:
        return const Color(0xff00FF00);
      case 6:
        return const Color(0xffA52A2A);
      case 7:
        return const Color(0xffFF0000);
      case 8:
        return const Color(0xff8B0000);
      case 9:
        return const Color(0xffFFE4C4);
      case 10:
        return const Color(0xffD2B48C);
      case 11:
        return const Color(0xff0000FF);
      case 12:
        return const Color(0xffFF0000);
      case 13:
        return const Color(0xff00FF7F);
      case 14:
        return const Color(0xff98FB98);

    }
    return Colors.black;
  }

  //converting chat timing to String
  static String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);
    if (diff.inDays >= 7) {
      int week = diff.inDays ~/ 7;
      return '$week week ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} seconds ago';
    } else {
      return 'just now';
    }
  }

  //date and time into minus
  static String convertToDisplayTime(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

//widget for showing network image
  static Widget loadCachedNetworkImage(String? imageUrl, {int? memHeight,int? memWidth,
    double? height,double? width,BoxFit? fit,String? provider}) {

    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        provider ?? 'images/no_photo.png',
        fit: fit ?? BoxFit.cover,
        height: height,
        width: width,
      );
    } else {
      return memHeight != null && memWidth != null ? CachedNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: int.parse(memWidth.toString()),
        memCacheHeight: int.parse(memHeight.toString()),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit:  fit ?? BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Image.asset(
          provider ?? 'images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
          height: height,
          width: width,
        ),
        errorWidget: (context, url, error) => Image.asset(
          provider ?? 'images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
          height: height,
          width: width,
        ),
      ) :
      CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit:  fit ?? BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Image.asset(
          provider ?? 'assets/images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
          height: height,
          width: width,
        ),
        errorWidget: (context, url, error) => Image.asset(
          provider ?? 'assets/images/no_photo.png',
          fit:  fit ?? BoxFit.cover,
          height: height,
          width: width,
        ),
      );
    }
  }

  // dialog box
  static void showTwoButtonAlertDialog(
      {required BuildContext context,
        required String alertTitle,
        required String alertMsg,
        required String positiveText,
        required String negativeText,
        required Function() yesTap,
        Function()? noTap}) {
    // set up the buttons
    Widget noButton = TextButton(
      onPressed: noTap ?? () {
        Navigator.of(context).pop();
      },
      child: Text(
        negativeText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      ),
    );
    Widget yesButton = TextButton(
      child: Text(
        positiveText,
        style: const TextStyle(
          fontSize: 16.0,
          color: primaryColor,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        yesTap();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(alertTitle),
      content: Text(alertMsg),
      actions: [noButton, yesButton],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // random string generator
  static String generateRandomString1(int length) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    return List.generate(length, (index) => chars[r.nextInt(chars.length)])
        .join();
  }

  // file extension for images
  static String getFileExtension(String fileName) {
    try {
      return ".${fileName.split('.').last}";
    } catch(e){
      return '.jpg';
    }
  }
  // file extension for images
  static String getFileName(String fileName) {
    try {
      return fileName.split('/').last;
    } catch(e){
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      return timeStamp + getFileExtension(fileName);
    }
  }

  //get address from lat, long
  static Future<String> getAddress(double latitude,double longitude) async {
    String addr = "";
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude);

      Placemark address = placeMarks.first;
      if(address.street != null){
        addr += ", ${address.street!}";
      }
      if(address.name != null){
        addr += ", ${address.name!}";
      }
      if(address.subLocality != null){
        addr += ", ${address.subLocality!}";
      }
      if(address.locality != null){
        addr += ", ${address.locality!}";
      }else{
        if(address.subAdministrativeArea != null){
          addr += ", ${address.subAdministrativeArea!}";
        }
      }
      if(address.administrativeArea != null){
        addr += ", ${address.administrativeArea!}";
      }
      if(address.country != null){
        addr += ", ${address.country!}";
      }
      if(address.postalCode != null){
        addr += ", ${address.postalCode!}";
      }

      return addr.substring(2);
    } catch (e) {
      debugPrint(e.toString());
      return "";
    }
  }

  //get file type
  static FileTypes getFileType(String url){
    final File selectedFile = File(url);
    final fileExtension = extension(selectedFile.path);
    // debugPrint("$url || $fileExtension");

    if(fileExtension.toLowerCase().contains('png')
        || fileExtension.toLowerCase().contains('jpg')
        || fileExtension.toLowerCase().contains('jpeg')
        || fileExtension.toLowerCase().contains('gif')){
      return FileTypes.image;
    }else if (fileExtension.toLowerCase().contains('mp4')
        || fileExtension.toLowerCase().contains('mov')
        || fileExtension.toLowerCase().contains('wmv')
        || fileExtension.toLowerCase().contains('avi')
        || fileExtension.toLowerCase().contains('mpeg')
        || fileExtension.toLowerCase().contains('webm')
        || fileExtension.toLowerCase().contains('flv')
        || fileExtension.toLowerCase().contains('mkv')){
      return FileTypes.video;
    }else if (fileExtension.toLowerCase().contains('pdf')){
      return FileTypes.pdf;
    }else if (fileExtension.toLowerCase().contains('doc')
        || fileExtension.toLowerCase().contains('docx')){
      return FileTypes.doc;
    }else{
      return FileTypes.text;
    }
  }
}
enum FileTypes {image, video, pdf, doc, text}
