import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCupertinoDialogOpenFrame(
  BuildContext context,
  String title,
  String description,
  String buttonTitle,
  String buttonTitle2,
  Color color,
  VoidCallback onExecutePressed,
) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              buttonTitle2, //"Stay",
              style: TextStyle(
                color: Color(0xff007AFF),
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
          ),

          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              onExecutePressed();
              Navigator.pop(context);
            },
            child: Text(
              buttonTitle,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
        ],
      );
    },
  );
}
