import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
Widget personCard(
    BuildContext context,
    String image,
    String text, {
      required bool isSelected,
      required VoidCallback onTap,
    }) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: Sizes(context).GetWidth() * 40,
      height: Sizes(context).GetHeight() * 28,
      decoration: BoxDecoration(
        color:Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected
              ? Themes().GetColor("textPrimary")
              : Colors.transparent,
          width:1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: Sizes(context).GetWidth() * 30,
                height: Sizes(context).GetHeight() * 15,
              ),
            ),
            SizedBox(height: Sizes(context).GetHeight() * 2),
            Text(
              text,
              style: TextStyle(
                fontSize: Sizes(context).GetHeight() * 1.7,
                color: Themes().GetColor("textPrimary"),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Sizes(context).GetHeight() * 2),
            Text(
              TextLanguage().GetWord('يتعلم أكثر'),
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Themes().GetColor("textPrimary"),
                color: Themes().GetColor("textPrimary"),
                fontSize: Sizes(context).GetHeight() * 1.7,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
