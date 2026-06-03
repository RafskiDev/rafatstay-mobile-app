import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Widget/CategoryItemCard.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/CustomCarousel.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../Filters/Filters.dart';
import '../OffersDetails/OffersDetails.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import '../Search/Search.dart';
import '../SeeAll/SeeAll.dart';
import '../SeeAll/SeeAll_riverpod.dart';
import '../notifications/notifications.dart';
import 'Home_riverpod.dart';
import 'Widget/Events.dart';
import 'Widget/Favorites.dart';
import 'Widget/LanguageDropdown.dart';
import 'Widget/Status.dart';
import 'Widget/TopPicks.dart';

extension SafeTextLanguage on TextLanguage {
  String w(String key) => GetWord(key) ?? key;
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    if (mounted) {
      ref.read(Home_riverpod.notifier).restaurants(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Home_riverpod);
    final sizes           = Sizes(context);
    final textLanguage    = TextLanguage();
    final theme           = Themes();
    final favorite        = ref.watch(Home_riverpod.notifier).favorite;
    final dish            = ref.watch(Home_riverpod.notifier).dish;
    final events          = ref.watch(Home_riverpod.notifier).events;
    final selectedIndex   = ref.watch(Home_riverpod.notifier).selectedIndex;
    final homes           = ref.read(Home_riverpod.notifier).home;
    final box             = ref.watch(Home_riverpod.notifier).box;
    final event           = ref.watch(Home_riverpod.notifier).event;
    final offers          = ref.watch(Home_riverpod.notifier).offers;
    final closestCheapest = ref.watch(Home_riverpod.notifier).closestCheapest;
    final mostOrdered     = ref.watch(Home_riverpod.notifier).mostOrdered;
    final statuses        = ref.watch(Home_riverpod.notifier).statuses;
  //  final String statusKey = ref.read(Home_riverpod.notifier).getStatusKey();
    final user = ref.read(Home_riverpod.notifier).box.read("user");
    final avatarPath = user?["avatar_url"];
    final avatarUrl = avatarPath != null
        ? "$avatarPath"
        : null;
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: sizes.GetHeight() * 1),
                // ─── Header ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: sizes.GetWidth() * 60,
                      padding: EdgeInsets.all(sizes.GetWidth() * 0.5),
                      decoration: BoxDecoration(
                        color: Themes().GetColor("background"),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Themes().GetColor("textPrimary").withOpacity(0.2),
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child:avatarUrl!=null? Image.network(
                              avatarUrl,
                              width: sizes.GetHeight() * 5,
                              height: sizes.GetHeight() * 5,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                                width: sizes.GetHeight() * 5,
                                height: sizes.GetHeight() * 5,
                                fit: BoxFit.cover,
                              ),
                            ):Image.asset(
                              "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                              width: sizes.GetHeight() * 5,
                              height: sizes.GetHeight() * 5,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(box.read("user")?["full_name"] ?? ""),
                              Text(textLanguage.w("يسعدنا رؤيتك")),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _iconButton("assets/icon/Settings.svg",iconColor:ref.read(Home_riverpod.notifier).showLanguage?theme.GetColor("white"):theme.GetColor("textPrimary"),sizes,backgroundColor:ref.read(Home_riverpod.notifier).showLanguage?theme.GetColor("primary"):theme.GetColor("backgroundOffWhite"), onTap: () {
                          ref.read(Home_riverpod.notifier).toggleLanguage();
                        }),
                        SizedBox(width: sizes.GetWidth() * 2),
                        _iconButton("assets/icon/notifications.svg",iconColor:theme.GetColor("textPrimary"),sizes,backgroundColor:theme.GetColor("backgroundOffWhite"), onTap: () {
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (_, __, ___) => notifications(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ));
                        }),
                      ],
                    ),
                  ],
                ),
                if(ref.read(Home_riverpod.notifier).showLanguage)
                LanguageDropdown(ref:ref),
                if(ref.read(Home_riverpod.notifier).showLanguage==false)
                SizedBox(height: sizes.GetHeight() * 2),
                // ─── Tabs (Restaurants / Lounges / Cafes / Order to Go) ───
                Row(
                  children: [
                    Flexible(
                      child: SizedBox(
                        height: sizes.GetHeight() * 10,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 0.5),
                              child: GestureDetector(
                                onTap: () {
                                  ref.read(Home_riverpod.notifier).select(index);
                                  ref.read(Home_riverpod.notifier).restaurants(context);
                                },
                                child: IconBox(
                                  iconKey: events[index]["key"].toString(),
                                  width: sizes.GetWidth() * 28,
                                  height: sizes.GetWidth() * 10,
                                  icon: events[index]["imagePath"].toString(),
                                  isSelected: selectedIndex == index,
                                  title: events[index]["title"].toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: LoadingService.isLoading,
                  builder: (context, isLoading, child) {
                    return isLoading
                        ? SizedBox(
                      height: sizes.GetHeight() * 60,
                      child: Center(
                        child: showLoading(),
                         ),
                        )
                        : Column(
                      children: [
                        SizedBox(height: sizes.GetHeight() * 2),

                        // ─── Filters ─────────────────────────────────
                        Visibility(
                          visible: homes.isNotEmpty && homes[0]["sections"]?["filters"] != null,
                          child: SizedBox(
                            height: sizes.GetHeight() * 5,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: homes.isNotEmpty && homes[0]["sections"]?["filters"] != null
                                  ? homes[0]["sections"]["filters"].length
                                  : 0,
                              itemBuilder: (context, index) {
                                final language = ref.read(Home_riverpod.notifier).box.read("Language");
                                final filterItem = homes[0]["sections"]["filters"][index];
                               // final String category = (filterItem["label_en"] ?? filterItem["label"] ?? filterItem["key"] ?? "").toString();
                                final String category = language == 0
                                    ? (filterItem["label_en"] ?? filterItem["key"] ?? "").toString()
                                    : (filterItem["label"] ?? filterItem["label_en"] ?? filterItem["key"] ?? "").toString();
                                final String filterKey = (filterItem["key"] ?? category).toString().toLowerCase().replaceAll(" ", "_");
                                final isSelected = ref.watch(Home_riverpod.notifier).selectedCategoryIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    ref.read(Home_riverpod.notifier).selectCategory(index);
                                    if (index == 0) {
                                      ref.read(Home_riverpod.notifier).filters.clear();
                                      ref.read(Home_riverpod.notifier).ref.notifyListeners();
                                    } else {
                                      ref.read(Home_riverpod.notifier).filter(context, filter: filterKey);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: sizes.GetWidth() * 4,
                                      vertical: sizes.GetHeight() * 1,
                                    ),
                                    margin: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 1.5),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFFA56C0B) : Color(0xFFF4EBD7),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected ? Color(0xFFA56C0B) : Color(0xFFD4B896),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      category,
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
                          ),
                        ),
                        homes.isNotEmpty && homes[0]["sections"]?["filters"] != null? SizedBox(height: sizes.GetHeight() * 2):SizedBox.shrink(),
                        // ─── Search ───────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: WidgetTextField(
                                borderColor: theme.GetColor("primary"),
                                Controller: ref.read(Home_riverpod.notifier).searchController,
                                hintTextColor: theme.GetColor("textPrimary"),
                                HintText: textLanguage.w("بحث"),
                                iconData: "assets/icon/Search.svg",
                                iconColor: theme.GetColor("textPrimary"),
                                Horizontal: sizes.GetWidth() * 2,
                                focusNode: ref.read(Home_riverpod.notifier).searchNode,
                                isReadOnly: true,
                                onTap: () async {
                                  final res = await Navigator.push(context, PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => Search(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ));
                                  if (res != null) ref.read(Home_riverpod.notifier).restaurants(context);
                                },
                              ),
                            ),
                            SizedBox(width: sizes.GetWidth() * 2),
                            CircularButton(
                              size: Sizes(context).GetWidth() * 13,
                              onTap: ()async {
                                final res = await Navigator.push(context, PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => Filters(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ));
                                if (res != null) ref.read(Home_riverpod.notifier).restaurants(context,showLoader: false);
                              },
                              child: SvgPicture.asset("assets/icon/Filters.svg"),
                              borderColor: theme.GetColor("primary"),
                            ),
                          ],
                        ),
                        // ─── Events (مطاعم فقط) ───────────────────────
                        if (selectedIndex == 0) ...[
                          if (event.isNotEmpty) SizedBox(height: sizes.GetHeight() * 2),
                          Events(events: event),
                        ],

                        // ─── Status ───────────────────────────────────
                        if(statuses.isNotEmpty) ...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          _sectionHeader(
                            title: _getStatusTitle(homes),
                            onSeeAll: () {
                              Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SeeAll(
                                  title: textLanguage.w("حالة المطاعم"),
                                  section: RestaurantSection.status,
                                  sectionKey: ref.read(Home_riverpod.notifier).getTopPicksKey(),
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));
                            },
                            sizes: sizes, theme: theme, textLanguage: textLanguage,
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          Row(children: [Expanded(child: Status())]),
                        ],
                        statuses.isEmpty?SizedBox(height: sizes.GetHeight() * 2):SizedBox.shrink(),

                        // ─── Offers ───────────────────────────────────
                        if (offers.isNotEmpty) ...[
                          _sectionHeader(
                            title: textLanguage.w("عروض اليوم"),
                            onSeeAll: () {
                               Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SeeAll(
                                  title: textLanguage.w("عروض اليوم"),
                                  section: RestaurantSection.offers,
                                  sectionKey: ref.read(Home_riverpod.notifier).getTopPicksKey(),
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));
                            },
                            sizes: sizes, theme: theme, textLanguage: textLanguage,
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          CustomCarousel(
                            items: offers,
                            currentIndex: ref.watch(Home_riverpod.notifier).mainCarouselIndex,
                            onTap: () {
                              final currentIndex = ref.watch(Home_riverpod.notifier).mainCarouselIndex;

                              final selectedOffer = offers[currentIndex];
                              final int offerId = int.tryParse(selectedOffer["id"]?.toString() ?? "0") ?? 0;
                           //  print(selectedOffer);
                              Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (_, __, ___) => OffersDetails(
                                  title: textLanguage.w("تفاصيل العروض"),
                                  offerId: offerId,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));
                            },
                            onPageChanged: (index) => ref.read(Home_riverpod.notifier).changeMainCarousel(index),
                            height: sizes.GetHeight() * 18,
                            activeColor: theme.GetColor("primary"),
                            inactiveColor: Color(0xFFD3E9F8),
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                        ],
                        // ─── Top Picks ────────────────────────────────
                          if (ref.read(Home_riverpod.notifier).displayItems.isNotEmpty)
                          Toppicks(
                          homes: [{"items": ref.watch(Home_riverpod.notifier).displayItems}],
                          filters: homes,
                        ),

                        // ─── Closest & Cheapest (Order to Go فقط) ────
                        if (selectedIndex == 3 && closestCheapest.isNotEmpty) ...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          _sectionHeader(
                            title: "الأقرب والأرخص",
                            onSeeAll: () {},
                            sizes: sizes, theme: theme, textLanguage: textLanguage,
                          ),
                          SizedBox(height: sizes.GetHeight() * 1),

                          // Sort Buttons
                          _buildSortButtons(sizes, theme, textLanguage),

                          SizedBox(height: sizes.GetHeight() * 2),
                          SizedBox(
                            height: sizes.GetHeight() * 30,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: closestCheapest.length,
                              itemBuilder: (context, i) {
                                final item = closestCheapest[i];
                                final int itemId = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
                                return Padding(
                                  padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                                  child: ContentCard(
                                    imagePath: "assets/images/image6.png",
                                    title: item["business_name"] ?? "",
                                    description: item["name"] ?? "",
                                    showIcon: true,
                                    circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                                    buttonText: textLanguage.w("اطلب الآن"),
                                    onButtonTap: () {},
                                    width: sizes.GetWidth() * 50,
                                    height: sizes.GetHeight() * 40,
                                    liked: ref.watch(Home_riverpod.notifier).favoriteStatus[itemId] ?? false,
                                    onLikeTap: () => ref.read(Home_riverpod.notifier).toggleLike(itemId, i, context),
                                    additionalInfo: Column(
                                      children: [
                                        Row(children: [
                                          SvgPicture.asset("assets/icon/LikePrice.svg"),
                                          SizedBox(width: sizes.GetWidth() * 1),
                                          Text(
                                            "${item["min_price"] ?? "0"} SAR",
                                            style: TextStyle(color: theme.GetColor("secondaryPrimary"), fontSize: 10),
                                          ),
                                        ]),
                                        if (item["distance_km"] != null)
                                          Row(children: [
                                            SvgPicture.asset("assets/icon/site.svg", height: sizes.GetHeight() * 1.7),
                                            SizedBox(width: sizes.GetWidth() * 1),
                                            Text("${item["distance_km"]} KM", style: TextStyle(fontSize: 10)),
                                          ]),
                                      ],
                                    ),
                                    menuItemId: item['id'],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        // ─── Most Ordered (Order to Go فقط) ──────────
                        if (selectedIndex == 3 && mostOrdered.isNotEmpty) ...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          _sectionHeader(
                            title: textLanguage.w("الأكثر طلباً"),
                            onSeeAll: () {},
                            sizes: sizes, theme: theme, textLanguage: textLanguage,
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          SizedBox(
                            height: sizes.GetHeight() * 30,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: mostOrdered.length,
                              itemBuilder: (context, i) {
                                final item = mostOrdered[i];
                                final int itemId = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
                                return Padding(
                                  padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                                  child: ContentCard(
                                    imagePath: "assets/images/image6.png",
                                    title: item["business_name"] ?? "",
                                    description: item["name"] ?? "",
                                    showIcon: true,
                                    circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                                    buttonText: textLanguage.w("اطلب الآن"),
                                    onButtonTap: () {},
                                    width: sizes.GetWidth() * 50,
                                    height: sizes.GetHeight() * 40,
                                    liked: ref.watch(Home_riverpod.notifier).favoriteStatus[itemId] ?? false,
                                    onLikeTap: () => ref.read(Home_riverpod.notifier).toggleLike(itemId, i, context),
                                    additionalInfo: SizedBox.shrink(),
                                    menuItemId: item['id'],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        // ─── Favorites ────────────────────────────────
                        if (favorite.isNotEmpty) ...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          _sectionHeader(
                            title: textLanguage.w("اختيارات المستخدمين المفضلة"),
                            onSeeAll: ()async {
                            final res=await Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SeeAll(
                                  title: textLanguage.w("اختيارات المستخدمين المفضلة"),
                                  section: RestaurantSection.favorites,
                                  /*
                                  filters: homes.isNotEmpty && homes[0]["sections"]?["filters"] is List
                                      ? (homes[0]["sections"]["filters"] as List)
                                      .whereType<Map<String, dynamic>>()
                                      .toList()
                                      : [],

                                   */
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));

                              if(res!=null){
                                ref.read(Home_riverpod.notifier).restaurants(context);
                              }

                            },
                            sizes: sizes, theme: theme, textLanguage: textLanguage,
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          Favorites(favorite: favorite),
                        ],

                        // ─── A New Dish to Try / Flavor of the Day ─────────────────
                        if (dish.isNotEmpty) ...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          _sectionHeader(
                            title:selectedIndex ==0? textLanguage.w("طبق جديد لتجربته"):textLanguage.w("نكهة اليوم"),
                            onSeeAll: ()async {
                            final res=await Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SeeAll(
                                  title:selectedIndex ==0? textLanguage.w("طبق جديد لتجربته"):textLanguage.w("نكهة اليوم"),
                                  section: RestaurantSection.dishOfTheDay,
                                  sectionKey: ref.read(Home_riverpod.notifier).getTopPicksKey(),
                                  /*
                                  filters: homes.isNotEmpty && homes[0]["sections"]?["filters"] is List
                                      ? (homes[0]["sections"]["filters"] as List)
                                      .whereType<Map<String, dynamic>>()
                                      .toList()
                                      : [],
                                   */
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));
                            if(res!=null){
                              ref.read(Home_riverpod.notifier).restaurants(context);
                            }
                            },
                            sizes: sizes, theme: theme, textLanguage: textLanguage,
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          SizedBox(
                            height: sizes.GetHeight() * 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dish.length,
                              itemBuilder: (context, i) {
                                final dishs = dish[i];
                                final String dishTitle = (dishs["title"] ?? dishs["business_name"] ?? "").toString();
                                final String dishSubTitle = (dishs["restaurant"]?["name"] ?? dishs["branch_name"] ?? "").toString();
                                final String dishDesc = (dishs["description"] ?? "لايوجد بينات").toString();
                                final String dishPrice = dishs["price"]?.toString() ?? "0";
                                final dynamic rawId = dishs["id"] ?? dishs["item"]?["id"] ?? dishs["branch_id"];
                                final int itemId = int.tryParse(rawId?.toString() ?? "0") ?? 0;
                                final bool isLiked = ref.watch(Home_riverpod.notifier).favoriteStatus[itemId] ?? false;
                                return Padding(
                                  padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                                  child: ContentCard(
                                    additionalInfo: Row(children: [
                                      SvgPicture.asset("assets/icon/LikePrice.svg"),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text(dishPrice, style: TextStyle(color: theme.GetColor("secondaryPrimary"))),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      SvgPicture.asset("assets/icon/SAR.svg", color: theme.GetColor("secondaryPrimary")),
                                    ]),
                                    showIcon: true,
                                    imagePath: fixImage(dishs["image"])??"",
                                    title: dishTitle,
                                    subTitle: dishSubTitle,
                                    description: dishDesc,
                                    circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                                    buttonText: textLanguage.w("اطلب الآن"),
                                    onButtonTap: () {
                                      final int branchId = dishs["branch_id"] ?? 0;
                                      Navigator.push(context, PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => RestaurantDetalis(title: dishTitle,
                                          branchId: branchId,
                                         ),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ));
                                    },
                                    width: sizes.GetWidth() * 50,
                                    height: sizes.GetHeight() * 40,
                                    liked: isLiked,
                                    onLikeTap: () {
                                      if (itemId == 0) return;
                                      ref.read(Home_riverpod.notifier).toggleLike(itemId, i, context, type: "menu_item");
                                    },
                                    menuItemId: dishs['id'],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        SizedBox(height: sizes.GetHeight() * 2),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sort Buttons لـ Closest & Cheapest ──────────────────────────────────
  Widget _buildSortButtons(Sizes sizes, Themes theme, TextLanguage textLanguage) {
    final notifier   = ref.read(Home_riverpod.notifier);
    final currentSort = ref.watch(Home_riverpod.notifier).closestCheapestSortBy;
    final sortOptions = [
      {"key": "ratio",   "label": textLanguage.w("الأفضل")},
      {"key": "closest", "label": textLanguage.w("الأقرب")},
      {"key": "cheapest","label": textLanguage.w("الأرخص")},
    ];
    return Row(
      children: sortOptions.map((option) {
        final isSelected = currentSort == option["key"];
        return GestureDetector(
          onTap: () => notifier.changeClosestCheapestSort(context, option["key"]!),
          child: Container(
            margin: EdgeInsets.only(right: sizes.GetWidth() * 2),
            padding: EdgeInsets.symmetric(
              horizontal: sizes.GetWidth() * 4,
              vertical: sizes.GetHeight() * 0.8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFA56C0B) : Color(0xFFF4EBD7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Color(0xFFA56C0B) : Color(0xFFD4B896),
              ),
            ),
            child: Text(
              option["label"]!,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFFA56C0B),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Section Header Helper ────────────────────────────────────────────────
  Widget _sectionHeader({
    required String title,
    required VoidCallback onSeeAll,
    required Sizes sizes,
    required Themes theme,
    required TextLanguage textLanguage,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: theme.GetColor("textPrimary"), fontSize: 15, fontWeight: FontWeight.bold)),
        InkWell(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                textLanguage.w("عرض الكل"),
                style: TextStyle(decoration: TextDecoration.underline, color: theme.GetColor("textPrimary")),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Directionality.of(context) == TextDirection.rtl
                    ? Matrix4.rotationY(3.141592653589793)
                    : Matrix4.identity(),
                child: SvgPicture.asset("assets/icon/Arrow_one.svg"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Icon Button Helper ───────────────────────────────────────────────────
  Widget _iconButton(
      String asset,
      Sizes sizes, {
        required Color backgroundColor,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: onTap,
        child: SvgPicture.asset(
          asset,
          height: sizes.GetHeight() * 3,
          color: iconColor, // 👈 لون الأيقونة
        ),
      ),
    );
  }

  String _getStatusTitle(List homes) {
    if (homes.isEmpty) return "";
    final sections = homes[0]["sections"];
    if (sections == null) return "";
    if (sections?["restaurants_status"]?["has_content"] ?? false) return TextLanguage().w("حالة المطاعم");
    if (sections?["lounges_status"]?["has_content"] ?? false)     return TextLanguage().w("حالة لاونجات");
    if (sections?["cafes_status"]?["has_content"] ?? false)       return TextLanguage().w("حالة المقاهي");
    if (sections?["order_to_go_status"]?["has_content"] ?? false) return TextLanguage().w("حالة الطلب الجاهز");
    return "";
  }
}

// ─── IconBox ──────────────────────────────────────────────────────────────────
class IconBox extends StatelessWidget {
  final bool isSelected;
  final String iconKey, icon, title;
  final double width, height;
  final double radius;

  const IconBox({
    super.key,
    required this.iconKey,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.width,
    required this.height,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Themes();
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: isSelected
            ? Border.all(color: theme.GetColor("textPrimary"), width: 1.5)
            : Border.all(color: theme.GetColor("primaryS"), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconKey == "SVG"
              ? SvgPicture.asset(icon)
              : Image.asset(icon, height: height),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? theme.GetColor("textPrimary") : theme.GetColor("primaryS"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}