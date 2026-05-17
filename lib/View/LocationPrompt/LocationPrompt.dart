import 'package:flutter/material.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'LocationPrompt_riverpod.dart';
class LocationPrompt extends ConsumerWidget {
  const LocationPrompt({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(context,""),
      body:Container(
        child:Column(
          children: [
            Center(
              child:SvgPicture.asset("assets/images/location.svg",),
            ),
            SizedBox(height:sizes.GetHeight()*2,),
            Text(textLanguage.GetWord("تمكين موقعك"),style:TextStyle(fontWeight:FontWeight.bold),),
            SizedBox(height:sizes.GetHeight()*2,),
            Text(
                textLanguage.GetWord("لإظهار أماكن الإقامة القريبة منك، والعروض المخصصة، وأفضل التجارب حولك، نحتاج إلى الوصول إلى موقعك. يساعدنا موقعك في تقديم تجربة أسرع وأذكى."),
                textAlign:TextAlign.center,
               ),
            SizedBox(height:sizes.GetHeight()*2,),
            WidgetButton(
              context: context,
              width:sizes.GetWidth()*40,
              buttonText:textLanguage.GetWord("السماح بالموقع"),
              onPressed: () async{
                await ref.read(LocationPrompt_riverpod.notifier).requestLocationPermission();
              },
              backgroundColor:theme.GetColor("primary"),
              textColor:theme.GetColor("textPrimary"),
              isCircular: true,
            ),
            SizedBox(height:sizes.GetHeight()*2,),
            WidgetButton(
              context: context,
              width:sizes.GetWidth()*40,
              buttonText:textLanguage.GetWord("ربما في وقت لاحق"),
              onPressed: () {
                print("تم الضغط على الزر");
              },
              backgroundColor:theme.GetColor("background"),
              textColor:theme.GetColor("textPrimary"),
              borderColor:theme.GetColor("textPrimary"),
              isCircular: true,
            ),
          ],
        ),
      ),
    );
  }
}
