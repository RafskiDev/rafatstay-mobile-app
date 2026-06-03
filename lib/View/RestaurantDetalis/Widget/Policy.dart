import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../RestaurantDetalis_riverpod.dart';
Widget Policy(BuildContext context, WidgetRef ref) {
  // جلب البيانات الخام من الريفربود
  final List<dynamic> rawPolicies = ref.read(RestaurantDetalis_riverpod.notifier).policies;

  if (rawPolicies.isEmpty) return const SizedBox.shrink();

  final List<Widget> items = [];

  // فحص العنصر الأول في القائمة
  final firstItem = rawPolicies[0];

  // 1️⃣ الحالة الأولى: إذا كانت البيانات عبارة عن نص مباشر (مثل الحالة مالتك الحالية)
  if (firstItem is String) {
    for (final policyText in rawPolicies) {
      if (policyText.toString().isNotEmpty) {
        items.add(infow(
          icon: "assets/icon/Reservations.svg", // الأيقونة الافتراضية
          text: "السياسات والأحكام",
          subtext: policyText.toString(),
        ));
      }
    }
  }
  // 2️⃣ الحالة الثانية: إذا كانت البيانات عبارة عن Map (الكود المتقدم مالتك)
  else if (firstItem is Map) {
    final policy = Map<String, dynamic>.from(firstItem);

    final cancellation = policy["cancellation"] is Map
        ? Map<String, dynamic>.from(policy["cancellation"])
        : null;
    final booking = policy["booking"] is Map
        ? Map<String, dynamic>.from(policy["booking"])
        : null;
    final general = policy["general"] is List
        ? policy["general"] as List
        : [];

    // ─── Cancellation ───
    if (cancellation != null) {
      final desc = cancellation["description"]?.toString() ?? "";
      if (desc.isNotEmpty) {
        items.add(infow(
          icon: "assets/icon/Reservations.svg",
          text: "سياسة الإلغاء",
          subtext: desc,
        ));
      }
    }

    // ─── Booking ───
    if (booking != null) {
      final minHours = booking["min_advance_hours"];
      final maxDays = booking["max_advance_days"];
      final hasDeposit = booking["requires_deposit"] == true;
      final depositPct = booking["deposit_percentage"];

      String bookingDesc = "";
      if (minHours != null) bookingDesc += "الحجز المسبق: $minHours ساعة على الأقل\n";
      if (maxDays != null)  bookingDesc += "الحد الأقصى: $maxDays يوم مقدماً\n";
      if (hasDeposit)       bookingDesc += "عربون: $depositPct%";

      if (bookingDesc.isNotEmpty) {
        items.add(infow(
          icon: "assets/icon/Reservations.svg",
          text: "سياسة الحجز",
          subtext: bookingDesc.trim(),
        ));
      }
    }

    // ─── General ───
    for (final item in general) {
      if (item is! Map) continue;
      final title = item["title"]?.toString() ?? "";
      final desc  = item["description"]?.toString() ?? "";
      if (title.isNotEmpty || desc.isNotEmpty) {
        items.add(infow(
          icon: _getIcon(item["key"]?.toString()),
          text: title,
          subtext: desc,
        ));
      }
    }
  }

  if (items.isEmpty) return const SizedBox.shrink();

  return Column(
    children: items
        .map((w) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: w,
    ))
        .toList(),
  );
}

String _getIcon(String? key) {
  switch (key) {
    case "dress_code":          return "assets/icon/Bowknot.svg";
    case "children_policy":     return "assets/icon/children.svg";
    case "behavior":            return "assets/icon/Behavior.svg";
    case "photography_smoking": return "assets/icon/PhotographySmoking.svg";
    default:                    return "assets/icon/Reservations.svg";
  }
}

class infow extends StatelessWidget {
  final String icon;
  final String text;
  final String subtext;

  const infow({
    super.key,
    required this.icon,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            icon,
            width: 22,
            height: 22,
            color: Themes().GetColor("primaryA"),
          ),
        ),
        SizedBox(width: Sizes(context).GetWidth() * 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (text.isNotEmpty)
                Text(
                  TextLanguage().GetWord(text),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              if (subtext.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtext,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}