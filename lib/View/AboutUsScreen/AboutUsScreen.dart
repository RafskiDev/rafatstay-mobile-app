import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

import '../../Utils/Sizes.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import 'aboutUsProvider.dart';

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // الاستماع للبروفايدر لإعادة البناء عند تحويل اللغة
    final currentLanguageIndex = ref.watch(aboutUsProvider);

    // جلب البيانات المترجمة فوراً بسطر واحد
    final aboutUsSections = ref.read(aboutUsProvider.notifier).aboutUsData;

    // تحديد اتجاه النص بناءً على اللغة (1 يعني عربي)
    final isArabic = currentLanguageIndex == 1;

    return Scaffold(
      backgroundColor: Themes().GetColor("background"),
      appBar: buildCustomAppBar(context,TextLanguage().GetWord("تعرف علينا")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Sizes(context).GetHeight()*2),
        child: ListView.builder(
          itemCount: aboutUsSections.length,

          itemBuilder: (context, index) {
            final section = aboutUsSections[index];
            return Padding(
              padding:  EdgeInsets.only(bottom:Sizes(context).GetHeight()*2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان الرئيسي بجانبه الدائرة السوداء
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // الدائرة السوداء الصغيرة المقتبسة من التصميم
                      Container(
                        width: Sizes(context).GetWidth()*3,
                        height: Sizes(context).GetWidth()*3,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D233A), // لون كحلي داكن/أسود متناسق مع التصميم
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: Sizes(context).GetWidth()*2),

                      // نص العنوان
                      Expanded(
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0D233A), // نفس درجة اللون الداكنة للعنوان
                          ),
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: Sizes(context).GetHeight()*1),

                  // عرض الوصف إن وجد
                  if (section.description != null) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        // إزاحة خفيفة للداخل ليتناسق النص تحت العنوان مباشرة دون الدائرة
                        left: isArabic ? 0 : 24.0,
                        right: isArabic ? 24.0 : 0,
                      ),
                      child: Text(
                        section.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5, // ليعطي مسافة مريحة للأسطر (Line height)
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],

                  // عرض النقاط إن وجدت
                  if (section.points != null)
                    ...section.points!.map((point) => Padding(
                      padding: EdgeInsets.only(
                        left: isArabic ? 0 : 28.0,
                        right: isArabic ? 28.0 : 0,
                        top: 6.0,
                        bottom: 6.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // علامة النقطة الفرعية المصممة
                          const Text(
                            "▪ ",
                            style: TextStyle(color: Color(0xFF0D233A), fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}