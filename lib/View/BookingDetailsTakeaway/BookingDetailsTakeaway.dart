import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/CountdownText.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../OffersDetails/OffersDetails_riverpod.dart';
import '../Review_Confirm/Review_Confirm.dart';
import 'BookingDetailsTakeaway_riverpod.dart';
import 'dart:async';

class BookingDetailsTakeaway extends  ConsumerStatefulWidget{
  final Map<String, dynamic> bookingData;
  const BookingDetailsTakeaway({super.key, required this.bookingData});

  @override
  ConsumerState<BookingDetailsTakeaway> createState() => _BookingDetailsTakeawayState();
}

class _BookingDetailsTakeawayState extends ConsumerState<BookingDetailsTakeaway> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(BookingDetailsTakeaway_riverpod.notifier).resetToDefault();
      ref.read(BookingDetailsTakeaway_riverpod.notifier).loadFromBookingData(widget.bookingData);
      ref.read(BookingDetailsTakeaway_riverpod.notifier).garages(context,widget.bookingData["branch_id"]??0);
    });
  }
  @override
  void dispose() {
    _timer?.cancel();  // ← مهم عشان ما يسبب memory leak
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(BookingDetailsTakeaway_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final items = ref.watch(BookingDetailsTakeaway_riverpod.notifier).items;
    final menuItems = ref.watch(MakeItYourWay_riverpod.notifier).menuItems;
    final includedItems = ref.read(OffersDetails_riverpod.notifier).includedItems;
    final menuItems_ = (menuItems.isNotEmpty)
        ? menuItems
        : (includedItems.isNotEmpty)
        ? includedItems
        : <Map<String, dynamic>>[];
    final garage=ref.watch(BookingDetailsTakeaway_riverpod.notifier).garage;
    final List? bookingItems = widget.bookingData["items"];
    final Map? firstItem = (bookingItems != null && bookingItems.isNotEmpty) ? bookingItems[0] : null;
    final String? cookingMethod = firstItem?["cooking_method"];
    final String? donenessLevel = firstItem?["doneness_level"];
    final bool showCookingOptions = cookingMethod != null || donenessLevel != null;
    final double totalPrice = menuItems_.fold(0.0, (sum, item) {
      double price = double.tryParse(item["price"].toString()) ?? 0.0;
      int count = int.tryParse(item["count"].toString()) ?? 1;
      return sum + (price * count);
    });
    return  Scaffold(
      appBar:buildCustomAppBar(context,"Booking Details"),
      backgroundColor:theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable:LoadingService.isLoading,
        builder:(context,isLoading,child) {
          return isLoading ? showLoading() : Container(
              padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: sizes.GetHeight() * 4.2,
                              height: sizes.GetHeight() * 4.2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.GetColor("secondaryPrimary"),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ClipOval(
                                  child: Image.asset(
                                    "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(
                                widget.bookingData["businessName"],
                               style: TextStyle(
                                color: theme.GetColor("primary"),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.GetColor("primary"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        SizedBox(
                          height: sizes.GetHeight() * 10,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: sizes.GetHeight() * 0.2),
                                child: BadgeBox(
                                  sizes: sizes,
                                  theme: theme,
                                  text: items[index]["title"].toString(),
                                  svgPath: items[index]["image"].toString(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(textLanguage.GetWord("الوقت المتبقي"),
                              style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              children: [
                                SvgPicture.asset(height: sizes.GetHeight() * 2,
                                  "assets/icon/SandGlass.svg",
                                  color: theme.GetColor("textPrimary"),),
                                CountdownText(bookingData: widget.bookingData),
                                /*
                                Text(DateTimeHelper().getRemainingTime(
                                    widget.bookingData)),

                                 */
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        Row(
                          children: [
                            GradientText(
                              widget: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/MealDetails.svg",
                                    height: sizes.GetHeight() * 2,
                                  ),
                                  SizedBox(width: sizes.GetWidth() * 1),
                                  Text(textLanguage.GetWord("تفاصيل الوجبة"),
                                    style: TextStyle(fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ),
                            SizedBox(width: sizes.GetWidth() * 5),
                            GradientText(
                              widget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/dollar.svg",
                                    height: sizes.GetHeight() * 2,
                                  ),
                                  SizedBox(width: sizes.GetWidth() * 1),
                                  Text(
                                    totalPrice.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: sizes.GetWidth() * 1),
                                  SvgPicture.asset("assets/icon/SAR.svg",height:sizes.GetHeight()*1.2),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        Container(
                          padding: EdgeInsets.all(sizes.GetWidth() * 3),
                          decoration: BoxDecoration(
                            color: Themes().GetColor("backgroundOffWhite"),
                            borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                          ),
                          child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(height: sizes.GetHeight() * 2),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: menuItems_.length,
                              itemBuilder: (_, index) {
                                final item = menuItems_[index];
                                return MealInfoRow(
                                  sizes: sizes,
                                  theme: theme,
                                  title: item["title"].toString(),
                                  price: item["price"].toString(),
                                  priceSvg: "assets/icon/dollar.svg",
                                  currencySvg: "assets/icon/SAR.svg",
                                  mealsSvg: "assets/icon/MealDetails.svg",
                                  mealsCount: item["count"].toString(),
                                  mealsText: textLanguage.GetWord("وجبات الطعام"),
                                );
                              }),
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        if (showCookingOptions)...[
                          Row(
                            children: [
                              GradientText(
                                widget: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icon/CookingMethod.svg",
                                      height: sizes.GetHeight() * 3,
                                    ),
                                    SizedBox(width: sizes.GetWidth() * 1),
                                    Text(textLanguage.GetWord("تفاصيل الطبخ")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sizes.GetHeight() * 1),
                          Container(
                            padding: EdgeInsets.all(sizes.GetWidth() * 3),
                            decoration: BoxDecoration(
                              color: Themes().GetColor("backgroundOffWhite"),
                              borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                            ),
                            child: Column(
                              children: [
                                if (cookingMethod != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icon/CookingMethod.svg",
                                            height: sizes.GetHeight() * 3,
                                          ),
                                          SizedBox(width: sizes.GetWidth() * 1),
                                          Text(textLanguage.GetWord("طريقة الطهي")),
                                        ],
                                      ),
                                      WidgetButton(
                                        borderColor:theme.GetColor("textPrimary"),
                                        context: context,
                                        buttonText:widget.bookingData["items"][0]["cooking_method"],
                                        textColor: theme.GetColor("textPrimary"),
                                        width: sizes.GetWidth() * 10,
                                        isCircular:true,
                                        onPressed: () {
                                          print("Button pressed!");
                                        },
                                        backgroundColor: Colors.transparent,
                                      )

                                    ],
                                  ),
                                if (donenessLevel != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icon/DonenessLevel.svg",
                                            height: sizes.GetHeight() * 3,
                                          ),
                                          SizedBox(width: sizes.GetWidth() * 1),
                                          Text(textLanguage.GetWord("مستوى الإنجاز")),
                                        ],
                                      ),
                                      WidgetButton(
                                        borderColor:theme.GetColor("textPrimary"),
                                        context: context,
                                        buttonText:widget.bookingData["items"][0]["doneness_level"],
                                        textColor: theme.GetColor("textPrimary"),
                                        width: sizes.GetWidth() * 10,
                                        isCircular:true,
                                        onPressed: () {
                                          print("Button pressed!");
                                        },
                                        backgroundColor: Colors.transparent,
                                      )

                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: sizes.GetHeight() * 1),
                        Container(
                          padding: EdgeInsets.all(sizes.GetWidth() * 3),
                          decoration: BoxDecoration(
                            color: Themes().GetColor("backgroundOffWhite"),
                            borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/FoodPackaging.svg",
                                    height: sizes.GetHeight() * 3,
                                  ),
                                  SizedBox(width: sizes.GetWidth() * 1),
                                  Text("Food packaging", style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                                ],
                              ),
                              GradientText(
                                widget: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset("assets/icon/SAR.svg",
                                        height: sizes.GetHeight() * 1.5),
                                    SizedBox(width: sizes.GetWidth() * 1),
                                    Text("%5", style: TextStyle(
                                        fontSize: sizes.GetHeight() * 2.2,
                                        fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                       // if(garage.isNotEmpty && garage[0]["available"] == true)...[],
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icon/TableDetails.svg",
                              height: sizes.GetHeight() * 3,
                            ),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(textLanguage.GetWord('حجز موقف السيارات'),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        Row(
                          children: [
                            Text(textLanguage.GetWord(
                                'هل تحتاج إلى موقف سيارات'),
                                style: TextStyle(color: theme.GetColor(
                                    "textSecondary"))),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        Row(
                          children: [
                            CheckBox<int>(
                              height: sizes.GetHeight() * 3,
                              value: 0,
                              borderColor: theme.GetColor("textSecondary"),
                              groupValue: (ref.watch(
                                  BookingDetailsTakeaway_riverpod) & 1) != 0
                                  ? 0
                                  : -1,
                              onChanged: (val) {
                                /*
                                 if (garage.isNotEmpty && garage[0]["available"] == true) {
                                  ref.read(BookingDetailsTakeaway_riverpod.notifier).selectIndex(val);
                                }
                                 */
                                ref
                                    .read(
                                    BookingDetailsTakeaway_riverpod.notifier)
                                    .selectIndex(val);
                              },
                            ),
                            Text(textLanguage.GetWord("أحتاج إلى موقف سيارة")),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        if ((ref.watch(BookingDetailsTakeaway_riverpod) & 1) != 0 && garage.isNotEmpty)
                        Visibility(
                          visible: (ref.watch(
                              BookingDetailsTakeaway_riverpod) & 1) != 0,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icon/dollar.svg",
                                        height:sizes.GetHeight()*2.2,
                                        color:theme.GetColor("textPrimary"),
                                      ),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      SvgPicture.asset(
                                        "assets/icon/SAR.svg",
                                        height:sizes.GetHeight()*1.8,
                                        color:theme.GetColor("textPrimary"),
                                      ),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text("${garage[0]["price"] ?? 0}")
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icon/hour.svg",
                                        color:theme.GetColor("textPrimary"),
                                        height:sizes.GetHeight()*1.8,
                                      ),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text("${garage[0]["open_time"]??"00:00"} hours"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icon/LocationTable.svg",
                                        color:theme.GetColor("textPrimary"),
                                        height:sizes.GetHeight()*1.8,
                                      ),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text(garage[0]["location"] ?? "indoor"),//غير موجوده في باك اند الحفل
                                    ],
                                  ),

                                ],
                              ),
                              SizedBox(height: sizes.GetHeight() * 1),
                              WidgetTextField(
                                isPassword: false,
                                Controller: ref
                                    .read(BookingDetailsTakeaway_riverpod.notifier)
                                    .CarPlate,
                                HintText: textLanguage.GetWord(
                                    "أدخل رقم لوحة السيارة"),
                                iconData: "assets/icon/carplate.svg",
                                focusNode: ref
                                    .read(BookingDetailsTakeaway_riverpod.notifier)
                                    .CarPlateNode,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        Visibility(
                          visible: (ref.watch(
                              BookingDetailsTakeaway_riverpod) & 1) != 0,
                          child: WidgetTextField(
                            isPassword: false,
                            Controller: ref
                                .read(BookingDetailsTakeaway_riverpod.notifier)
                                .CarColor,
                            HintText: textLanguage.GetWord("أدخل لون السيارة"),
                            iconData: "assets/icon/CarColor.svg",
                            focusNode: ref
                                .read(BookingDetailsTakeaway_riverpod.notifier)
                                .CarColorNode,
                          ),
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        Row(
                          children: [
                            CheckBox<int>(
                              height: sizes.GetHeight() * 3,
                              value: 1,
                              borderColor: theme.GetColor("textSecondary"),
                              groupValue: (ref.watch(
                                  BookingDetailsTakeaway_riverpod) & 2) != 0
                                  ? 1
                                  : -1,
                              onChanged: (val) {
                                ref
                                    .read(
                                    BookingDetailsTakeaway_riverpod.notifier)
                                    .selectIndex(val);
                              },
                            ),
                            Text(textLanguage.GetWord(
                                "لست بحاجة إلى موقف سيارات")),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        SquareButton(
                          width: sizes.GetWidth() * 50,
                          height: sizes.GetHeight() * 6,
                          onTap: () async {
                            final hasGarage = garage.isNotEmpty && garage[0]["available"] == true;
                            final state = ref.read(BookingDetailsTakeaway_riverpod);
                            if (hasGarage && state != 1 && state != 2) {
                              ToastMessages(
                                context,
                                textLanguage.GetWord("يرجى تحديد هل تحتاج موقف سيارة"),
                                Colors.red,
                                Colors.white,
                              );
                              return;
                            }

                            final needsParking = ref.read(BookingDetailsTakeaway_riverpod.notifier).isFirstSelected();
                            final enrichedBookingData = {
                              ...widget.bookingData,
                              'menuItems': ref.read(MakeItYourWay_riverpod.notifier).menuItems,
                              'needs_parking': needsParking,
                              if (needsParking) ...{
                                'car_plate': ref.read(BookingDetailsTakeaway_riverpod.notifier).CarPlate.text,
                                'car_color': ref.read(BookingDetailsTakeaway_riverpod.notifier).CarColor.text,
                                'parking_hours': garage[0]["open_time"] ?? 1,
                                'parking_location': "indoor",
                              }
                            };

                           final createTakeawayBooking=await ref.read(BookingDetailsTakeaway_riverpod.notifier).createTakeawayBooking(
                                context: context,
                                bookingData:enrichedBookingData
                              );
                            if (createTakeawayBooking == null) return;
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1,
                                    animation2) =>
                                    Review_Confirm(
                                        bookingData: createTakeawayBooking,name:widget.bookingData["businessName"]),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                textLanguage.GetWord("مراجعة وتأكيد"),
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              SvgPicture.asset(
                                "assets/icon/arrow.svg",
                              ),
                            ],
                          ),
                          backgroundColor: theme.GetColor("primary"),
                          borderRadius: sizes.GetWidth() * 10,
                        ),
                        SizedBox(height: sizes.GetHeight() * 7,),
                      ]
                  )
              )
          );
        }
      ),
    );
  }

}

class BadgeBox extends StatelessWidget {
  final Sizes sizes;
  final dynamic theme;
  final String text;
  final String svgPath;   // مسار الأيقونة

  const BadgeBox({
    super.key,
    required this.sizes,
    required this.theme,
    required this.text,
    required this.svgPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 0.4),
      width: sizes.GetWidth() * 18.5,
      height: sizes.GetHeight() * 10,
      decoration: BoxDecoration(
        color: theme.GetColor("background"),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:theme.GetColor("primary"),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath,                     // هنا نستخدم البراميتر
            height: sizes.GetHeight() * 4,
            color: theme.GetColor("primary"),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class MealInfoRow extends StatelessWidget {
  final Sizes sizes;
  final dynamic theme;

  final String title;       // Meat Dishes
  final String price;       // 1000
  final String currencySvg; // assets/icon/SAR.svg
  final String priceSvg;    // assets/icon/dollar.svg
  final String mealsCount;  // 4
  final String mealsText;   // meals
  final String mealsSvg;    // assets/icon/MealDetails.svg

  const MealInfoRow({
    super.key,
    required this.sizes,
    required this.theme,
    required this.title,
    required this.price,
    required this.currencySvg,
    required this.priceSvg,
    required this.mealsCount,
    required this.mealsText,
    required this.mealsSvg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            color: theme.GetColor("textPrimary"),
            fontWeight: FontWeight.w600,
          ),
        ),

        // Price
        GradientText(
          widget: Row(
            children: [
              SvgPicture.asset(
                priceSvg,
                height: sizes.GetHeight() * 2,
              ),
              SizedBox(width: sizes.GetWidth() * 1),
              SvgPicture.asset(
                currencySvg,
                height: sizes.GetHeight() * 2,
                color: theme.GetColor("textPrimary"),
              ),
              SizedBox(width: sizes.GetWidth() * 1),
              Text(
                price,
                style: TextStyle(color: theme.GetColor("textPrimary")),
              ),
            ],
          ),
        ),

        // Meals count
        Row(
          children: [
            SvgPicture.asset(
              mealsSvg,
              height: sizes.GetHeight() * 2,
            ),
            SizedBox(width: sizes.GetWidth() * 1),
            Text(
              mealsCount,
              style: TextStyle(color: theme.GetColor("textPrimary")),
            ),
            SizedBox(width: sizes.GetWidth() * 1),
            Text(
              mealsText,
              style: TextStyle(color: theme.GetColor("textPrimary")),
            ),
          ],
        ),
      ],
    );
  }
}

class TableInfoRow extends StatelessWidget {
  final Sizes sizes;
  final dynamic theme;

  final String tableTitle;       // مثل "Table #5"
  final String price;            // مثل "1000"
  final String priceSvg;         // أيقونة السعر
  final String currencySvg;      // أيقونة العملة
  final String extraSvg;         // أيقونة إضافية للـ Row الثاني
  final String extraText;        // نص إضافي للـ Row الثاني

  const TableInfoRow({
    super.key,
    required this.sizes,
    required this.theme,
    required this.tableTitle,
    required this.price,
    required this.priceSvg,
    required this.currencySvg,
    required this.extraSvg,
    required this.extraText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // العنوان الرئيسي للطاولة
        Text(
          tableTitle,
          style: TextStyle(
            color: theme.GetColor("textPrimary"),
            fontWeight: FontWeight.w600,
          ),
        ),

        // السعر مع الأيقونات
        Row(
          children: [
            SvgPicture.asset(
              priceSvg,
              height: sizes.GetHeight() * 2,
            ),
            SizedBox(width: sizes.GetWidth() * 1),
            SvgPicture.asset(
              currencySvg,
              height: sizes.GetHeight() * 2,
              color: theme.GetColor("textPrimary"),
            ),
            SizedBox(width: sizes.GetWidth() * 1),
            Text(
              price,
              style: TextStyle(color: theme.GetColor("textPrimary")),
            ),
          ],
        ),

        // معلومات إضافية
        Row(
          children: [
            SvgPicture.asset(
              extraSvg,
              height: sizes.GetHeight() * 2,
              color: theme.GetColor("textPrimary"),
            ),
            SizedBox(width: sizes.GetWidth() * 1),
            Text(
              extraText,
              style: TextStyle(color: theme.GetColor("textPrimary")),
            ),
          ],
        ),
      ],
    );
  }
}
