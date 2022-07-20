import 'dart:io';
import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 20, 68, 74);
const Color primaryTransColor = Color.fromARGB(200, 20, 68, 74);
const Color primaryTransColor1 = Color.fromARGB(50, 20, 68, 74);
const Color primaryDarkColor = Color.fromARGB(255, 20, 68, 74);
const Color primaryLiteColor = Color.fromARGB(255, 20, 68, 74);

const double standardText = 18.0;
const double largeText = 18.0;
final double headerSize = Platform.isIOS ? 44.0 : 56.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

void snackBar(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

InputDecoration inputStyling(String labelText, {hintText}) =>
    InputDecoration(labelText: labelText, hintText: hintText);
