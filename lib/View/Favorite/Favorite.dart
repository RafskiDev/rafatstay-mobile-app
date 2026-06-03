import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/WidgetAppBar.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import '../Story/Story.dart';
import 'Favorite_riverpod.dart';
import 'Widget/InterestCard.dart';

class Favorite extends ConsumerStatefulWidget {
  const Favorite({super.key});

  @override
  ConsumerState<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends ConsumerState<Favorite> {
  // ✅ إضافة متغير للتحكم في حالة التحميل
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ جلب المفضلة الكاملة وتغيير حالة التحميل عند الانتهاء
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });

      // انتظار جلب البيانات من السيرفر
      await ref.read(Favorite_riverpod.notifier).fetchFavorites(context);

      // إيقاف التحميل بعد وصول البيانات
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();

    ref.watch(Favorite_riverpod);
    final notifier = ref.read(Favorite_riverpod.notifier);

    final favoriteBranches = notifier.favoriteBranches;
    final favoriteDishes = notifier.favoriteDishes;
    final branchesWithStories = notifier.statusBranches;
    final interestBranches = notifier.interestBranches;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
          child: Column(
            children: [
              buildCustomAppBar(context, showBackButton: false, textLanguage.GetWord("مفضل")),
              // ✅ عرض دائرة التحميل إذا كانت البيانات قيد الجلب
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: sizes.GetHeight() * 30),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.GetColor("primary"),
                    ),
                  ),
                )
              // ✅ عرض المحتوى عند اكتمال التحميل
              else ...[
                // ─── المطاعم المفضلة ───────────────────────────────
                if (favoriteBranches.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(textLanguage.GetWord("المطاعم المفضلة"),
                          style: TextStyle(
                              color: theme.GetColor("textPrimary"),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  SizedBox(
                    height: sizes.GetHeight() * 41,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteBranches.length,
                      itemBuilder: (context, i) {
                        final item = favoriteBranches[i];
                        final int itemId = item['item_id'] ?? 0;
                        final type = item['type'] ?? 'branch';
                        final visits = item["visits_label"]?.toString().split(' ').first ?? "0";
                        print(item);
                        return Padding(
                          padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                          child: ContentCard(
                            additionalInfo: Column(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset("assets/icon/site.svg", height: sizes.GetHeight() * 1.7),
                                    SizedBox(width: sizes.GetWidth() * 0.4),
                                    Text("${item["distance_km"]?.toString() ?? "0"} ${textLanguage.GetWord("كم")}",
                                        style: const TextStyle(fontSize: 10)),
                                    SizedBox(width: sizes.GetWidth() * 1.5),
                                    SvgPicture.asset("assets/icon/time.svg", height: sizes.GetHeight() * 1.7),
                                    SizedBox(width: sizes.GetWidth() * 0.4),
                                    Text("${item["eta_minutes"]?.toString() ?? "0"} ${textLanguage.GetWord("دقائق")}",
                                        style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                                SizedBox(height: sizes.GetHeight() * 1),
                                Row(
                                  children: [
                                    SvgPicture.asset("assets/icon/Viewers.svg"),
                                    SizedBox(width: sizes.GetWidth() * 0.4),
                                    Text("${item["rating"]?.toString() ?? "0"} (${item["reviews_count"]?.toString() ?? "0"} ${textLanguage.GetWord("التقييمات")})", style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                                SizedBox(height: sizes.GetHeight() * 1),
                                Row(
                                  children: [
                                    SvgPicture.asset("assets/icon/evaluation.svg"),
                                    SizedBox(width: sizes.GetWidth() * 0.4),
                                    Text(visits, style: const TextStyle(fontSize: 10)),
                                    SizedBox(width: sizes.GetWidth() * 0.4),
                                    Text(textLanguage.GetWord("يزور"), style:  TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                            showIcon: true,
                            imagePath: item["image"] ?? "",
                            title: item["business_name"] ?? "",
                            description: item["description"] ?? " ",
                            circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                            buttonText:textLanguage.GetWord("يكتشف"),
                            onButtonTap: () {
                              final int branchId = item["item_id"] ?? 0;
                              if (branchId == 0) return;
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => RestaurantDetalis(
                                    title: item["business_name"] ?? "",
                                    branchId: branchId,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            width: sizes.GetWidth() * 50,
                            height: sizes.GetHeight() * 40,
                            liked: notifier.favoriteStatus[itemId] ?? true,
                            onLikeTap: () {
                              notifier.toggleFavorite(itemId, type, context);
                            },
                            menuItemId: itemId,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                ],

                // ─── الأطباق المفضلة ───────────────────────────────
                if (favoriteDishes.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(textLanguage.GetWord("الطبق المفضل"),
                          style: TextStyle(
                              color: theme.GetColor("textPrimary"),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  SizedBox(
                    height: sizes.GetHeight() * 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteDishes.length,
                      itemBuilder: (context, i) {
                        final item = favoriteDishes[i];
                        final int itemId = item['item_id'] ?? 0;
                        final type = item['type'] ?? 'menu_item';
                        return Padding(
                          padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                          child: ContentCard(
                            additionalInfo: Column(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset("assets/icon/LikePrice.svg", color: theme.GetColor("secondaryPrimary")),
                                    SizedBox(width: sizes.GetWidth() * 1),
                                    Text(item["display_price"]?.toString() ?? item["price"]?.toString() ?? "0",
                                        style: TextStyle(color: theme.GetColor("secondaryPrimary"))),
                                    SizedBox(width: sizes.GetWidth() * 1),
                                    Text(item["currency"] ?? "SAR", style: TextStyle(color: theme.GetColor("secondaryPrimary"), fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                            showIcon: true,
                            imagePath: item["image"] ?? "",
                            title: item["business_name"] ?? "",
                            subTitle: item["name"] ?? "",
                            description: item["description"] ?? "",
                            circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                            buttonText:textLanguage.GetWord("اطلب الآن"),
                            onButtonTap: () {
                              final int branchId = item["branch_id"] ?? 0;
                              if (branchId == 0) return;
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => RestaurantDetalis(
                                    title: item["business_name"] ?? "",
                                    branchId: branchId,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            width: sizes.GetWidth() * 50,
                            height: sizes.GetHeight() * 40,
                            liked: notifier.favoriteStatus[itemId] ?? true,
                            onLikeTap: () {
                              notifier.toggleFavorite(itemId, type, context);
                            },
                            menuItemId: itemId,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                ],

                // ─── قسم الحالات (Status) ───────────────────────────
                if (branchesWithStories.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(textLanguage.GetWord("حالة"), style: TextStyle(color: theme.GetColor("textPrimary"), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 1.5),
                  SizedBox(
                    height: sizes.GetHeight() * 11,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: branchesWithStories.length,
                      itemBuilder: (context, i) {
                        final statusItem = branchesWithStories[i];
                        final String logoUrl = statusItem["logo_url"] ?? "";
                        final String businessName = statusItem["business_name"] ?? "";
                        final String statusEndpoint = statusItem["cta"]?["endpoint"] ?? "";

                        return GestureDetector(
                          onTap: () {
                            if (statusEndpoint.isEmpty) return;
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => Story(
                                  branchData: statusItem,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: sizes.GetWidth() * 4),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.GetColor("primary"),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: sizes.GetHeight() * 3.5,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
                                    child: logoUrl.isEmpty ? const Icon(Icons.store, color: Colors.grey) : null,
                                  ),
                                ),
                                SizedBox(height: sizes.GetHeight() * 0.5),
                                SizedBox(
                                  width: sizes.GetWidth() * 18,
                                  child: Text(
                                    businessName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.GetColor("textPrimary"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                ],

                // ─── قسم الاهتمامات (Interests) ─────────────────────────
                if (interestBranches.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        textLanguage.GetWord("الاهتمامات"),
                        style: TextStyle(
                            color: theme.GetColor("textPrimary"),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 1.5),
                  SizedBox(
                    height: sizes.GetHeight() * 11,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: interestBranches.length,
                      itemBuilder: (context, i) {
                        final item = interestBranches[i];

                        final String logoUrl = item["logo_url"] ?? "";
                        final String businessName = item["business_name"] ?? "";
                        final String branchName = item["name"] ?? "";

                        return Padding(
                          padding: EdgeInsets.only(
                            right: Localizations.localeOf(context).languageCode == 'ar' ? 0 : sizes.GetWidth() * 3,
                            left: Localizations.localeOf(context).languageCode == 'ar' ? sizes.GetWidth() * 3 : 0,
                          ),
                          child: InterestCard(
                            width: sizes.GetWidth() * 95,
                            height: sizes.GetHeight() * 10,
                            logoUrl: logoUrl,
                            businessName: businessName,
                            branchName: branchName,
                            onTap: () {
                              final int branchId = item["branch_id"] ?? 0;
                              if (branchId == 0) return;
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => RestaurantDetalis(
                                    title: businessName,
                                    branchId: branchId,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // ✅ رسالة تظهر في حال كانت كل القوائم فارغة بعد الانتهاء من التحميل
                if (favoriteBranches.isEmpty && favoriteDishes.isEmpty && branchesWithStories.isEmpty && interestBranches.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: sizes.GetHeight() * 35),
                    child: Center(
                      child: Text(
                        textLanguage.GetWord("لا توجد مفضلات حالياً"),
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),

                SizedBox(height: sizes.GetHeight() * 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}