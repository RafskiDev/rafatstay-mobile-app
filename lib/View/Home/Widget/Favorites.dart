import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/CategoryItemCard.dart';
import '../../../Widget/ContentCard.dart';
import '../../RestaurantDetalis/RestaurantDetalis.dart';
import '../../Story/Story.dart';
import '../Home_riverpod.dart';
class Favorites extends ConsumerWidget {
  final List<dynamic> favorite;
   Favorites({super.key, required this.favorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = Sizes(context);
    final textLanguage = TextLanguage();
    final theme = Themes();
    return  Visibility(
      visible: ref
          .read(Home_riverpod.notifier)
          .favorite.isNotEmpty,
      child: SizedBox(
        height: sizes.GetHeight() * 33.5,
        child:ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: favorite.length,
          itemBuilder: (context, i) {
            final favorites = favorite[i];
            /*
            final String type = favorites["type"]?.toString() ?? "branch";
            final String title = type == "menu_item"
                ? (favorites["item"]?["name"] ??
                favorites["item"]?["business_name"] ?? "").toString()
                : (favorites["item"]?["business_name"] ??
                favorites["item"]?["name"] ?? "").toString();
             */
            final String favImage = favorites["item"]["image"].toString();
            final business_name=favorites["item"]?["business_name"]??"";
            return Padding(
              padding: EdgeInsets.only(
                  right: sizes.GetWidth() * 1),
              child: ContentCard(
                additionalInfo: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                            "assets/icon/site.svg",
                            height:
                            sizes.GetHeight() *
                                1.7),
                        SizedBox(
                            width:
                            sizes.GetWidth() *
                                0.4),
                        Flexible(
                          child: Text(
                            (favorites["distance_km"] ?? "0 KM").toString(),
                            style: const TextStyle(
                                fontSize: 10),
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                            width:
                            sizes.GetWidth() *
                                1.5),
                        SvgPicture.asset(
                            "assets/icon/time.svg",
                            height:
                            sizes.GetHeight() *
                                1.7),
                        SizedBox(
                            width:
                            sizes.GetWidth() *
                                0.4),
                        Text(
                          (favorites["eta_minutes"] ?? "0 Mins").toString(),
                          style: const TextStyle(
                              fontSize: 10),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                            "assets/icon/evaluation.svg"),
                        SizedBox(
                            width:
                            sizes.GetWidth() * 1),
                        Text(
                            "${favorites["reviews_count"] ?? "0"} reviews",
                            style: TextStyle(
                                fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                            "assets/icon/Viewers.svg"),
                        SizedBox(
                            width:
                            sizes.GetWidth() * 1),
                        Text(
                            "${favorites["visits_count"] ?? "0"} visits",
                            style: TextStyle(
                                fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                showIcon: true,
                imagePath: favImage,
                title:business_name,
                description:"",
                circleImagePath:
                "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                buttonText:
                textLanguage.GetWord("يكتشف"),
                onButtonTap: () {
                  final itemData = favorites["item"] as Map<String, dynamic>?;
                  final int branchId = itemData?["branch_id"] ?? 0;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context,
                          animation1,
                          animation2) =>
                          RestaurantDetalis(
                            title:favorites["item"]["business_name"]??"",
                            branchId: branchId,
                          ),
                      transitionDuration:
                      Duration.zero,
                      reverseTransitionDuration:
                      Duration.zero,
                    ),
                  );
                },
                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 40,
                liked:
                favorites["liked"] as bool? ??
                    true,
                onLikeTap: () {
                  final int itemId = int.tryParse(
                      favorites["item"]?["id"]?.toString() ?? "0"
                  ) ?? 0;
                  if (itemId == 0) return;
                  final String type = (favorites["type"] ?? "branch").toString();
                  ref.read(Home_riverpod.notifier).toggleLike(
                    itemId,
                    i,
                    context,
                    type: type,
                  );
                },
                menuItemId: int.tryParse(favorites["item"]?["id"]?.toString() ?? "0") ?? 0,
              ),
            );
          },
        ),
      ),
    );
  }
}
