import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Widget/ContentCard.dart';
import '../../RestaurantDetalis/RestaurantDetalis.dart';
import '../Home_riverpod.dart';
Map<String, dynamic> normalizeFavorite(dynamic fav) {
  if (fav is Map && fav["item"] != null) {
    return Map<String, dynamic>.from(fav["item"]);
  }
  return Map<String, dynamic>.from(fav ?? {});
}

class Favorites extends ConsumerWidget {
  final List<dynamic> favorite;

  const Favorites({super.key, required this.favorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = Sizes(context);
    final textLanguage = TextLanguage();
    return Visibility(
      visible: ref.read(Home_riverpod.notifier).favorite.isNotEmpty,
      child: SizedBox(
        height: sizes.GetHeight() * 33.5,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: favorite.length,
          itemBuilder: (context, i) {
            final raw = favorite[i];
            final item = normalizeFavorite(raw);
            final String image = item["image"] ?? "";
            final String businessName =
                item["business_name"] ?? item["name"] ?? "";
            return Padding(
              padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
              child: ContentCard(
                additionalInfo: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icon/site.svg",
                          height: sizes.GetHeight() * 1.7,
                        ),
                        SizedBox(width: sizes.GetWidth() * 0.4),
                        Text(
                          (item["distance"] ??
                              item["distance_km"] ??
                              "0 ${textLanguage.GetWord("كم")}")
                              .toString(),
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: sizes.GetWidth() * 1.5),
                        SvgPicture.asset(
                          "assets/icon/time.svg",
                          height: sizes.GetHeight() * 1.7,
                        ),
                        SizedBox(width: sizes.GetWidth() * 0.4),
                        Text(
                          (item["estimated_time"] ??
                              item["eta_minutes"] ??
                              "0 ${textLanguage.GetWord("دقائق")}")
                              .toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/evaluation.svg"),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(
                          "${item["reviews_count"] ?? 0} ${textLanguage.GetWord("التقييمات")}",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/Viewers.svg"),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(
                          "${item["visits_count"] ?? 0} ${textLanguage.GetWord("الزيارات")}",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                showIcon: true,
                imagePath: image,
                title: businessName,
                description: "",

                circleImagePath:
                "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",

                buttonText: textLanguage.GetWord("يكتشف"),

                onButtonTap: () {
                  final String type = (raw["type"] ?? "branch").toString();

                  int branchId = 0;
                  if (type == "branch") {
                    branchId = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
                  } else if (type == "menu_item") {
                    branchId = int.tryParse(item["branch_id"]?.toString() ?? "0") ?? 0;
                  }

                  if (branchId == 0) return;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => RestaurantDetalis(
                        title: businessName,
                        branchId:branchId,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },

                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 40,

                liked: raw["liked"] as bool? ?? true,

                onLikeTap: () {
                  final int itemId = int.tryParse(
                    item["id"]?.toString() ?? "0",
                  ) ??
                      0;

                  if (itemId == 0) return;

                  final String type =
                  (raw["type"] ?? "branch").toString();

                  ref.read(Home_riverpod.notifier).toggleLike(
                    itemId,
                    i,
                    context,
                    type: type,
                  );
                },

                menuItemId:
                int.tryParse(item["id"]?.toString() ?? "0") ?? 0,
              ),
            );
          },
        ),
      ),
    );
  }
}