import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Widget/ShowLoading.dart';
import '../RestaurantDetalis_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget SuperGuest(BuildContext context, WidgetRef ref) {
  final superGuests = ref.read(RestaurantDetalis_riverpod.notifier).superGuests;

  if (superGuests.isEmpty) return const SizedBox.shrink();

  final sizes = Sizes(context);
  final theme = Themes();

  return GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: sizes.GetWidth() * 1,
      // 👇 تم تعديل النسبة هنا ليعطي الكرت مرونة بالطول للأسفل ولا يختفي النص
      childAspectRatio: 0.45,
    ),
    itemCount: superGuests.length,
    itemBuilder: (context, index) {
      final guest = superGuests[index];

      final user = guest["user"] is Map ? guest["user"] as Map : {};
      final String name = user["name"]?.toString() ?? "ضيف مميز";
      final String avatarUrl = user["avatar_url"]?.toString() ?? "";

      final String memberSince = guest["member_since"]?.toString() ?? "";
      final String visitsCount = guest["visits_count"]?.toString() ?? "0";
      final String benefit = guest["benefit"]?.toString() ?? "0";

      return Container(
        width: sizes.GetWidth() * 39,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── الصورة الشخصية ───
            Container(
              height: sizes.GetHeight() * 10,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.GetColor("secondary"),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: showLoading()),
                  errorWidget: (context, url, error) {
                    return Container(
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6), // زيادة المسافة قليلاً لتنفس العناصر

            // ─── الاسم ───
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/profile_stars.svg", height: sizes.GetHeight() * 2, color: theme.GetColor("primaryA")),
                SizedBox(width: sizes.GetWidth() * 1),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.GetColor("primaryA"), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ─── تاريخ الانضمام (تم إصلاحه بـ Expanded) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/Since.svg", height: sizes.GetHeight() * 2, color: theme.GetColor("primaryA")),
                SizedBox(width: sizes.GetWidth() * 1),
                Expanded(
                  child: Text(
                    memberSince,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.GetColor("textPrimary"), fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ─── عدد الزيارات ───
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/Visits.svg", height: sizes.GetHeight() * 2, color: theme.GetColor("primaryA")),
                SizedBox(width: sizes.GetWidth() * 1),
                Expanded(
                  child: Text(
                    "$visitsCount زيارات",
                    maxLines: 1,
                    style: TextStyle(color: theme.GetColor("textPrimary"), fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ─── الفائدة / الخصم ───
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/benefit.svg", height: sizes.GetHeight() * 2),
                SizedBox(width: sizes.GetWidth() * 1),
                Expanded(
                  child: Text(
                    "خصم %$benefit",
                    maxLines: 1,
                    style: TextStyle(color: theme.GetColor("textPrimary"), fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}