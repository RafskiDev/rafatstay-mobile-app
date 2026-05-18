import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Widget/GradientText.dart';

class EventCard extends StatelessWidget {
  final List<dynamic> eventsData;

  const EventCard({Key? key, required this.eventsData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود بيانات لتجنب الـ Crash
    if (eventsData.isEmpty) return const SizedBox.shrink();

    final event = eventsData[0];
    const Color backgroundColor = Color(0xFFF9F6EE);
    const Color textColor = Color(0xFF2D3E4E);
    final sizes = Sizes(context);
    final theme = Themes();

    // 1. استخراج الطاولات ونوع الموقعsafely
    final List<dynamic> tables = event["tables"] ?? [];
    final String locationType = tables.isNotEmpty ? (tables[0]["location_type"] ?? "indoor") : "indoor";
    final int tablesCount = tables.length;
    String displayTime = "---";
    final startsAtStr = event["ends_at"]?.toString();
    if (startsAtStr != null) {
      final dateTime = DateTime.tryParse(startsAtStr);
      if (dateTime != null) {
        int hour = dateTime.hour;
        final String ampm = hour >= 12 ? "PM" : "AM";
        hour = hour % 12;
        hour = hour == 0 ? 12 : hour;
        final String minute = dateTime.minute.toString().padLeft(2, '0');
        displayTime = "$hour:$minute $ampm";
      }
    }
    String eventTime = event["ends_at"].toString().contains(' ')
        ? event["ends_at"].toString().split(' ').last
        : event["ends_at"].toString();
    final double rawPrice = double.tryParse(event["price"]?.toString() ?? "0") ?? 0.0;
    final String price = rawPrice.toInt().toString();
  //  print(tables);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/1c07e950ad312fdaaef1bdd4e1882d79f25c9233.png',
              width: sizes.GetHeight() * 14,
              height: sizes.GetHeight() * 14,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: sizes.GetWidth() * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: sizes.GetHeight() * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/icon/stadium.svg", width: sizes.GetWidth() * 5),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Expanded(
                            child: Text(
                              event["title"]?.toString() ?? event["business_name"]?.toString() ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 14,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.GetColor("primary"),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        "assets/icon/sharing.svg",
                        color: theme.GetColor("white"),
                        width: sizes.GetWidth() * 4,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sizes.GetHeight() * 1.5),

                Row(
                  children: [
                    _buildInfoItem(context, "assets/icon/TableDetails.svg", '$tablesCount $locationType', sizes.GetWidth() * 5, textColor),
                    SizedBox(width: sizes.GetWidth() * 6),
                    _buildInfoItem(context, "assets/icon/Coffee.svg", 'Buffet', sizes.GetWidth() * 5, textColor),
                  ],
                ),

                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context, "assets/icon/Calendar.svg", DateTimeHelper.extractDate(event["starts_at"]), sizes.GetWidth() * 4, textColor),
                    _buildInfoItem(context, "assets/icon/tiems.svg", DateTimeHelper().formatTime(eventTime), sizes.GetWidth() * 4, textColor),
                    GradientText(
                      widget: Row(
                        children: [
                          SvgPicture.asset("assets/icon/LikePrice.svg"),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
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

  Widget _buildInfoItem(BuildContext context, String icon, String text, double? size, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(icon, width: size, color: textColor),
        SizedBox(width: Sizes(context).GetWidth() * 1),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}