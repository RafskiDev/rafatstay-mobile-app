 import 'package:flutter/cupertino.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Widget/CheckBox.dart';
import '../../../Widget/WidgetTextField.dart';
import '../RateYourExperience_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
Widget celebrate(BuildContext context,WidgetRef ref,int? selectedGender){
  String text=TextLanguage().GetWord("ساعدنا في الاحتفال بك");
  List<String> parts = text.split(" ");
  String firstText = text.split(" ")[0];
  String secondText = parts.sublist(1).join(" ");
  return Container(
    width: Sizes(context).GetWidth() * 100,
    height: Sizes(context).GetHeight() * 30,
    decoration:BoxDecoration(
      color: Themes().GetColor("backgroundOffWhite"),
      borderRadius: BorderRadius.circular(18),
      border:Border.all(color: Themes().GetColor("secondary"),width:1),
    ),
    child:Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset("assets/icon/Celebrate.svg"),
              SizedBox(width:Sizes(context).GetWidth()*2,),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text: '${firstText} ',
                      style: TextStyle(color: Colors.black),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF082133), Color(0xFFC19632)],
                        ).createShader(bounds),
                        child: Text(
                          secondText,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height:Sizes(context).GetHeight()*2,),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1995),
                firstDate: DateTime(1900),
                lastDate: DateTime.now().subtract(const Duration(days: 1)), // ✅ قبل اليوم
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme:  ColorScheme.light(
                        primary: Themes().GetColor("primary"),      // لون الهيدر والأزرار
                     //   onPrimary: Themes().GetColor("background"),  // نص الهيدر
                        onSurface: Colors.black,  // نص الأيام
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor:Themes().GetColor("primary"), // OK / CANCEL
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                final formatted =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                ref.read(RateYourExperience_riverpod.notifier).birthday.text = formatted;
              }
            },
            child: AbsorbPointer( // ✅ يمنع الكيبورد
              child: WidgetTextField(
                backgroundColor: Themes().GetColor("backgroundOffWhite"),
                borderColor: Themes().GetColor("secondary"),
                Controller: ref.read(RateYourExperience_riverpod.notifier).birthday,
                focusNode: ref.read(RateYourExperience_riverpod.notifier).focusNodeBirthday,
                HintText: TextLanguage().GetWord('اختر تاريخ ميلادك'),
                keyboardType: TextInputType.datetime,
                iconData: 'assets/icon/birthday.svg',
              ),
            ),
          ),
          SizedBox(height:Sizes(context).GetHeight()*2,),
          Row(
            children: [
              SvgPicture.asset("assets/icon/Gender.svg"),
              SizedBox(width:Sizes(context).GetWidth()*1,),
              Text(TextLanguage().GetWord('جنس')),
            ],
          ),
          SizedBox(height:Sizes(context).GetHeight()*2,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CheckBox<String>(
                    value: TextLanguage().GetWord('ذكر'),
                    groupValue: selectedGender == 1 ? TextLanguage().GetWord('ذكر') : "", // إذا كانت state=1 فهي Male
                    onChanged: (val) {
                      ref.read(RateYourExperience_riverpod.notifier).setGender(1);
                    },
                    width: Sizes(context).GetWidth()*5,
                    height: Sizes(context).GetHeight()*5,

                    borderColor:Themes().GetColor("textSecondary"),
                    borderWidth: 3,
                  ),
                  SizedBox(width:Sizes(context).GetWidth()*1,),
                  SvgPicture.asset("assets/icon/Male.svg"),
                  SizedBox(width:Sizes(context).GetWidth()*1,),
                  Text(TextLanguage().GetWord('ذكر')),
                ],
              ),
              Row(
                children: [
                  CheckBox<String>(
                    value:TextLanguage().GetWord('أنثى'),
                    groupValue: selectedGender == 2 ? TextLanguage().GetWord('أنثى'): "",
                    onChanged: (val) {
                      ref.read(RateYourExperience_riverpod.notifier).setGender(2);
                    },
                    width: Sizes(context).GetWidth()*5,
                    height: Sizes(context).GetHeight()*5,
                    borderColor:Themes().GetColor("textSecondary"),
                    borderWidth: 3,
                  ),
                  SizedBox(width:Sizes(context).GetWidth()*1,),
                  SvgPicture.asset("assets/icon/Female.svg"),
                  SizedBox(width:Sizes(context).GetWidth()*1,),
                  Text(TextLanguage().GetWord('أنثى')),
                ],
              ),
              SizedBox(width:Sizes(context).GetWidth()*1,),
            ],
          ),
        ],
      ),
    ),
  );
}