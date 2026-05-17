
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../../Utils/Sizes.dart';
Widget evaluation(
    BuildContext context,
    String text,
    String icon,
    int rating,
    ) {
  return Container(
    width: Sizes(context).GetWidth() * 45,
    height: Sizes(context).GetHeight()*15,
    padding: EdgeInsets.all(Sizes(context).GetWidth() * 3),
    decoration: BoxDecoration(
      color: Themes().GetColor("backgroundOffWhite"),
      borderRadius: BorderRadius.circular(18),
      border:Border.all(width:0.2,color: Themes().GetColor("secondary")),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
            ),
            SizedBox(width: Sizes(context).GetWidth() * 1),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Sizes(context).GetHeight() * 1.5),
        // صف النجوم
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return SvgPicture.asset(
              index < rating
                  ? "assets/icon/Star.svg"
                  : "assets/icon/Star_off.svg",
              height: Sizes(context).GetHeight() *3,
            );
          }),
        ),
      ],
    ),
  );
}
