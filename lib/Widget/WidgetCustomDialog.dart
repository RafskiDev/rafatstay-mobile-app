import 'package:flutter/material.dart';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
Future<void> WidgetCustomDialog(BuildContext context,{
      Widget? child,
      bool barrierDismissible = true,
      Color backgroundColor = Colors.transparent,

    }) {
  Themes theme = Themes();
  final sizes=Sizes(context);
  return showDialog(
    context: context,
    barrierDismissible:barrierDismissible,
    builder: (context) {
      return Dialog(
        backgroundColor:backgroundColor,
        insetPadding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color:backgroundColor==Colors.transparent?theme.GetColor("primary").withOpacity(0.5):backgroundColor,
            borderRadius: BorderRadius.circular(sizes.GetHeight()*3),
            border: Border.all(
              color: theme.GetColor("background"), // اللون الذي تريد
              width: 0.3,                         // سماكة الخط
            ),
          ),
          padding: EdgeInsets.all(sizes.GetHeight()*1.2),
          child:child,
        ),
      );
    },
  );
}