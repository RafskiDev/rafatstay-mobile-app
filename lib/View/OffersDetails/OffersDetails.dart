import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rafatstay/View/MakeItYourWay/MakeItYourWay.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CarouselIndicator.dart';
import '../../Widget/CountdownText.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
import 'OffersDetails_riverpod.dart';

class OffersDetails extends ConsumerStatefulWidget {
  final String title;
  final int offerId;

  const OffersDetails({
    super.key,
    required this.title,
    required this.offerId,
  });

  @override
  ConsumerState<OffersDetails> createState() => _OffersDetailsState();
}

class _OffersDetailsState extends ConsumerState<OffersDetails> {
  // ✅ متغير محلي يتتبع حالة التحميل
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      ref.read(MakeItYourWay_riverpod.notifier).menuItems.clear();
      ref.read(RestaurantDetalis_riverpod.notifier).supportsTakeaway = false;

      await ref.read(OffersDetails_riverpod.notifier).fetchOfferDetails(context, widget.offerId);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();

    final currentIndex = ref.watch(OffersDetails_riverpod);
    final notifier = ref.watch(OffersDetails_riverpod.notifier);
    final offerData = notifier.offerData;
    final item = notifier.items;

    // ✅ شاشة تحميل
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.GetColor("background"),
        body: Center(child: CircularProgressIndicator(color: theme.GetColor("primary"))),
      );
    }

    // ✅ شاشة لا توجد بيانات — بعد انتهاء التحميل فقط
    if (offerData == null) {
      return Scaffold(
        backgroundColor: theme.GetColor("background"),
        appBar: buildCustomAppBar(context, widget.title),
        body: Center(
          child: Text(
            textLanguage.GetWord("لا توجد بيانات"),
            style: TextStyle(color: theme.GetColor("textSecondary"), fontSize: 16),
          ),
        ),
      );
    }

    final countdown = offerData["countdown_seconds"];
    final images = offerData["image_urls"] ?? [];
    final language = notifier.box.read("Language");

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: CarouselSlider(
                      items: images.isEmpty
                          ? [
                        Container(
                          color: theme.GetColor("primaryS"),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        )
                      ]
                          : images.map<Widget>((img) {
                        return CachedNetworkImage(
                          imageUrl: img.toString(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(color: theme.GetColor("primary")),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.GetColor("background"),
                            child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: sizes.GetHeight() * 35,
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (index, reason) {
                          ref.read(OffersDetails_riverpod.notifier).changePage(index);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
                      child: GlassAppBar(
                        onBack: () => Navigator.pop(context),
                        onNotification: () {},
                        titel: widget.title,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              if (images.isNotEmpty)
                CarouselIndicator(
                  itemCount: images.length,
                  currentIndex: currentIndex,
                  activeColor: theme.GetColor("secondary500"),
                  inactiveColor: theme.GetColor("primaryS"),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/MealTime.svg", height: sizes.GetHeight() * 2),
                            SizedBox(width: sizes.GetWidth() * 2),
                            Text(offerData["prep_time_label"]?.toString() ?? "0"),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/stars.svg"),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text("${offerData["rating"] ?? 0}"),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(
                              "(${offerData["reviews_count"] ?? 0} ${textLanguage.GetWord("التقييمات")})",
                              style: TextStyle(
                                color: theme.GetColor("textSecondary"),
                                fontSize: sizes.GetHeight() * 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/LikePrice.svg", height: sizes.GetHeight() * 2),
                            if (offerData["original_price"] != null) ...[
                              SizedBox(width: sizes.GetWidth() * 2),
                              Text(
                                "${offerData["original_price"]}",
                                style: TextStyle(
                                  color: theme.GetColor("secondaryPrimary"),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SvgPicture.asset("assets/icon/SAR.svg", height: sizes.GetHeight() * 2),
                            ],
                            if (offerData["discount_value"] != null) ...[
                              SizedBox(width: sizes.GetWidth() * 2),
                              Text(
                                "${offerData["discount_value"]}",
                                style: TextStyle(
                                  color: theme.GetColor("error"),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: theme.GetColor("error"),
                                  decorationThickness: 2,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/icon/SAR.svg",
                                height: sizes.GetHeight() * 2,
                                color: theme.GetColor("error"),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/SandGlass.svg", height: sizes.GetHeight() * 2),
                            SizedBox(width: sizes.GetWidth() * 2),
                            CountdownSeconds(
                              countdownSeconds: (countdown ?? 0).toInt(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offerData["title"] ?? "",
                            style: TextStyle(
                              fontSize: sizes.GetHeight() * 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        language == 0 ? offerData["description_en"] ?? "" : offerData["description"] ?? "",
                        style: TextStyle(color: theme.GetColor("primaryS")),
                      ),
                    ),
                    SizedBox(height: sizes.GetHeight() * 3),
                    if (item.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            textLanguage.GetWord("المحتويات"),
                            style: TextStyle(
                              fontSize: sizes.GetHeight() * 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      SizedBox(
                        height: sizes.GetHeight() * 11,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: item.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                              child: ImageWithTitleItem(
                                imageUrl: item[index]["image"] ?? "",
                                title: item[index]["name"] ?? "",
                                size: sizes.GetHeight() * 11,
                                backgroundColor: theme.GetColor("background"),
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: sizes.GetHeight() * 5),
                    SquareButton(
                      backgroundColor: theme.GetColor("primary"),
                      width: sizes.GetWidth() * 50,
                      height: sizes.GetHeight() * 5,
                      borderRadius: sizes.GetHeight() * 5,
                      onTap: () {
                        final businessName = offerData["branch"]?["business_name"] ?? "";
                        final branchId = offerData["branch"]?["id"] ?? 0;
                        final title = offerData["title"] ?? "";
                        final includedItems = ref.read(OffersDetails_riverpod.notifier).items;
                        final selectedMeals = includedItems.map((item) {
                          final range = item["ready_time_minutes"] ?? "0-0";
                          final name = item["name"] ?? "0-0";
                          return {
                            ...item,
                            "time": range,
                            "title":name,
                          };
                        }).toList();
                        if (includedItems.isNotEmpty) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => MakeItYourWay(
                                selectedMeals: selectedMeals,
                                title: title,
                                businessName: businessName,
                                branchId: branchId,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              textLanguage.GetWord("اطلب الآن"),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: sizes.GetWidth() * 2),
                                 Transform.flip(
                                 flipX: notifier.box.read("Language") == 1,
                                 child: SvgPicture.asset("assets/icon/arrow.svg"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: sizes.GetHeight() * 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageWithTitleItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ImageWithTitleItem({
    super.key,
    required this.imageUrl,
    required this.title,
    this.size = 48,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Themes theme = Themes();
    final sizes = Sizes(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        padding: EdgeInsets.all(sizes.GetHeight() * 1),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: theme.GetColor("primaryS"), width: 1),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.fastfood, size: 30),
                ),
              ),
            ),
            SizedBox(height: sizes.GetHeight() * 1),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sizes.GetHeight() * 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}