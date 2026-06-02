import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Utils/Them.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Themes().GetColor("background"),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icon/ComingSoon.svg",
                  width: width * 0.1,
                  height: height * 0.1,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: height * 0.01),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    TextLanguage().GetWord("فنادق قريباً"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Themes().GetColor("secondaryPrimary")),
                  ),
                ),
                SizedBox(height: height * 0.01),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    TextLanguage().GetWord("نحن بصدد إعداد تجربة حجز فنادق مميزة لكم. ترقبوا المزيد."),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Themes().GetColor("primaryS")),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}