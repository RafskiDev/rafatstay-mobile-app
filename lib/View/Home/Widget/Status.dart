import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/CategoryItemCard.dart';
import '../../Story/Story.dart';
import '../Home_riverpod.dart';
class Status extends ConsumerWidget {
  const Status();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final sizes = Sizes(context);
    final statusItems = ref.watch(Home_riverpod.notifier).statuses;

   // if (statusItems.isEmpty) return SizedBox.shrink();
    return SizedBox(
      height: sizes.GetHeight() * 16.5,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: statusItems.length,
        itemBuilder: (context, index) {
          final item = statusItems[index];
          final String business_name = (item["business_name"] ?? "").toString();
          final latestStatus = item["latest_status"] as Map<String, dynamic>?;
          final String statusImage = latestStatus != null ? (latestStatus["media_url"] ?? "").toString() : "";
          return CategoryItemCard(
            imagePath:statusImage,
            width: sizes.GetWidth() * 19,
            height: sizes.GetHeight() * 11,
            nameImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
            circularNameImage: true,
            name: business_name,
            paddings: 1,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Story(
                    branchData: item, // 👈 نمرر الماب بالكامل فقط هنا
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          );
        },
      ),
    );
  }
}