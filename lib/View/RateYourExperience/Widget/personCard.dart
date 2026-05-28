import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../Widget/ShowLoading.dart';
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
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child:  CachedNetworkImage(
                imageUrl:image,
                fit: BoxFit.cover,
                width: Sizes(context).GetWidth() * 30,
                height: Sizes(context).GetHeight() * 13,
                placeholder: (context, url) =>  Center(
                  child:showLoading(),
                ),
                //ضفت هذا حتى لا يطبع الخطا
                errorListener: (dynamic exception) {
                },
                errorWidget: (context, url, error) {
                  return Container(
                    width: double.infinity,
                    height: Sizes(context).GetHeight() * 13,
                    color: const Color(0xFFEEEEEE),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
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
            SizedBox(height: Sizes(context).GetHeight() * 1),
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
