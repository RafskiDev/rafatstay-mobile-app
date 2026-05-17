import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/WidgetButton.dart';
class NavigationInfoCard extends StatelessWidget {
  final String duration;    // الوقت (مثلاً: 27 min)
  final String distance;    // المسافة (مثلاً: 15 km)
  final String arrivalTime; // وقت الوصول (مثلاً: 01:04 PM)
  final VoidCallback onRouteTap;
  final VoidCallback onCloseTap;

  const NavigationInfoCard({
    super.key,
    required this.duration,
    required this.distance,
    required this.arrivalTime,
    required this.onRouteTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: sizes.GetHeight() * 2,
          left: sizes.GetWidth() * 5,
          right: sizes.GetWidth() * 5,
          bottom: sizes.GetHeight() * 4
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط السحب
          Container(
            width: sizes.GetWidth() * 12,
            height: sizes.GetHeight() * 0.6,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // قسم المعلومات الديناميكي
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: theme.GetColor("primary"), size: sizes.GetHeight() * 3),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.GetColor("primary"),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  Row(
                    children: [
                      Text(distance, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(width: sizes.GetWidth() * 2),
                      Container(width: sizes.GetHeight() * 0.5, height: sizes.GetHeight() * 0.5, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                      SizedBox(width: sizes.GetWidth() * 2),
                      Text(arrivalTime, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),

              // قسم الأزرار
              Row(
                children: [
                  CircularButton(
                    size: sizes.GetHeight() * 5.5,
                    backgroundColor: Colors.white,
                    borderColor: Colors.white,
                    onTap: onRouteTap,
                    child: SvgPicture.asset('assets/icon/alt_route_outlined.svg', width: sizes.GetHeight() * 2.5),
                  ),
                  const SizedBox(width: 12),
                  CircularButton(
                    size: sizes.GetHeight() * 5.5,
                    backgroundColor: Colors.white,
                    borderColor: Colors.white,
                    onTap: onCloseTap,
                    child: SvgPicture.asset('assets/icon/ic_close.svg', width: sizes.GetHeight() * 2.5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}