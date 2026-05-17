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
          final String name = (item["name"] ?? "").toString();
          final String logo = (item["logo"] ?? "").toString();
          final latestStatus = item["latest_status"];
          final String mediaUrl = (latestStatus?["media_url"] ?? "").toString();

          return CategoryItemCard(
            imagePath: "assets/images/A_Tazaj.png",
            width: sizes.GetWidth() * 19,
            height: sizes.GetHeight() * 11,
            nameImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
            circularNameImage: true,
            name: name,
            paddings: 1,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Story(
                    image: 'assets/images/A_Tazaj.png',
                    icon: 'assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png',
                    text: name,
                    statuses: List<Map<String, dynamic>>.from(item["active_statuses"] ?? []),
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