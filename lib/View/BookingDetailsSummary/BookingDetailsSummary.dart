import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../PayNow/PayNow.dart';
import '../Payment/Payment.dart';
import '../PaywithMada/PaywithMada.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import 'BookingDetailsSummary_riverpod.dart';
class BookingDetailsSummary extends ConsumerStatefulWidget {
  final int bookingId;
  final Map<String, dynamic>? bookingDetails;
  const BookingDetailsSummary({super.key, required this.bookingId,required this.bookingDetails});

  @override
  ConsumerState<BookingDetailsSummary> createState() => _BookingDetailsSummaryState();
}

class _BookingDetailsSummaryState extends ConsumerState<BookingDetailsSummary> {

  @override
  void initState() {
    super.initState();

    Future.microtask(()async {
     await ref.read(BookingDetailsSummary_riverpod.notifier)
          .fetchReview(context, widget.bookingId);
     print(widget.bookingDetails);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(BookingDetailsSummary_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final reviewData = ref.watch(BookingDetailsSummary_riverpod.notifier).reviewData;
    return  Scaffold(
      appBar:buildCustomAppBar(context,textLanguage.GetWord("تفاصيل الحجز")),
      backgroundColor:theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          return isLoading
              ? showLoading()
              : Container(
              padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icon/bookingDeactivate.svg",
                              height: sizes.GetHeight() * 2.2,
                              color: theme.GetColor("textPrimary"),),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(textLanguage.GetWord("تفاصيل الحجز")),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        Row(
                          children: [
                            Text(textLanguage.GetWord(
                                "استعرض جميع تفاصيل زيارتك السابقة في مكان واحد.")),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        // Items
                        if ((reviewData?['items'] as List?)?.isNotEmpty == true)
                          Column(
                            children: [
                              ...(reviewData!['items'] as List).map((item) => Column(
                                children: [
                                  Padding(
                                    padding:EdgeInsets.symmetric(vertical: sizes.GetHeight()*1),
                                    child: MealInfoRow(
                                      sizes: sizes,
                                      theme: theme,
                                      title: item['item_name']?.toString() ?? '-',
                                      price: item['unit_price']?.toString() ?? '0',
                                      priceSvg: "assets/icon/dollar.svg",
                                      currencySvg: "assets/icon/SAR.svg",
                                      mealsSvg: "assets/icon/MealDetails.svg",
                                      mealsCount: item['quantity']?.toString() ?? '0',
                                      mealsText: textLanguage.GetWord("وجبات الطعام"),
                                    ),
                                  ),
                                  if (item['cooking_method'] != null) ...[
                                    SizedBox(height: sizes.GetHeight() * 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icon/CookingMethod.svg",
                                              height: sizes.GetHeight() * 2.2,
                                            ),
                                            SizedBox(width: sizes.GetWidth() * 1),
                                            Text(textLanguage.GetWord("طريقة الطهي")),
                                          ],
                                        ),
                                        WidgetButton(
                                          borderColor: theme.GetColor("textPrimary"),
                                          context: context,
                                          buttonText: item['cooking_method'].toString(),
                                          textColor: theme.GetColor("textPrimary"),
                                          width: sizes.GetWidth() * 10,
                                          isCircular: true,
                                          onPressed: () {},
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (item['doneness_level'] != null) ...[
                                    SizedBox(height: sizes.GetHeight() * 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icon/DonenessLevel.svg",
                                              height: sizes.GetHeight() * 2.2,
                                            ),
                                            SizedBox(width: sizes.GetWidth() * 1),
                                            Text(textLanguage.GetWord("مستوى الإنجاز")),
                                          ],
                                        ),
                                        WidgetButton(
                                          borderColor: theme.GetColor("textPrimary"),
                                          context: context,
                                          buttonText: item['doneness_level'].toString(),
                                          textColor: theme.GetColor("textPrimary"),
                                          width: sizes.GetWidth() * 10,
                                          isCircular: true,
                                          onPressed: () {},
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              )),
                            ],
                          ),
                        // Table
                        if (reviewData?['table'] != null && reviewData?['service_mode'] != 'takeaway') ...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          TableInfoRow(
                            sizes: sizes,
                            theme: theme,
                            tableTitle: "Table #${reviewData!['table']['table_number']}",
                            price: reviewData['table']['reservation_fee']
                                ?.toString() ?? '0',
                            priceSvg: "assets/icon/dollar.svg",
                            currencySvg: "assets/icon/SAR.svg",
                            extraSvg: "assets/icon/LocationTable.svg",
                            extraText: reviewData['table']['location_type']
                                ?.toString() ?? '',
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                        ],
                        if(reviewData?['service_mode'] == 'takeaway')...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          Row(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/icon/FoodPackaging.svg"),
                                  SizedBox(width: sizes.GetWidth() * 1),
                                  Text(textLanguage.GetWord("تغليف المواد الغذائية")),
                                ],
                              ),
                              SizedBox(width: sizes.GetWidth() * 10),
                              GradientText(
                                widget: Row(
                                  children: [
                                    SvgPicture.asset("assets/icon/dollar.svg",height:sizes.GetHeight()*2),
                                    SizedBox(width: sizes.GetWidth() * 1),
                                    SvgPicture.asset("assets/icon/SAR.svg",height:sizes.GetHeight()*1.2),
                                    SizedBox(width: sizes.GetWidth() * 1),
                                    Text(reviewData?['pricing']?['packaging_fee']?.toString() ?? "0",),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                        ],
                        // Parking
                        if (reviewData?['parking'] != null) ...[
                          Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      "assets/icon/Parking.svg", height: sizes
                                      .GetHeight() * 2.2),
                                  SizedBox(width: sizes.GetWidth() * 1),
                                  Text(textLanguage.GetWord('موقف سيارات')),
                                ],
                              ),
                              SizedBox(height: sizes.GetHeight() * 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GradientText(
                                    widget: Row(
                                      children: [
                                        SvgPicture.asset("assets/icon/dollar.svg",
                                            height: sizes.GetHeight() * 2.2),
                                        SizedBox(width: sizes.GetWidth() * 1),
                                        SvgPicture.asset("assets/icon/SAR.svg",
                                            height: sizes.GetHeight() * 1.4),
                                        SizedBox(width: sizes.GetWidth() * 1),
                                        Text(reviewData!['parking']['fee']
                                            ?.toString() ?? '0'),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset("assets/icon/time.svg",
                                          height: sizes.GetHeight() * 2.2),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text(
                                          "${reviewData['parking']['hours']} hours"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/icon/LocationTable.svg",
                                          height: sizes.GetHeight() * 2.2),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text(reviewData['parking']['location']
                                          ?.toString() ?? ''),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset("assets/icon/ABC.svg",
                                          height: sizes.GetHeight() * 2.2),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text(reviewData['parking']['car_plate']
                                          ?.toString() ?? ''),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/icon/carPainting.svg",
                                          height: sizes.GetHeight() * 2.2),
                                      SizedBox(width: sizes.GetWidth() * 1),
                                      Text(reviewData['parking']['car_color']
                                          ?.toString() ?? ''),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: sizes.GetHeight() * 2),
                        /*
                        // Total
                        PriceRow(
                          labelText:
                          '${textLanguage.GetWord('الإجمالي')} '
                              '(${reviewData?['pricing']?['vat_rate'] == null ? 0 : reviewData?['pricing']?['vat_rate'] * 100}% ${textLanguage.GetWord("شامل الضريبة")})',
                          amount: reviewData?['pricing']?['total']?.toString() ?? '0',

                          sizes: Sizes(context).GetWidth() * 5,
                        ),
                         */
                        PriceRow(
                          labelText:'',
                          amount: reviewData?['pricing']?['total']?.toString() ?? '0',

                          sizes: Sizes(context).GetWidth() * 5,
                        ),
                        SizedBox(height: sizes.GetHeight() * 5),
                        WidgetButton(
                          context: context,
                          buttonText: textLanguage.GetWord("إعادة الحجز"),
                          textColor: theme.GetColor("textPrimary"),
                          width: sizes.GetWidth() * 33,
                          isCircular: true,
                          onPressed: ()async {
                            final booking = widget.bookingDetails;

                            if (booking == null) return;

                            final branchId = (booking['branch'] as Map<String, dynamic>)['id'];
                            final restaurantName =(booking['business'] as Map<String, dynamic>)['name'];
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (_, __, ___) =>
                                    RestaurantDetalis(
                                        title: (restaurantName).toString(),
                                        branchId: branchId),
                                transitionDuration:
                                Duration.zero,
                                reverseTransitionDuration:
                                Duration.zero,
                              ),
                            );
                          },
                          backgroundColor: theme.GetColor("primaryA"),
                        )
                      ]
                  )
              )
          );
        }
      )
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
                height: sizes.GetHeight() * 1.2,
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

  final String tableTitle; // مثل "Table #5"
  final String price; // مثل "1000"
  final String priceSvg; // أيقونة السعر
  final String currencySvg; // أيقونة العملة
  final String extraSvg; // أيقونة إضافية للـ Row الثاني
  final String extraText; // نص إضافي للـ Row الثاني

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
class PriceRow extends StatelessWidget {
  final String labelText; // نص الوصف
  final String amount; // المبلغ
  final double? sizes;
  const PriceRow({
    super.key,
    required this.labelText,
    required this.amount,
    this.sizes,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(labelText,style: sizes!=null?TextStyle(fontSize:sizes):null,),
        GradientText(
          widget: Row(
            children: [
              SvgPicture.asset(height:sizes==null?Sizes(context).GetHeight()*1.8:sizes,"assets/icon/dollar.svg"),
              SizedBox(width:Sizes(context).GetWidth()*1,),
              SvgPicture.asset(height: sizes==null?Sizes(context).GetHeight()*1.8:sizes,"assets/icon/SAR.svg",color:Themes().GetColor("textPrimary"),),
              SizedBox(width:Sizes(context).GetWidth()*1,),
              Text(amount,style: sizes!=null?TextStyle(fontSize:sizes):null),
            ],
          ),
        ),
      ],
    );
  }
}