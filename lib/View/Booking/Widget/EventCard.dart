import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../../Utils/Sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Widget/GradientText.dart';

class EventCard extends StatelessWidget {
  const EventCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF9F6EE);
    const Color textColor = Color(0xFF2D3E4E);
    final sizes = Sizes(context);
    final theme = Themes();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        // يمكنك إضافة Shadow هنا إذا رغبت
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. صورة المباراة (الجانب الأيسر)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/1c07e950ad312fdaaef1bdd4e1882d79f25c9233.png', // استبدله بمسار الصورة الخاصة بك
              width: sizes.GetHeight()*14,
              height: sizes.GetHeight()*14,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: sizes.GetWidth()*1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: sizes.GetHeight()*1),
                // الصف الأول: اسم الدوري وزر المشاركة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/icon/stadium.svg",width: sizes.GetWidth()*5),
                          SizedBox(width: sizes.GetWidth()*1),
                          Expanded(
                            child: Text(
                              'Roshen Saudi League',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // زر المشاركة
                    Container(
                      decoration:  BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.GetColor("primary"),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset("assets/icon/sharing.svg",color: theme.GetColor("white"),width: sizes.GetWidth()*5),
                    ),
                  ],
                ),

                SizedBox(height: sizes.GetHeight()*1),

                // الصف الثاني: المرافق (طاولة وقهوة)
                Row(
                  children: [
                    _buildInfoItem(context,"assets/icon/TableDetails.svg", '5 Indoor', sizes.GetWidth()*5, textColor),
                     SizedBox(width: sizes.GetWidth()*8),
                    _buildInfoItem(context,"assets/icon/Coffee.svg", 'Coffee', sizes.GetWidth()*5, textColor),
                  ],
                ),

                 SizedBox(height: sizes.GetHeight()*2),

                // الصف الثالث: التاريخ، الوقت، والسعر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context,"assets/icon/Calendar.svg", '22 May', sizes.GetWidth()*4, textColor),
                    _buildInfoItem(context,"assets/icon/tiems.svg", '9:00 PM', sizes.GetWidth()*4, textColor),
                    GradientText(
                      widget: Row(
                        children: [
                          SvgPicture.asset("assets/icon/LikePrice.svg"),
                          SizedBox(width: sizes.GetWidth()*1),
                          const Text(
                            '150',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: sizes.GetWidth()*1),
                          SvgPicture.asset("assets/icon/SAR.svg"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ويدجت مساعد لتقليل التكرار في الأيقونات والنصوص
  Widget _buildInfoItem(BuildContext context,String icon, String text, double? size, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
       // Icon(icon, color: iconColor, size: 18), // استبدله بـ SvgPicture إذا لزم الأمر
        SvgPicture.asset(icon, width: size,color: textColor),
         SizedBox(width: Sizes(context).GetWidth()*1),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}