import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../RateYourExperience/Widget/evaluation.dart';
import 'SecondRateYourExperience_riverpod.dart';
import 'Widget/FeedbackInput.dart';
import 'Widget/GradientBorderContainer.dart';
class SecondRateYourExperience extends ConsumerWidget {
  SecondRateYourExperience({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(SecondRateYourExperience_riverpod);
    final selectedGender = ref.watch(SecondRateYourExperience_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return Scaffold(
      backgroundColor:theme.GetColor("background"),
      appBar:buildCustomAppBar(context,textLanguage.GetWord('قيّم تجربتك')),
      body:Container(
        padding:EdgeInsets.symmetric(horizontal: sizes.GetWidth()*2),
        child:SingleChildScrollView(
          child:Column(
            children: [
              Row(
                children: [
                  Text(textLanguage.GetWord('نأسف لأن تجربتك لم تكن جيدة'))
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                children: [
                  Text(textLanguage.GetWord('أخبرنا بما حدث من خطأ حتى نتمكن من التحسين'),style: TextStyle(color:theme.GetColor("textSecondary")),)
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              FeedbackInput(context,textLanguage.GetWord('ما الذي لم ينجح معك؟')),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                children: [
                  Text(textLanguage.GetWord("تقييم المطعم"))
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              SizedBox(
                height: Sizes(context).GetWidth() * 28,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // عرض أفقي
                  itemCount: ref.read(SecondRateYourExperience_riverpod.notifier).ratings.length, // عدد العناصر
                  itemBuilder: (context, index) {
                    final reviews = ref.read(SecondRateYourExperience_riverpod.notifier).ratings[index];
                    return Padding(
                      padding:EdgeInsets.only(right: sizes.GetWidth()*2),
                      child: evaluation(
                        context,
                        reviews["title"].toString(),
                        reviews["icon"].toString(),
                        reviews["rate"] as int,
                         (value) {

                          }
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                children: [
                  Text(textLanguage.GetWord('تقييم الخدمة'))
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              SizedBox(
                height: Sizes(context).GetWidth() * 28,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // عرض أفقي
                  itemCount: ref.read(SecondRateYourExperience_riverpod.notifier).ratings.length, // عدد العناصر
                  itemBuilder: (context, index) {
                    final reviews = ref.read(SecondRateYourExperience_riverpod.notifier).ratings[index];
                    return Padding(
                      padding:EdgeInsets.only(right: sizes.GetWidth()*2),
                      child: evaluation(
                        context,
                        reviews["title"].toString(),
                        reviews["icon"].toString(),
                        reviews["rate"] as int,
                        (value) {

                          }
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              GradientBorderContainer(
                child: Column(
                  children: [
                    SizedBox(height: Sizes(context).GetHeight() * 1),
                    Row(
                      children: [
                        Text(textLanguage.GetWord('شاركنا رأيك'),style:TextStyle(fontSize:sizes.GetHeight()*2.2,color:Themes().GetColor("textPrimary")),),
                      ],
                    ),
                    SizedBox(height: Sizes(context).GetHeight() * 1),
                    Row(
                      children: [
                        Text(
                          textLanguage.GetWord('ملاحظاتكم تساعدنا على تقديم خدمة أفضل لكم'),
                          style: TextStyle(
                            color: Themes().GetColor("secondary"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              //Send feedback
              WidgetButton(
                width: sizes.GetWidth()*45,
                isCircular:true,
                context: context,
                buttonText:textLanguage.GetWord('أرسل ملاحظاتك'),
                textColor:Themes().GetColor("textPrimary"),
                onPressed: () {
                  print("تم الضغط على الزر");
                },
                backgroundColor:Themes().GetColor("primaryA"),
              ),
            ]
          )
        )
      ),
    );
  }
}