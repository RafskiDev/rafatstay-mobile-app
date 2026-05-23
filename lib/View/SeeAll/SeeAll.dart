import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CategoryItemCard.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/CustomCarousel.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetTextField.dart';
import '../OffersDetails/OffersDetails.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import 'SeeAll_riverpod.dart';

class SeeAll extends ConsumerStatefulWidget {
  final String title;
  final RestaurantSection section;
  final RestaurantFilter filter;
  final String sectionKey;
  final List<Map<String, dynamic>> filters;

  const SeeAll({
    required this.title,
    required this.section,
    this.filter = RestaurantFilter.all,
    this.sectionKey = "",
    this.filters = const [],
    Key? key,
  });

  @override
  ConsumerState<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends ConsumerState<SeeAll> {
  late ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(SeeAll_riverpod.notifier).resetAll();
      ref.read(SeeAll_riverpod.notifier).fetchSection(
        context,
        section: widget.section,
        filter: widget.filter,
        key: widget.sectionKey,
      );
    });
  }

  void _onScroll() {
    if (!mounted) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      final notifier = ref.read(SeeAll_riverpod.notifier);

      if (notifier.getCurrentHasMore() && !notifier.isFetchingMore) {
        notifier.loadMoreCurrent(context, widget.sectionKey);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Themes();
    final textLanguage = TextLanguage();
    final sizes = Sizes(context);
    final notifier = ref.watch(SeeAll_riverpod.notifier);
    ref.watch(SeeAll_riverpod);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(SeeAll_riverpod.notifier);
      if (notifier.filtersList.isEmpty && widget.filters.isNotEmpty) {
        notifier.filtersList = widget.filters;
      }
    });

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar: buildCustomAppBar(context, widget.title),
      body: ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading && notifier.currentPage == 1 && !notifier.isSearching) return showLoading();
          return Column(
            children: [
              if (widget.section != RestaurantSection.offers && widget.section != RestaurantSection.favorites)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
                  child: WidgetTextField(
                    Controller: notifier.searchController,
                    HintText: textLanguage.GetWord("بحث"),
                    iconData: "assets/icon/Search.svg",
                    Horizontal: sizes.GetWidth() * 2,
                    focusNode: notifier.searchNode,
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (!mounted) return;
                        if (value.trim().isEmpty) {
                          ref.read(SeeAll_riverpod.notifier).resetSearch();
                          ref.read(SeeAll_riverpod.notifier).fetchSection(
                            context,
                            section: widget.section,
                            filter: widget.filter,
                            key: widget.sectionKey,
                          );
                        } else {
                          ref.read(SeeAll_riverpod.notifier).search(context);
                        }
                      });
                    },
                  ),
                ),
              SizedBox(height: sizes.GetHeight() * 2),
              widget.filters.isNotEmpty ? SizedBox(
                height: sizes.GetHeight() * 5,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
                  itemCount: widget.filters.length,
                  itemBuilder: (context, index) {
                    final filter = widget.filters[index];
                    final isSelected = notifier.selectedFilterIndex == index;
                    final label = filter["label_en"] ?? filter["label"] ?? filter["key"] ?? "";
                    return GestureDetector(
                      onTap: (){
                        final filter = widget.filters[index];
                        ref.read(SeeAll_riverpod.notifier)
                            .selectFilter(context, index, widget.sectionKey, filter);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sizes.GetWidth() * 4,
                          vertical: sizes.GetHeight() * 1,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFA56C0B) : Color(0xFFF4EBD7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? Color(0xFFA56C0B) : Color(0xFFD4B896),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Color(0xFFA56C0B),
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ) : const SizedBox(),
              if (widget.filters.isNotEmpty)
                SizedBox(height: sizes.GetHeight() * 2),
              Expanded(
                child: _buildSectionContent(notifier, sizes, theme, textLanguage),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionContent(
      PageNotifier notifier,
      Sizes sizes,
      Themes theme,
      TextLanguage textLanguage,
      ) {
    final currentList = notifier.getCurrentList();

    // تم تعديل التحقق هنا ليعتمد على الـ state الفعلي للتحميل من الـ notifier
    final bool isLoaderVisible = notifier.isFetchingMore;

    switch (widget.section) {
    // ─── Offers ───────────────────────────────────────────────────────────
      case RestaurantSection.offers:
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final offer = currentList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(
                      vertical: sizes.GetHeight() * 1,
                      horizontal: sizes.GetWidth() * 2,
                    ),
                    height: sizes.GetHeight() * 18,
                    child: CarouselTextImageItem(
                      item: {
                        'leftColor': const Color(0xFFA56C0B),
                        'rightColor': const Color(0xFFFFF8DC),
                        'title': offer['name'] ?? '',
                        'description': offer['description'] ?? '',
                        'image': 'assets/images/ChickenDish.png',
                      },
                      height: sizes.GetHeight() * 18,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OffersDetails(
                              title: textLanguage.GetWord("تفاصيل العروض"), offerId: 3,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // ✅ هنا يظهر مؤشر التحميل في المنتصف تماماً أسفل القائمة
            if (isLoaderVisible)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: showLoading()),
                ),
              ),
            SizedBox(height: sizes.GetHeight() * 3),
          ],
        );

    // ─── Top Picks ────────────────────────────────────────────────────────
      case RestaurantSection.topPicks:
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(sizes.GetWidth() * 2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: Sizes(context).GetHeight() * 36,
                  crossAxisSpacing: Sizes(context).GetWidth() * 1,
                  mainAxisSpacing: Sizes(context).GetHeight() * 1,
                ),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final item = currentList[index];
                  return ContentCard(
                    showIcon: true,
                    imagePath: item["image"] ?? "",
                    title: item["business_name"] ?? "",
                    description: item["name"] ?? "",
                    circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                    buttonText: textLanguage.GetWord("اطلب الآن"),
                    additionalInfo: Column(
                      children: [
                        SizedBox(height: sizes.GetHeight() * 1),
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/site.svg", height: sizes.GetHeight() * 1.7),
                            SizedBox(width: sizes.GetWidth() * 0.4),
                            Flexible(
                                child: Text(
                                  (item["distance_km"] ?? "0 KM").toString(),
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                )),
                            SizedBox(width: sizes.GetWidth() * 1.5),
                            SvgPicture.asset("assets/icon/time.svg", height: sizes.GetHeight() * 1.7),
                            SizedBox(width: sizes.GetWidth() * 0.4),
                            Text(
                              (item["eta_minutes"] ?? "0 Mins").toString(),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                    onButtonTap: () async {
                      final branchId = item["id"];
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => RestaurantDetalis(
                            title: (item["business_name"] ?? "").toString(),
                            branchId: branchId,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    width: sizes.GetWidth() * 50,
                    height: sizes.GetHeight() * 40,
                    liked: notifier.favoriteStatus[item['id']] ?? false,
                    onLikeTap: () {
                      notifier.toggleFavorite(item['id'], context, "branch");
                    },
                    menuItemId: item["id"],
                  );
                },
              ),
            ),
            // ✅ تم إخراجه من الـ GridView ليصبح في السطر الأخير ممتد في السنتر تماماً
            if (isLoaderVisible)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: showLoading()),
                ),
              ),
            SizedBox(height: sizes.GetHeight() * 3),
          ],
        );

    // ─── Favorites ────────────────────────────────────────────────────────
      case RestaurantSection.favorites:
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(sizes.GetWidth() * 2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: Sizes(context).GetHeight() * 40,
                  crossAxisSpacing: Sizes(context).GetWidth() * 1,
                  mainAxisSpacing: Sizes(context).GetHeight() * 1,
                ),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final favorite = currentList[index];
                  final item = favorite["item"] ?? {};
                  return ContentCard(
                    showIcon: true,
                    imagePath: item["image"] ?? "",
                    title: item["business_name"] ?? "",
                    description: "${item["description"] ?? "لا يوجد بيانات"}",
                    circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                    buttonText: textLanguage.GetWord("يكتشف"),
                    onButtonTap: () async {
                      final branchId = item["id"];
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => RestaurantDetalis(
                            title: (item["business_name"] ?? "").toString(),
                            branchId: branchId,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    width: sizes.GetWidth() * 50,
                    height: sizes.GetHeight() * 40,
                    liked: notifier.favoriteStatus[item['id']] ?? false,
                    onLikeTap: () {
                      notifier.toggleFavorite(item['id'], context, favorite["type"]);
                    },
                    additionalInfo: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/site.svg", height: sizes.GetHeight() * 1.7),
                            SizedBox(width: sizes.GetWidth() * 0.4),
                            Flexible(
                              child: Text(
                                (item["distance_km"] ?? "0 KM").toString(),
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: sizes.GetWidth() * 1.5),
                            SvgPicture.asset("assets/icon/time.svg", height: sizes.GetHeight() * 1.7),
                            SizedBox(width: sizes.GetWidth() * 0.4),
                            Text(
                              (item["eta_minutes"] ?? "0 Mins").toString(),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/evaluation.svg"),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text("${item["reviews_count"] ?? "0"} reviews", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/Viewers.svg"),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text("${item["visits_count"] ?? "0"} visits", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    menuItemId: item["id"],
                  );
                },
              ),
            ),
            // ✅ مؤشر تحميل نظيف في السنتر تماماً
            if (isLoaderVisible)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: showLoading()),
                ),
              ),
            SizedBox(height: sizes.GetHeight() * 3),
          ],
        );

    // ─── Dish of the Day ──────────────────────────────────────────────────
      case RestaurantSection.dishOfTheDay:
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(sizes.GetWidth() * 2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: Sizes(context).GetHeight() * 36.2,
                  crossAxisSpacing: Sizes(context).GetWidth() * 1,
                  mainAxisSpacing: Sizes(context).GetHeight() * 1,
                ),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final dish = currentList[index];
                  final String dishPrice = dish["price"]?.toString() ?? "0";
                  return ContentCard(
                    showIcon: true,
                    imagePath: dish["image"] ?? "",
                    title: dish["business_name"]?.toString() ?? "",
                    description: dish["description"]?.toString() ?? "لا يوجد بينات",
                    circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                    buttonText: textLanguage.GetWord("يكتشف"),
                    onButtonTap: ()async {
                      final branchId = dish["id"];
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => RestaurantDetalis(
                            title: (dish["business_name"] ?? "").toString(),
                            branchId: branchId,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    width: sizes.GetWidth() * 50,
                    height: sizes.GetHeight() * 40,
                    liked: notifier.favoriteStatus[dish['id']] ?? false,
                    additionalInfo: Row(children: [
                      SvgPicture.asset("assets/icon/LikePrice.svg"),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(dishPrice, style: TextStyle(color: theme.GetColor("secondaryPrimary"))),
                      SizedBox(width: sizes.GetWidth() * 1),
                      SvgPicture.asset("assets/icon/SAR.svg", color: theme.GetColor("secondaryPrimary")),
                    ]),
                    onLikeTap: () {
                      notifier.toggleFavorite(dish['id'], context, "menu_item");
                    },
                    menuItemId: dish["id"],
                  );
                },
              ),
            ),
            // ✅ مؤشر تحميل نظيف في السنتر تماماً
            if (isLoaderVisible)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: showLoading()),
                ),
              ),
            SizedBox(height: sizes.GetHeight() * 3),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}