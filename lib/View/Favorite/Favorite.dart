import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/WidgetAppBar.dart';
import 'Favorite_riverpod.dart';

class Favorite extends ConsumerStatefulWidget {
  const Favorite({super.key});

  @override
  ConsumerState<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends ConsumerState<Favorite> {
  @override
  void initState() {
    super.initState();
    // ✅ جلب المفضلة مرة واحدة عند الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(Favorite_riverpod.notifier).fetchFavorites(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();

    // ✅ مراقبة التحديثات
    ref.watch(Favorite_riverpod);
    final notifier = ref.read(Favorite_riverpod.notifier);

    // ✅ جلب المفضلة حسب النوع
    final favoriteBranches = notifier.favoriteBranches;
    final favoriteDishes = notifier.favoriteDishes;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
          child: Column(
            children: [
              buildCustomAppBar(context, showBackButton: false, "Favorite"),

              // ─── المطاعم المفضلة ───────────────────────────────
              favoriteBranches.isNotEmpty?Row(
                children: [
                  Text("Favorite restaurants"),
                ],
              ):SizedBox.shrink(),
              SizedBox(height: sizes.GetHeight() * 2),

              favoriteBranches.isEmpty
                  ? SizedBox.shrink()
                  : SizedBox(
                height: sizes.GetHeight() * 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteBranches.length,
                  itemBuilder: (context, i) {
                    final favorite = favoriteBranches[i];
                    final item = favorite['item'] ?? {};
                    final type = favorite['type'] ?? 'branch';

                    return Padding(
                      padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                      child: ContentCard(
                        additionalInfo: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/icon/site.svg", height: sizes.GetHeight() * 1.7),
                                SizedBox(width: sizes.GetWidth() * 0.4),
                                Text("1.2 KM", style: const TextStyle(fontSize: 10)),
                                SizedBox(width: sizes.GetWidth() * 1.5),
                                SvgPicture.asset("assets/icon/time.svg", height: sizes.GetHeight() * 1.7),
                                SizedBox(width: sizes.GetWidth() * 0.4),
                                Text("10 Mins", style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        showIcon: true,
                        imagePath: "assets/images/image6.png",
                        title: item["name"] ?? "",
                        description: item["description"] ?? "",
                        circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                        buttonText: textLanguage.GetWord("يكتشف"),
                        onButtonTap: () {},
                        width: sizes.GetWidth() * 50,
                        height: sizes.GetHeight() * 40,
                        liked: notifier.favoriteStatus[item['id']] ?? true,
                        onLikeTap: () {
                          notifier.toggleFavorite(item['id'], type, context);
                        },
                        menuItemId: item['id'],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: sizes.GetHeight() * 2),
              // ─── الأطباق المفضلة ───────────────────────────────
              favoriteDishes.isNotEmpty?Row(
                children: [
                  Text("Favorite dish"),
                ],
              ):SizedBox.shrink(),
              SizedBox(height: sizes.GetHeight() * 2),

              favoriteDishes.isEmpty
                  ? SizedBox.shrink()
                  : SizedBox(
                height: sizes.GetHeight() * 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteDishes.length,
                  itemBuilder: (context, i) {
                    final favorite = favoriteDishes[i];
                    final item = favorite['item'] ?? {};
                    final type = favorite['type'] ?? 'menu_item';

                    return Padding(
                      padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                      child: ContentCard(
                        additionalInfo: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/icon/LikePrice.svg", color: theme.GetColor("secondaryPrimary")),
                                SizedBox(width: sizes.GetWidth() * 1),
                                Text(item["price"]?.toString() ?? "0", style: TextStyle(color: theme.GetColor("secondaryPrimary"))),
                                SizedBox(width: sizes.GetWidth() * 1),
                                SvgPicture.asset("assets/icon/SAR.svg", color: theme.GetColor("secondaryPrimary")),
                              ],
                            ),
                          ],
                        ),
                        showIcon: true,
                        imagePath: "assets/images/image6.png",
                        title: item["name"] ?? "",
                        subTitle: item["business_name"] ?? "",
                        description: item["description"] ?? "",
                        circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                        buttonText: textLanguage.GetWord("اطلب الآن"),
                        onButtonTap: () {},
                        width: sizes.GetWidth() * 50,
                        height: sizes.GetHeight() * 40,
                        liked: notifier.favoriteStatus[item['id']] ?? true,
                        onLikeTap: () {
                          notifier.toggleFavorite(item['id'], type, context);
                        },
                        menuItemId: item['id'],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: sizes.GetHeight() * 10),
            ],
          ),
        ),
      ),
    );
  }
}