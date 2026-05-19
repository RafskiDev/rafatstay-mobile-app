import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Utils/VideoContainer.dart';
import '../../Widget/CarouselIndicator.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/CustomCarousel.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/ReviewCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/VideoImageCard.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../Chat/Chat.dart';
import '../EmployeeDetails/EmployeeDetails.dart';
import '../MakeItYourWay/MakeItYourWay.dart';
import '../OffersDetails/OffersDetails.dart';
import '../Reviews/Reviews.dart';
import '../SetYourBookingDetails/SetYourBookingDetails.dart';
import '../notifications/notifications.dart';
import 'RestaurantDetalis_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'Widget/Garage.dart';
import 'Widget/Location.dart';
import 'Widget/Employees.dart';
import 'Widget/MealDropdown.dart';
import 'Widget/Policy.dart';
import 'Widget/SuperGuest.dart';
class RestaurantDetalis extends ConsumerStatefulWidget {
  final String title;
  final int branchId;
  const RestaurantDetalis({
    super.key,
    required this.title,
    required this.branchId,
  });

  @override
  ConsumerState<RestaurantDetalis> createState() => _RestaurantDetalisState();
}

class _RestaurantDetalisState extends ConsumerState<RestaurantDetalis> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // اجلب العروض أولاً
      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).offers(context, widget.branchId);
      });

      // باقي البيانات تجي بشكل غير متزامن
      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).employees(context,widget.branchId);
      });

      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).reviews(context, widget.branchId);
      });

      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).branche(context, widget.branchId);
      });

      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).menus(context, widget.branchId);
      });

      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).branchPolicies(context, widget.branchId);
      });
      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).garages(context, widget.branchId);
      });
      Future.microtask(() async {
        await ref.read(RestaurantDetalis_riverpod.notifier).superGuests_(context, widget.branchId);
      });

    });
  }


  @override
  Widget build(BuildContext context) {
    ref.watch(RestaurantDetalis_riverpod);
    final currentIndex = ref.watch(RestaurantDetalis_riverpod);
    final items=ref.watch(RestaurantDetalis_riverpod.notifier).carouselItems;
   // final controller = ref.watch(RestaurantDetalis_riverpod.notifier).controller;
    final notifier = ref.read(RestaurantDetalis_riverpod.notifier);
    final branches = notifier.branches;
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          if (branches.isEmpty && !LoadingService.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: theme.GetColor("textSecondary")),
                  SizedBox(height: sizes.GetHeight() * 2),
                  Text(
                    textLanguage.GetWord("الفرع غير متوفر"),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.GetColor("textSecondary"),
                    ),
                  ),
                ],
              ),
            );
          }
          if (branches.isEmpty) return showLoading();
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(sizes.GetHeight() * 3),
                        bottomRight: Radius.circular(sizes.GetHeight() * 3),
                      ),
                      child: CarouselSlider(
                        items: (branches[0]['photos'] as List? ?? []).map((item) {
                          final url = item['url'];
                          return Image.asset(
                            "assets/images/66fed65c893473ef90356d043c26c12940be6cf5.png",
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: sizes.GetHeight() * 35,
                          viewportFraction: 1.0,
                          autoPlay: true,
                          enlargeCenterPage: false,
                          onPageChanged: (index, reason) {
                            ref.read(RestaurantDetalis_riverpod.notifier).changePage(index);
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
                          horizontal: sizes.GetWidth() * 4,
                        ),
                        child: GlassAppBar(
                          onBack: () => Navigator.pop(context),
                          onNotification: () {

                          },
                          titel: widget.title,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                CarouselIndicator(
                  itemCount: items.length,
                  currentIndex: currentIndex,
                  activeColor: theme.GetColor("secondary500"),
                  inactiveColor: theme.GetColor("primaryS"),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sizes.GetWidth() * 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icon/ApplesinChina.svg",
                                height: sizes.GetHeight() * 2,
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text(textLanguage.GetWord("حول"),
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: sizes.GetHeight() * 2.5)),
                            ],
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icon/Views_.svg",
                                height: sizes.GetHeight() * 1.5,
                                color: theme.GetColor("textSecondary"),
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text("${textLanguage.GetWord("منظر")} ${ref.read(RestaurantDetalis_riverpod.notifier).branches[0]["reviews_count"]}",
                                  style: TextStyle(
                                      color: theme.GetColor("textSecondary"))),
                            ],
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icon/reserved.svg",
                                height: sizes.GetHeight() * 1.4,
                                color: theme.GetColor("textSecondary"),
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text("${textLanguage.GetWord("الحجز")} ${120}",
                                  style: TextStyle(
                                      color: theme.GetColor("textSecondary"))),
                            ],
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icon/interest.svg",
                                height: sizes.GetHeight() * 2,
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text("${textLanguage.GetWord("اهتمام")} ${23}"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration:BoxDecoration(
                          color:Themes().GetColor("backgroundOffWhite"),
                          borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: sizes.GetHeight() * 6,
                              padding: EdgeInsets.symmetric(horizontal: sizes
                                  .GetWidth() * 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFD3E9F8),
                                borderRadius: BorderRadius.circular(
                                    sizes.GetWidth() * 10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(ref
                                    .read(RestaurantDetalis_riverpod.notifier)
                                    .menuItems
                                    .length, (index) {
                                  final isSelected = ref
                                      .watch(RestaurantDetalis_riverpod.notifier)
                                      .selectedMenuIndex == index;

                                  return InkWell(
                                    onTap: () {
                                      ref
                                          .read(RestaurantDetalis_riverpod.notifier)
                                          .changeSelectedMenu(index);
                                    },
                                    child: Text(
                                      ref
                                          .read(RestaurantDetalis_riverpod.notifier)
                                          .menuItems[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? theme.GetColor(
                                            "secondary500") // اللون عند الاختيار
                                            : theme.GetColor(
                                            "secondaryPrimary"), // اللون العادي
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            ref.read(RestaurantDetalis_riverpod.notifier).selectedMenuIndex!=0?SizedBox(height: sizes.GetHeight() * 2):SizedBox.shrink(),
                            ref
                                .watch(RestaurantDetalis_riverpod.notifier)
                                .selectedMenuIndex == 0 ? Location(
                                context, ref) : Container(),
                            ref
                                .watch(RestaurantDetalis_riverpod.notifier)
                                .selectedMenuIndex == 1
                                ? Policy(context,ref)
                                : Container(),
                            ref
                                .watch(RestaurantDetalis_riverpod.notifier)
                                .selectedMenuIndex == 2 ? Garage(
                              context,
                              "${widget.title} ${textLanguage.GetWord("موقف سيارات")}",//"Al-Baik Garage"
                              "assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png",
                              ref,
                            ) : Container(),
                            ref
                                .watch(RestaurantDetalis_riverpod.notifier)
                                .selectedMenuIndex == 3 ? Employees(ref
                                .read(RestaurantDetalis_riverpod.notifier)
                                .employee,widget.branchId,context) : Container(),
                            ref
                                .watch(RestaurantDetalis_riverpod.notifier)
                                .selectedMenuIndex == 4 ? SuperGuest(context,
                                ref) : Container(),
                            SizedBox(height: sizes.GetHeight() * 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: sizes.GetWidth() * 66,
                                  height: sizes.GetHeight() * 5,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: sizes.GetWidth() * 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF90CAF9),
                                    borderRadius: BorderRadius.circular(
                                        sizes.GetWidth() * 10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icon/closed.svg",
                                            height: sizes.GetHeight() * 2,
                                          ),
                                          SizedBox(width: sizes.GetWidth() * 1),
                                          Text(
                                            "${DateTimeHelper().formatRangeDays(branches[0]["work_days"] ?? [])} "
                                                "${DateTimeHelper().formatTime(
                                              ref.read(RestaurantDetalis_riverpod.notifier).branches[0]["opens_at"] ?? "00:00",
                                            )}",
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icon/closed.svg",
                                            height: sizes.GetHeight() * 2,
                                          ),
                                          SizedBox(width: sizes.GetWidth() * 1),
                                          Text(
                                            DateTimeHelper().formatTime(
                                              ref.read(RestaurantDetalis_riverpod.notifier).branches[0]["closes_at"] ?? "00:00",
                                            ),
                                          ),

                                        ],
                                      ),
                                      /*
                                SvgPicture.asset(
                                     "assets/icon/Menu.svg",
                                     height: sizes.GetHeight() * 2,
                                   ),
                                */
                                    ],
                                  ),
                                ),
                                SizedBox(width: sizes.GetWidth() * 2),
                                CircularButton(
                                  backgroundColor: theme.GetColor("backgroundLight"),
                                  borderColor: theme.GetColor("white"),
                                  size: sizes.GetHeight() * 5.5,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1,
                                            animation2) =>
                                            Chat(branch_id: widget.branchId),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    "assets/icon/chat.svg",
                                    height: sizes.GetHeight() * 3,
                                    color: theme.GetColor("textPrimary"),
                                  ),
                                ),
                                CircularButton(
                                  backgroundColor: theme.GetColor("backgroundLight"),
                                  borderColor: theme.GetColor("white"),
                                  size: sizes.GetHeight() * 5.5,
                                  onTap: () {},
                                  child: SvgPicture.asset(
                                    "assets/icon/sharings.svg",
                                    height: sizes.GetHeight() * 3,
                                    color: theme.GetColor("textPrimary"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icon/3D.svg",
                            height: sizes.GetHeight() * 2,
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(textLanguage.GetWord("مطعم بإطلالة كاملة"),
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: sizes.GetHeight() * 2)),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      VideoImageCard(
                        imagePath: "assets/images/66fed65c893473ef90356d043c26c12940be6cf5.png",
                        width: double.infinity,
                        height: sizes.GetHeight() * 25,
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Row(
                        children: [
                          Container(
                            width: sizes.GetWidth()*50,
                            padding: EdgeInsets.all(8.0),
                            decoration:BoxDecoration(
                              color:Themes().GetColor("backgroundOffWhite"),
                              borderRadius: BorderRadius.circular(sizes.GetHeight() * 10),
                            ),
                            child:Center(
                              child:GradientText(
                              widget: Text(
                                "${textLanguage.GetWord("الحد الأدنى للطلب")}: 200 SAR",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                 ),
                               ),
                             ),
                           ),
                         ),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icon/Menu.svg",
                                height: sizes.GetHeight() * 2,
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text(textLanguage.GetWord("قائمة طعام"),
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: sizes.GetHeight() * 2.5)),
                            ],
                          ),
                          MealDropdown(),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Container(
                        width: double.infinity,
                        height: sizes.GetHeight() * 6,
                        padding: EdgeInsets.symmetric(horizontal: sizes
                            .GetWidth() * 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3E9F8),
                          borderRadius: BorderRadius.circular(
                              sizes.GetWidth() * 10),
                        ),
                        child:ListView.builder(
                          scrollDirection: Axis.horizontal,
                          // +1 لزر "الكل"
                          itemCount: ref.read(RestaurantDetalis_riverpod.notifier).tagss.length + 1,
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final tag = isAll
                                ? "الكل"
                                : ref.read(RestaurantDetalis_riverpod.notifier).tagss[index - 1];
                            final isSelected = isAll
                                ? ref.watch(RestaurantDetalis_riverpod.notifier).isSelectedMenu == -1
                                : ref.watch(RestaurantDetalis_riverpod.notifier).isSelectedMenu == index - 1;

                            return GestureDetector(
                              onTap: () {
                                if (isAll) {
                                  ref.read(RestaurantDetalis_riverpod.notifier).resetMenu();
                                } else {
                                  ref.read(RestaurantDetalis_riverpod.notifier).changeMenu(index - 1);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: sizes.GetWidth() * 0.2,
                                  vertical: sizes.GetHeight() * 1,
                                ),
                                child: Center(
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: sizes.GetHeight() * 1.8,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? theme.GetColor("secondary500")
                                          : theme.GetColor("secondaryPrimary"),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: sizes.GetWidth() * 1,
                          mainAxisSpacing: sizes.GetWidth() * 2,
                          mainAxisExtent: sizes.GetHeight() * 30,
                        ),
                        itemCount: ref
                            .read(RestaurantDetalis_riverpod.notifier)
                            .meals
                            .length,
                        itemBuilder: (context, index) {
                          final meal = ref
                              .read(RestaurantDetalis_riverpod.notifier)
                              .meals[index];
                          return MealCard(
                              item: meal,
                              sizes: sizes,
                              theme: theme,
                              onTap: () {
                                ref
                                    .read(RestaurantDetalis_riverpod.notifier)
                                    .increaseCount(
                                  meal, context,
                                  widget.branchId,
                                );
                              },
                              onTapDelete: () {
                                ref.read(RestaurantDetalis_riverpod.notifier).deleteMeal(index,context);
                              }
                          );
                        },
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SquareButton(
                            width: sizes.GetWidth() * 45,
                            height: sizes.GetHeight() * 5,
                            backgroundColor: theme.GetColor("primary"),
                            borderRadius: sizes.GetHeight() * 5,
                            elevation: 6,
                            onTap: () {
                              final notifier = ref.read(RestaurantDetalis_riverpod.notifier);

                              final selectedMeals = notifier.allMeals
                                  .where((meal) => (meal['count'] ?? 0) > 0)
                                  .toList();
                              if (selectedMeals.isEmpty) {
                                ToastMessages(
                                  context,
                                  "اختر وجبة واحدة على الأقل",
                                  Themes().GetColor("error"),
                                  Themes().GetColor("white"),
                                );
                                return;
                              }

                              // 👇 حساب المجموع
                              double totalPrice = 0;
                              const double minOrder = 200;
                              for (var meal in selectedMeals) {
                                final price = double.tryParse(meal['price'].toString()) ?? 0;
                                final count = meal['count'] ?? 1;
                                totalPrice += price * count;
                              }

                              if (totalPrice < minOrder) {
                                ToastMessages(
                                  context,
                                  "الحد الأدنى للطلب 200 SAR",
                                  Themes().GetColor("error"),
                                  Themes().GetColor("white"),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                      MakeItYourWay(
                                        title: "Make It Your Way",
                                        branchId: widget.branchId,
                                        selectedMeals: selectedMeals,
                                        businessName: widget.title,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );

                              /*
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1,
                                      animation2) =>
                                      SetYourBookingDetails(title: "SetYourBookingDetails", branchId: widget.branchId,
                                       ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );

                               */
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Make It Your Way',
                                ),
                                SizedBox(width: sizes.GetWidth() * 1),
                                SvgPicture.asset(
                                  "assets/icon/arrow.svg",
                                  height: sizes.GetHeight() * 2.5,
                                  //  color:theme.GetColor("textSecondary"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      if (ref
                          .read(RestaurantDetalis_riverpod.notifier)
                          .offer
                          .isNotEmpty)
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icon/Offers.svg",
                              height: sizes.GetHeight() * 2,
                            ),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(textLanguage.GetWord("عروض"), style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: sizes.GetHeight() * 2.5)),
                          ],
                        ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      if (ref
                          .read(RestaurantDetalis_riverpod.notifier)
                          .offer
                          .isNotEmpty)
                        CustomCarousel(
                          items: ref
                              .read(RestaurantDetalis_riverpod.notifier)
                              .offer,
                          currentIndex: ref
                              .read(RestaurantDetalis_riverpod.notifier)
                              .selectedCarouselIndex,
                          onPageChanged: (index) {
                            ref
                                .read(RestaurantDetalis_riverpod.notifier)
                                .changePage_(index);
                          },
                          height: sizes.GetHeight() * 18,
                          activeColor: theme.GetColor("primary"),
                          inactiveColor: Color(0xFFD3E9F8),
                          onTap: () {
                            int offerId = ref
                                .read(RestaurantDetalis_riverpod.notifier)
                                .offer[
                            ref
                                .read(RestaurantDetalis_riverpod.notifier)
                                .selectedCarouselIndex
                            ]["id"];
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1,
                                    animation2) =>
                                    OffersDetails(title: textLanguage.GetWord(
                                        "تفاصيل العروض"),
                                      offerId: offerId,),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      SizedBox(height: sizes.GetHeight() * 1),
                      if (ref
                          .read(RestaurantDetalis_riverpod.notifier)
                          .review
                          .isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icon/Reviews.svg",
                                  height: sizes.GetHeight() * 2,
                                ),
                                SizedBox(width: sizes.GetWidth() * 1),
                                Text(textLanguage.GetWord("التقييمات"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sizes.GetHeight() * 2.5)),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1,
                                        animation2) =>
                                        Reviews(branchId: widget.branchId,),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    textLanguage.GetWord("عرض الكل"),
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: theme.GetColor("textPrimary"),
                                    ),
                                  ),
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: Directionality.of(context) ==
                                        TextDirection.rtl
                                        ? Matrix4.rotationY(3.141592653589793)
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
                      if (ref
                          .read(RestaurantDetalis_riverpod.notifier)
                          .review
                          .isNotEmpty)
                        ReviewCard(
                          name: ref
                              .read(RestaurantDetalis_riverpod.notifier)
                              .review[0]["user"]["full_name"],

                          date:DateTimeHelper.extractTime(ref.read(RestaurantDetalis_riverpod.notifier).review[0]["created_at"]),
                          rating: ref
                              .read(RestaurantDetalis_riverpod.notifier)
                              .review[0]["overall_rating"] ?? 0,
                          comment: ref
                              .read(RestaurantDetalis_riverpod.notifier)
                              .review[0]["comment"],
                          image: "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                          sizes: sizes,
                          theme: theme,
                          onAvatarTap: () {},
                        ),
                      SizedBox(height: sizes.GetHeight() * 6),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}





void showCustomDialog(BuildContext context) {
  final textLanguage = TextLanguage();
  final theme = Themes();
  final sizes = Sizes(context);
  WidgetCustomDialog(
    backgroundColor: theme.GetColor("background"),
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/icon/OutofStock.svg",
          height: sizes.GetHeight()*20,
        ),
        SizedBox(height: sizes.GetHeight() * 2),
        Text(
          textLanguage.GetWord("عذراً، هذه الوجبة غير متوفرة حالياً. يمكنك استكشاف خيارات أخرى شهية من قائمتنا."),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}