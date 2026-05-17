import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../language/language.dart';
import '../Home_riverpod.dart';
class LanguageDropdown extends StatelessWidget {
  final WidgetRef ref;
  const LanguageDropdown({super.key,required this.ref});
  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final lang = ref.read(Home_riverpod.notifier)
        .box.read("Language") ?? "en";
   return GestureDetector(
     onTap: () {
       ref.read(Home_riverpod.notifier).toggleLanguage();
       Navigator.push(context, PageRouteBuilder(
         pageBuilder: (_, __, ___) => language(),
         transitionDuration: Duration.zero,
         reverseTransitionDuration: Duration.zero,
       ));
     },
     child: Container(
        margin: EdgeInsets.symmetric(vertical: sizes.GetHeight() * 1,horizontal: sizes.GetWidth() * 1),
        decoration:BoxDecoration(
          color: Themes().GetColor("background"),
          borderRadius: BorderRadius.circular(20),
        ),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset("assets/icon/language.svg",height:sizes.GetHeight()*2.2),
            SizedBox(width:sizes.GetWidth()*1),
            Text("${ref.read(Home_riverpod.notifier).box.read("user")["preferred_language"]??" English "}",),
            SizedBox(width:sizes.GetWidth()*1),
            Transform.rotate(
              angle: lang == 0 ? 0 : 3.14,
              child: SvgPicture.asset(
                "assets/icon/Arrow_one.svg",
                height: sizes.GetHeight() * 2.2,
              ),
            ),
          ],
        ),
      ),
   );
  }
}