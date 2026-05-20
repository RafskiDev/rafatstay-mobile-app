import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/ContentCard.dart';
import '../../RestaurantDetalis/RestaurantDetalis.dart';
import '../../SeeAll/SeeAll.dart';
import '../../SeeAll/SeeAll_riverpod.dart';
import '../Home_riverpod.dart';
class Toppicks extends ConsumerWidget {
  final List<dynamic> homes;
  final List<dynamic> filters;
  const Toppicks({super.key, required this.homes, this.filters = const []});
  List<dynamic> get allItems {
    List<dynamic> result = [];
    for (var section in homes) {
      final items = section["items"];
      if (items is List) result.addAll(items);
    }
    return result;
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(Home_riverpod);
    final sizes = Sizes(context);
    final textLanguage = TextLanguage();
    final theme = Themes();
    final items = allItems; // ← استخدم هذا بدل homes مباشرة
    return  Visibility(
      visible:items
          .isNotEmpty,
      child: Container(
        decoration: BoxDecoration(
          color: theme.GetColor("primary"),
          borderRadius: BorderRadius.circular(25),
        ),
        height: sizes.GetHeight() * 50,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      // 1. الحصول على النص الكامل من المترجم
                      String fullText = textLanguage.GetWord("أفضل الخيارات بالقرب منك");

                      // 2. تقسيم النص إلى كلمات
                      List<String> words = fullText.split(' ');

                      // 3. استخراج آخر كلمة وبقية النص
                      String lastWord = words.isNotEmpty ? words.removeLast() : '';
                      String remainingText = words.join(' ') + (words.isNotEmpty ? ' ' : '');
                      return Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            fontWeight: FontWeight.w600, // SemiBold
                            height: 1.0,
                            color: Themes().GetColor("textPrimary"), // لون النص الأساسي
                          ),
                          children: [
                            TextSpan(text: remainingText), // الجزء الأول من الجملة
                            TextSpan(
                              text: lastWord,
                              style: const TextStyle(color: Colors.white), // آخر كلمة باللون الأبيض
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: ()async {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context,
                              animation1,
                              animation2) =>
                              SeeAll(
                                  title: textLanguage.GetWord(
                                      "أفضل الخيارات بالقرب منك"),
                                section: RestaurantSection.topPicks,sectionKey:ref.read(Home_riverpod.notifier).getTopPicksKey(),
                                filters: filters.isNotEmpty && filters[0]["sections"]?["filters"] is List
                                    ? (filters[0]["sections"]["filters"] as List)
                                    .whereType<Map<String, dynamic>>()
                                    .toList()
                                    : [],
                               ),
                          transitionDuration:
                          Duration.zero,
                          reverseTransitionDuration:
                          Duration.zero,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          textLanguage.GetWord("عرض الكل"),
                          style: TextStyle(
                            decoration: TextDecoration
                                .underline,
                            color: theme.GetColor(
                                "textPrimary"),
                          ),
                        ),
                        Transform(
                          alignment: Alignment.center,
                          transform:
                          Directionality.of(
                              context) ==
                              TextDirection.rtl
                              ? Matrix4.rotationY(
                              3.141592653589793)
                              : Matrix4.identity(),
                          child: SvgPicture.asset(
                            "assets/icon/Arrow_one.svg",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final favoriteStatus = ref
                      .watch(Home_riverpod.notifier)
                      .favoriteStatus;
                  return CarouselSlider.builder(
                    itemCount: items.length,
                    itemBuilder:(context, i, realIndex) {
                       final item = items[i] as Map<String, dynamic>;
                      final int itemId =
                      item["id"] is int ? item["id"] : int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
                      final bool isLiked =
                          favoriteStatus[itemId] ??
                              false;
                      return ContentCard(
                        imagePath:item["image"]??"",
                        title: item[
                        "business_name"] ??
                            "",
                        description:item["description"]??"لا يوجد بينات",
                        showIcon: true,//item["name"] ?? ""
                        circleImagePath:
                        "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                        buttonText:
                        textLanguage.GetWord(
                            "يكتشف"),
                        width:sizes.GetWidth() * 52,
                        height:sizes.GetHeight() * 40,
                        liked: isLiked,
                        additionalInfo:Column(
                          children: [
                            SizedBox(
                                height: sizes
                                    .GetHeight() *
                                    1),
                            Row(
                              children: [
                                SvgPicture.asset(
                                    "assets/icon/site.svg",
                                    height: sizes
                                        .GetHeight() *
                                        1.7),
                                SizedBox(
                                    width: sizes
                                        .GetWidth() *
                                        0.4),
                                Flexible(
                                    child: Text(
                                      (item["distance_km"] ?? "0 KM").toString(),
                                      style: const TextStyle(
                                          fontSize:
                                          10),
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                    )),
                                SizedBox(
                                    width: sizes
                                        .GetWidth() *
                                        1.5),
                                SvgPicture.asset(
                                    "assets/icon/time.svg",
                                    height: sizes
                                        .GetHeight() *
                                        1.7),
                                SizedBox(
                                    width: sizes
                                        .GetWidth() *
                                        0.4),
                                Text(
                                  (item["eta_minutes"] ?? "0 Mins").toString(),
                                  style: const TextStyle(
                                      fontSize: 10),
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                ),
                              ],
                            ),
                            SizedBox(height: sizes.GetHeight() * 3),
                          ],
                        ),
                        onLikeTap: () {
                          ref
                              .read(Home_riverpod
                              .notifier)
                              .toggleLike(
                              itemId,
                              i,
                              context);
                        },
                        onButtonTap: ()async {
                          final branchId = (items[i] as Map<String, dynamic>)["id"];
                           await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (_, __, ___) =>
                                  RestaurantDetalis(
                                      title: (item["business_name"] ?? "").toString(),
                                    branchId: branchId,
                                  ),
                              transitionDuration:
                              Duration.zero,
                              reverseTransitionDuration:
                              Duration.zero,
                            ),
                          );
                           if(!context.mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(Home_riverpod.notifier).changeCardsCarousel(0);
                          });


                        },
                        menuItemId: itemId,
                      );
                    },
                    options: CarouselOptions(
                      height:
                      sizes.GetHeight() * 38,
                      viewportFraction: 0.6,
                      enlargeCenterPage: true,
                      onPageChanged: (index,
                          reason) {
                        ref
                            .read(Home_riverpod
                            .notifier)
                            .changeCardsCarousel(
                            index);
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                items.length,
                    (i) {
                  final bool isCurrent = ref
                      .watch(Home_riverpod.notifier)
                      .cardsCarouselIndex ==
                      i;
                  return Container(
                    width: isCurrent
                        ? sizes.GetWidth() * 2 * 2.5
                        : sizes.GetWidth() * 2,
                    height: sizes.GetHeight() * 1,
                    margin: EdgeInsets.symmetric(
                        horizontal:
                        sizes.GetWidth() * 1),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme
                          .GetColor("textPrimary")
                          : Color(0xFFD3E9F8),
                      borderRadius:
                      BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: sizes.GetHeight() * 1),
          ],
        ),
      ),
    );
  }
}
