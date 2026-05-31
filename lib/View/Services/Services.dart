import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes().GetColor("background"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/icon/ComingSoon.svg"),
              Text(
                  TextLanguage().GetWord("فنادق قريباً"),
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Themes().GetColor("secondaryPrimary")),
              ),
              Text(
                  TextLanguage().GetWord("نحن بصدد إعداد تجربة حجز فنادق مميزة لكم. ترقبوا المزيد."),
                  style: TextStyle(fontSize: 12,color: Themes().GetColor("primaryS")),
                  textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
