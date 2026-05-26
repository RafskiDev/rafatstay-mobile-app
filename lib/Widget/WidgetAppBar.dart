import 'package:flutter/material.dart';
import 'dart:ui';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../View/notifications/notifications.dart';
AppBar buildCustomAppBar(BuildContext context, String title,{bool showBackButton = true,bool showNotification=true} ) {
  Themes theme = Themes(); // إذا أردت استخدام الألوان من Themes
  final sizes=Sizes(context);
  return AppBar(
    backgroundColor: theme.GetColor("background"), // لون خلفية الـ AppBar
    elevation: 0, // إزالة الظل
    centerTitle: true, // يجعل العنوان في الوسط
    leading:showBackButton? IconButton(
      icon: Icon(Icons.arrow_back_ios, color: theme.GetColor("textPrimary")),
      onPressed: () {
        Navigator.pop(context,0); // للرجوع للشاشة السابقة
      },
    ):null,
    title: Text(
      title,
      style: TextStyle(
        color: theme.GetColor("textPrimary"),
        fontWeight: FontWeight.bold,
        fontFamily: "Cairo",
        fontSize: sizes.GetHeight()*2.4,
      ),
    ),
    actions:[
      showNotification?IconButton(
        onPressed:(){
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
               notifications(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        icon:Container(
          width: Sizes(context).GetWidth()*9,
          height: Sizes(context).GetHeight()*9,
          decoration: BoxDecoration(
            color: Colors.white,        // لون الخلفية البيضاء
            shape: BoxShape.circle,     // شكل دائري
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            "assets/icon/notifications.svg",
          ),
        ),
      ):Container(),
    ]
  );
}

class GlassAppBar extends StatelessWidget {
  final String titel;
  final VoidCallback onBack;
  final VoidCallback onNotification;

  const GlassAppBar({
    required this.titel,
    required this.onBack,
    required this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    final sizes=Sizes(context);
    final theme = Themes();
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*2),
          height: sizes.GetHeight()*6.5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: sizes.GetHeight() * 4.5,
                width: sizes.GetHeight() * 4.5,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF5EB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero, // ✅ يلغي الإزاحة
                    constraints: const BoxConstraints(), // ✅ يمنع الحجم الافتراضي
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: theme.GetColor("textPrimary"),
                    ),
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    titel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color:Color(0xFFFAF5EB),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            notifications(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    "assets/icon/notifications.svg",
                    height:sizes.GetHeight()*3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

