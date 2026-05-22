import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildDateCard({
  required Sizes sizes,
  required String svg,
  required String title_1,
  required String title_2,
  String? title_3,
  bool underline=false
}) {
  return Container(
    width: sizes.GetWidth() * 47,
    height: sizes.GetHeight() * 17,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFDFBF4),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        // 1. الصف العلوي (الأيقونة + التاريخ)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // حاوية الأيقونة الزرقاء الفاتحة
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F4FC),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                svg,
               // width: 24,
              //  height: 24,
                color: const Color(0xFF8B6E32),
              ),
            ),
            SizedBox(width: sizes.GetWidth()*1),
            Flexible(
              child: Text(
                title_1,
                style: TextStyle(
                  color: const Color(0xFF102C3D),
                  fontSize: sizes.GetHeight() * 1.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.GetHeight() * 1),
          Expanded(
            child: Text(
              title_2,
              textAlign: TextAlign.center,
              style: underline?TextStyle(
                color: Colors.grey[500],
                fontSize: sizes.GetHeight() * 1.8,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline, // ← هذا يضيف الخط تحت النص
                decorationColor: Colors.grey, // لون الخط (اختياري)
                decorationThickness: 1.5, // سماكة الخط (اختياري)
              ):TextStyle(
                color: Colors.grey[500],
                fontSize: sizes.GetHeight() * 1.8,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        SizedBox(height: sizes.GetHeight()*1),
        if (title_3 != null) ...[
          Text(
            title_3,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: sizes.GetHeight() * 1.8,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    ),
  );
}