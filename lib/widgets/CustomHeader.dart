import 'dart:io';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final Widget? leftChild;
  final Widget middleChild;
  final Widget? rightChild;
  const CustomHeader({Key? key,
   this.leftChild,
   required this.middleChild,
   this.rightChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Platform.isAndroid ? 56 : 45 ,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: <Widget>[
          if(leftChild != null)...[
            leftChild!
          ],
          Expanded(child: Center(child: middleChild)),
          if(rightChild != null)...[
            rightChild!
          ],

        ],
      ),
    );
  }
}
