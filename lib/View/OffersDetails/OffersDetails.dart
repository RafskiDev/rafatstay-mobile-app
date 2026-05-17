import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/View/MakeItYourWay/MakeItYourWay.dart';
import 'package:rafatstay/View/SetYourBookingDetails/SetYourBookingDetails.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Widget/CarouselIndicator.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../Payment/Payment.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
import '../SetYourBookingDetails/SetYourBookingDetails_riverpod.dart';
import 'OffersDetails_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Widget/CarouselIndicator.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../Payment/Payment.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(OffersDetails_riverpod.notifier)
        .fetchOfferDetails(context, widget.offerId));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    ref.read(MakeItYourWay_riverpod.notifier).menuItems.clear();
    final notifier_ = ref.read(RestaurantDetalis_riverpod.notifier);
    notifier_.supportsTakeaway=false;
    final notifier = ref.watch(OffersDetails_riverpod.notifier);
    final items = notifier.carouselItems;
    final item = notifier.items;
    final currentIndex = ref.watch(OffersDetails_riverpod);
    final offerData = notifier.offerData;

    String countdownText = "-- : -- : --";

    if (offerData?["expires_at"] != null) {
      final expiry = DateTime.parse(offerData!["expires_at"]);
      final remaining = expiry.difference(DateTime.now());

      if (!remaining.isNegative) {
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final minutes = remaining.inMinutes % 60;

        countdownText = "${days}D : ${hours}H : ${minutes}M";
      } else {
        countdownText = "انتهى العرض";
      }
    }
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: offerData == null
          ?  Center(child: CircularProgressIndicator(color:theme.GetColor("primary")))
          : SingleChildScrollView(
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
                    items: items.isEmpty
                        ? [
                      Container(
                        color: theme.GetColor("primaryS"),
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 50),
                        ),
                      )
                    ]
                        : items.map((item) {
                      final img = item["image"] ?? "";
                      return img.startsWith("http")
                          ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : Image.asset(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: sizes.GetHeight() * 35,
                      viewportFraction: 1,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        ref
                            .read(OffersDetails_riverpod.notifier)
                            .changePage(index);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: sizes.GetHeight() * 4,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sizes.GetWidth() * 4),
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
            notifier.carouselItems.isNotEmpty
                ? CarouselIndicator(
              itemCount: notifier.carouselItems.length,
              currentIndex: currentIndex,
              activeColor: theme.GetColor("secondary500"),
              inactiveColor: theme.GetColor("primaryS"),
            )
                : const SizedBox.shrink(),
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icon/MealTime.svg",
                            height: sizes.GetHeight() * 2,
                          ),
                          SizedBox(width: sizes.GetWidth() * 2),
                          Text(
                            offerData["prep_time_minutes"] ?? "0",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset("assets/icon/stars.svg"),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(
                              "${offerData["rating"].toString()}"
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(
                            "(${offerData["reviews_count"].toString()} ${textLanguage.GetWord("التقييمات")})",
                            style:TextStyle(color: theme.GetColor("textSecondary"),fontSize: sizes.GetHeight()*1.5),
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
                          SvgPicture.asset(
                            "assets/icon/LikePrice.svg",
                            height: sizes.GetHeight() * 2,
                          ),
                         if (offerData["original_price"] != null)...[
                           SizedBox(width: sizes.GetWidth() * 2),
                           Text(
                               "${offerData["original_price"]}",
                               style: TextStyle(
                                 color:
                                 theme.GetColor("secondaryPrimary"),
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           SvgPicture.asset(
                             "assets/icon/SAR.svg",
                             height: sizes.GetHeight() * 2,
                           ),
                         ],
                          if (offerData["discount_value"] != null)...[
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
                          ///
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icon/SandGlass.svg",
                            height: sizes.GetHeight() * 2,
                          ),
                          SizedBox(width: sizes.GetWidth() * 2),
                          Text(countdownText),
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
                  SizedBox(height: sizes.GetHeight() * 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      offerData["description"] ?? "",
                      style:
                      TextStyle(color: theme.GetColor("primaryS")),
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
                            padding: EdgeInsets.only(
                                right: sizes.GetWidth() * 1),
                            child: ImageWithTitleItem(
                              svgPath: item[index]["image"] ?? "",
                              title: item[index]["title"] ?? "",
                              iconColor:
                              theme.GetColor("textPrimary"),
                              size: sizes.GetHeight() * 11,
                              backgroundColor:
                              theme.GetColor("background"),
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
                      final businessName = offerData["branch"]["business_name"] ?? "";
                      final branchId = offerData["branch"]["id"] ?? 0;
                      final title = offerData["title"] ?? "";
                    //  final includedItems = offerData["included_items"] ?? [];
                      final includedItems =ref.read(OffersDetails_riverpod.notifier).items;
                      if (includedItems.isNotEmpty) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) =>
                                MakeItYourWay(selectedMeals:includedItems,title: title, businessName: businessName, branchId: branchId),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      }
                      /*
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation1, animation2) =>
                              SetYourBookingDetails(includedItems:includedItems,title: title, businessName: businessName, branchId: branchId),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );

                       */
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textLanguage.GetWord("اطلب الآن"),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: sizes.GetWidth() * 2),
                          SvgPicture.asset("assets/icon/arrow.svg"),
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
    );
  }
}

class ImageWithTitleItem extends StatelessWidget {
  final String svgPath;
  final String title;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ImageWithTitleItem({
    super.key,
    required this.svgPath,
    required this.title,
    this.size = 48,
    this.iconColor,
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
          border: Border.all(
            color: theme.GetColor("primaryS"),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: sizes.GetHeight() * 6,
              color: iconColor,
            ),
            SizedBox(height: sizes.GetHeight() * 1),
            Text(
              title,
              textAlign: TextAlign.center,
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