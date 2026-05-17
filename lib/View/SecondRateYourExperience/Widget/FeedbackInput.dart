import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
Widget FeedbackInput(BuildContext context, String text) {
  return Container(
    height: Sizes(context).GetHeight() * 12,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Themes().GetColor("secondary500"),
          Themes().GetColor("primary"),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    padding: const EdgeInsets.all(1), // سماكة البوردر فقط
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes(context).GetWidth() * 3,
        vertical: Sizes(context).GetHeight() * 1.5,
      ),
      decoration: BoxDecoration(
        color: Themes().GetColor("backgroundOffWhite"), // خلفية الإدخال
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    ),
  );
}
