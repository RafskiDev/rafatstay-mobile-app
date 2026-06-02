import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../AvailableTables/AvailableTables_riverpod.dart';
import '../Booking/Widget/Cancelled.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../OffersDetails/OffersDetails_riverpod.dart';
import '../Payment/Payment_riverpod.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
import '../Review_Confirm/Review_Confirm.dart';
import 'BookingDetails_riverpod.dart';
class BookingDetails extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;
  const BookingDetails({super.key, required this.bookingData});

  @override
  ConsumerState<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends ConsumerState<BookingDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(BookingDetails_riverpod.notifier).loadFromBookingData(widget.bookingData);
     // ref.read(BookingDetails_riverpod.notifier).fetchBookingDetails(context, widget.bookingData["id"]);
    });
  }
 
  @override
  Widget build(BuildContext context) {
    ref.watch(BookingDetails_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final garage = ref.watch(RestaurantDetalis_riverpod.notifier).garage;
    final items = ref.watch(BookingDetails_riverpod.notifier).items;
    final includedItems = ref.read(OffersDetails_riverpod.notifier).includedItems;
    final menuItems = ref.read(MakeItYourWay_riverpod.notifier).menuItems;
    final menuItems_ = (menuItems.isNotEmpty)
        ? menuItems
        : (includedItems.isNotEmpty)
        ? includedItems
        : <Map<String, dynamic>>[];
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
    final pageNotifier = ref.watch(BookingDetails_riverpod.notifier);
    return  Scaffold(
      appBar:buildCustomAppBar(context,textLanguage.GetWord("تفاصيل الحجز")),
      backgroundColor:theme.GetColor("background"),
      body:Container(
        padding:EdgeInsets.symmetric(horizontal: sizes.GetWidth()*2),
        child:SingleChildScrollView(
          child:Column(
            children: [
              Row(
                children: [
                  Container(
                    width: sizes.GetHeight() * 4.2,
                    height: sizes.GetHeight() * 4.2,
                    decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color:theme.GetColor("secondaryPrimary"),
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
                  )
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    items.length,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: sizes.GetHeight() * 0.2),
                      child: BadgeBox(
                        sizes: sizes,
                        theme: theme,
                        text: items[index]["title"].toString(),
                        svgPath: items[index]["image"].toString(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(textLanguage.GetWord("الوقت المتبقي"),style: TextStyle(fontWeight: FontWeight.bold),),
                  Row(
                    children: [
                      SvgPicture.asset(height:sizes.GetHeight()*2,"assets/icon/SandGlass.svg",color:theme.GetColor("textPrimary"),),
                      Text(DateTimeHelper().getRemainingTime(widget.bookingData)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                children: [
                  GradientText(
                    widget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/icon/MealDetails.svg",
                          height: sizes.GetHeight() * 2,
                        ),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(
                          textLanguage.GetWord("تفاصيل الوجبة"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => SizedBox(height: sizes.GetHeight() * 2),
                  itemCount: menuItems_.length,
                  itemBuilder:(_,index){
                  final item = menuItems_[index];
                  return MealInfoRow(
                    sizes: sizes,
                    theme: theme,
                    title:item["title"].toString(),
                    price:item["price"].toString(),
                    priceSvg: "assets/icon/dollar.svg",
                    currencySvg: "assets/icon/SAR.svg",
                    mealsSvg: "assets/icon/MealDetails.svg",
                    mealsCount:item["count"].toString(),
                    mealsText:textLanguage.GetWord("وجبات الطعام"),
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
              /*
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icon/TableDetails.svg",
                    height: sizes.GetHeight() * 3,
                  ),
                  SizedBox(width: sizes.GetWidth() * 1),
                  Text(textLanguage.GetWord('تفاصيل الجدول'),style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
               */
              SizedBox(height: sizes.GetHeight() * 1),
              Container(
                padding: EdgeInsets.all(sizes.GetWidth() * 3),
                decoration: BoxDecoration(
                  color: Themes().GetColor("backgroundOffWhite"),
                  borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                ),
                child: TableInfoRow(
                  sizes: sizes,
                  theme: theme,
                  tableTitle: "${textLanguage.GetWord('طاولة')} ${(widget.bookingData['table_name']?.toString() ?? "Table").replaceAll(RegExp(r'table\s*', caseSensitive: false), '')}",
                  price:widget.bookingData['table_price']?.toString() ?? "0",
                  priceSvg: "assets/icon/dollar.svg",
                  currencySvg: "assets/icon/SAR.svg",
                  extraSvg: "assets/icon/LocationTable.svg",
                  extraText:pageNotifier.translateMode(widget.bookingData['location_type']?.toString()),
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icon/TableDetails.svg",
                    height: sizes.GetHeight() * 3,
                  ),
                  SizedBox(width: sizes.GetWidth() * 1),
                  Text(textLanguage.GetWord('حجز موقف السيارات'),style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              Row(
                children: [
                  Text(textLanguage.GetWord('هل تحتاج إلى موقف سيارات'),style: TextStyle(color:theme.GetColor("textSecondary"))),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              Row(
                children: [
                  CheckBox<int>(
                    height:sizes.GetHeight()*3,
                    value: 0,
                    borderColor:theme.GetColor("textSecondary"),
                    groupValue: (ref.watch(BookingDetails_riverpod) & 1) != 0 ? 0 : -1,
                    onChanged: (val) {
                      ref.read(BookingDetails_riverpod.notifier).selectIndex(val);
                    },
                  ),
                  Text(textLanguage.GetWord("أحتاج إلى موقف سيارة")),
                ],
              ),
              ref.watch(BookingDetails_riverpod)==1?SizedBox(height: sizes.GetHeight() * 1):SizedBox.shrink(),
              ref.watch(BookingDetails_riverpod)==1 && garage.isNotEmpty ?Row(
                children: [
                  GradientText(
                    widget: Row(
                      children: [
                        SvgPicture.asset("assets/icon/dollar.svg",height:sizes.GetHeight()*2),
                        SizedBox(width: sizes.GetWidth() * 1),
                        SvgPicture.asset("assets/icon/SAR.svg",color:theme.GetColor("textPrimary"),height:sizes.GetHeight()*1.5),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(garage[0]["price"]?.toString() ?? "0"),
                      ],
                    ),
                  ),
                  SizedBox(width: sizes.GetWidth() * 10),
                  Row(
                    children: [
                      SvgPicture.asset("assets/icon/time.svg",height:sizes.GetHeight()*2),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(garage[0]["duration"]?.toString()??""),
                    ],
                  ),
                  SizedBox(width: sizes.GetWidth() * 10),
                  Row(
                    children: [
                      SvgPicture.asset("assets/icon/LocationTable.svg",height:sizes.GetHeight()*2),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(garage[0]['parking_type']?.toString() ?? "null"),
                    //  SizedBox(width: sizes.GetWidth() * 2),
                    //  Text("(${garage[0]['parking_type']?.toString() ?? "null"})",style: TextStyle(color:theme.GetColor("primary")),),
                    ],
                  ),
                ],
              ):SizedBox.shrink(),
              ref.watch(BookingDetails_riverpod)==1?SizedBox(height: sizes.GetHeight() * 1):SizedBox.shrink(),
              Visibility(
                visible: (ref.watch(BookingDetails_riverpod) & 1) != 0,
                child: WidgetTextField(
                  isPassword: false,
                  Controller: ref.read(BookingDetails_riverpod.notifier).CarPlate,
                  HintText:textLanguage.GetWord("أدخل رقم لوحة السيارة"),
                  iconData:"assets/icon/carplate.svg",
                  focusNode: ref.read(BookingDetails_riverpod.notifier).CarPlateNode,
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              Visibility(
                visible:(ref.watch(BookingDetails_riverpod) & 1) != 0,
                child: WidgetTextField(
                  isPassword: false,
                  Controller: ref.read(BookingDetails_riverpod.notifier).CarColor,
                  HintText:textLanguage.GetWord("أدخل لون السيارة"),
                  iconData:"assets/icon/CarColor.svg",
                  focusNode: ref.read(BookingDetails_riverpod.notifier).CarColorNode,
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              Row(
                children: [
                  CheckBox<int>(
                    height:sizes.GetHeight()*3,
                    value: 1,
                    borderColor:theme.GetColor("textSecondary"),
                    groupValue: (ref.watch(BookingDetails_riverpod) & 2) != 0 ? 1 : -1,
                    onChanged: (val) {
                      ref.read(BookingDetails_riverpod.notifier).selectIndex(val);
                    },
                  ),
                  Text(textLanguage.GetWord("لست بحاجة إلى موقف سيارات")),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              SquareButton(
                isLoading:ref.watch(BookingDetails_riverpod.notifier).isLoading,
                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 5,
                onTap: ()async {
                  if (ref.read(BookingDetails_riverpod) != 0) {
                    ref.read(BookingDetails_riverpod.notifier).isLoading = true;
                    final enrichedBookingData = {
                      ...widget.bookingData,
                      'menuItems':menuItems_,
                    };
                    ref.read(BookingDetails_riverpod.notifier).isLoading = false;
                    final response = await ref.read(Payment_riverpod.notifier).createBooking(
                      context: context,
                      bookingData: enrichedBookingData,
                    );
                    ref.read(BookingDetails_riverpod.notifier).isLoading = false;
                    if (response?["success"] == true) {
                      enrichedBookingData["id"] = response!["data"]["id"];
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              Review_Confirm(bookingData: enrichedBookingData,name:widget.bookingData["businessName"],),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }else {
                      ToastMessages(context,response!["message"],Colors.red,Colors.white);
                    }

                  }

                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      textLanguage.GetWord("مراجعة وتأكيد"),
                    ),
                    SizedBox(width: sizes.GetWidth() * 1),
                    Transform.flip(
                      flipX: ref.read(MakeItYourWay_riverpod.notifier).storage.read("Language") == 1,
                      child: SvgPicture.asset(
                        "assets/icon/arrow.svg",
                      ),
                    ),
                  ],
                ),
                backgroundColor:ref.read(BookingDetails_riverpod) == 0?theme.GetColor("primaryS"):theme.GetColor("primary"),
                borderRadius:sizes.GetWidth()*10,
              ),
              SizedBox(height:sizes.GetHeight()*7,),
            ]
          )
        )
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
      width: sizes.GetWidth() * 27,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: sizes.GetHeight() * 1),
          SvgPicture.asset(
            svgPath,                     // هنا نستخدم البراميتر
            height: sizes.GetHeight() * 4,
            color: theme.GetColor("primary"),
          ),
          SizedBox(height: sizes.GetHeight() * 1),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 11),
            ),
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



        // معلومات إضافية
        Row(
          children: [
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
            SizedBox(width: sizes.GetWidth() * 2),
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