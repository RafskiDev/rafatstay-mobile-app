import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../Credit/Credit.dart';
import '../Home/Home_riverpod.dart';
import '../Maps/Maps.dart';
import '../PaymentWebView/PaymentWebView.dart';
import '../PayusingyourSTCPaywallet/PayusingyourSTCPaywallet.dart';
import '../PaywithMada/PaywithMada.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
import 'Payment_riverpod.dart';
class Payment extends ConsumerWidget {
  final int? bookingId;
  final String? bookingType;
  final Map<String, dynamic>? eventData;
  final Map<String, dynamic>? restaurantDetails;
  const Payment({
    super.key,
     this.bookingId,
     this.bookingType,
     this.eventData,
     this.restaurantDetails,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(Payment_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    print("bookingId:$bookingId");
    TextLanguage textLanguage = TextLanguage();
    final selected = ref.watch(Payment_riverpod);
    final url =  ref.read(Payment_riverpod.notifier)
        .initiatePayment(context, 1,0);
    return  Scaffold(
      appBar:buildCustomAppBar(context,"Payment"),
      backgroundColor:theme.GetColor("background"),
      body:Container(
        padding:EdgeInsets.symmetric(horizontal: sizes.GetWidth()*2),
        child:SingleChildScrollView(
          child:Column(
            children: [
              StepsWidget(),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                children: [
                  Expanded(
                    child: Text(
                       textLanguage.GetWord('اختر طريقة الدفع المفضلة لديك وأكمل طلبك بسهولة.'),
                      style: TextStyle(color:theme.GetColor("textSecondary")),
                    ),
                  ),
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              CheckBoxBox(isSelected: 0, title:textLanguage.GetWord("ادفع باستخدام مدى"), image: "assets/images/PaywithMada.png",),
              SizedBox(height:sizes.GetHeight()*2,),
              CheckBoxBox(isSelected: 1, title:textLanguage.GetWord('بطاقة ائتمان / بطاقة خصم'), image: "assets/images/CreditDebitCard.png",),
              SizedBox(height:sizes.GetHeight()*2,),
              CheckBoxBox(isSelected: 2, title: textLanguage.GetWord('ادفع باستخدام محفظة STC Pay الخاصة بك'), image: "assets/images/PayusingyourSTCPaywallet.png",),
              SizedBox(height:sizes.GetHeight()*2,),
              CheckBoxBox(isSelected: 3, title:textLanguage.GetWord('نقدي'), image: "assets/icon/Cash.svg",),
              SizedBox(height:sizes.GetHeight()*2,),
              (selected != 0 && selected != 1 && selected != 2 && selected != 3)?Container(
                width:double.infinity,
                height:sizes.GetHeight()*25,
                decoration:BoxDecoration(
                  color:Themes().GetColor("backgroundOffWhite"),
                  borderRadius: BorderRadius.circular(sizes.GetWidth()*4),
                ),
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(textLanguage.GetWord('ادفع بالتقسيط')),
                        ],
                      ),
                      SizedBox(height:sizes.GetHeight()*2,),
                      CheckBoxBox(isSelected: 4, title:textLanguage.GetWord('قطة مخططة'), image: "assets/images/Tabby.png",),
                      SizedBox(height:sizes.GetHeight()*2,),
                      CheckBoxBox(isSelected: 5, title:textLanguage.GetWord('تامارا'), image: "assets/images/Tamara.png",),
                    ],
                  ),
                ),
              ):SizedBox.shrink(),
              SizedBox(height:sizes.GetHeight()*2,),
              SquareButton(
                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 6,
                onTap: () async {
                  final selectedMethod = ref.read(Payment_riverpod);
                  if (selectedMethod == -1) return; // لم يتم اختيار شيء

                  final notifier = ref.read(Payment_riverpod.notifier);
                  final methodKeys = {
                    0: "mada",
                    1: "credit_card",
                    2: "stc_pay",
                    3: "cash",
                    4: "tabby",
                    5: "tamara",
                  };
                  final methodKey = methodKeys[selectedMethod] ?? "";

                  // --- وظيفة مساعدة لمعالجة الدفع عبر الإنترنت ---
                  Future<void> handleOnlinePayment(int id) async {
                    final result = await notifier.payBooking(
                      context: context,
                      bookingId: id,
                      paymentMethod: methodKey,
                      redirectUrl: "https://rafatstay.com/payment/callback",
                    );
                    if (!context.mounted) return;

                    if (result is String && result.isNotEmpty) {
                      // ننتظر النتيجة من صفحة الـ WebView
                      final paymentStatus = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentWebView(url: result),
                        ),
                      );
                      // بعد العودة، نتحقق من الحالة ونظهر رسالة
                      if (!context.mounted) return;
                      if (paymentStatus == "success") {
                        ToastMessages(context, textLanguage.GetWord("تمت عملية الدفع بنجاح"), Colors.green, Colors.white);
                      } else if (paymentStatus == "failed") {
                        ToastMessages(context, textLanguage.GetWord("فشلت عملية الدفع، يرجى المحاولة مرة أخرى"), Colors.red, Colors.white);
                      }
                    }
                  }

                  // --- وظيفة مساعدة لإظهار دايالوج الكاش ---
                  Future<void> showCashDialog(int bookingId) async {
                    // (نفس الكود الخاص بالدايالوج الذي وضعته سابقاً)
                    WidgetCustomDialog(
                      context,
                      barrierDismissible: false,
                      backgroundColor: Themes().GetColor("backgroundOffWhite"),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset("assets/icon/cash_payment.svg"),
                          Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: Sizes(context).GetHeight() * 2.2),
                            textLanguage.GetWord('سيتم إضافة رسوم خدمة بنسبة 5% عند اختيار الدفع النقدي.'),
                          ),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          SquareButton(
                            width: sizes.GetWidth() * 50,
                            height: sizes.GetHeight() * 6,
                            onTap: () => Navigator.pop(context),
                            child: Text(textLanguage.GetWord("ادفع عبر الإنترنت")),
                            backgroundColor: theme.GetColor("primary"),
                            borderRadius: sizes.GetWidth() * 10,
                          ),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          SquareButton(

                            width: sizes.GetWidth() * 50,

                            height: sizes.GetHeight() * 6,

                            onTap: () async {
                              Navigator.pop(context);
                              final success = await notifier.payBooking(
                                context: context,
                                bookingId: bookingId,
                                paymentMethod: "cash",
                              );
                              if (success) {
                                final id = restaurantDetails!["id"];
                                final restaurantDetalis = ref.read(RestaurantDetalis_riverpod.notifier);
                                final branch = restaurantDetalis.branches[0];
                                if(branch['latitude']!=null && branch['longitude']!=null) {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, a1, a2) =>
                                          Maps(
                                            restaurantLat: double.parse(branch['latitude'].toString()),
                                            restaurantLng: double.parse(branch['longitude'].toString()),
                                            data: [
                                              {
                                                "id": id,
                                                "RouteInfoCard": true
                                              },
                                            ],
                                          ),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(textLanguage.GetWord("الدفع النقدي")),
                            backgroundColor: theme.GetColor("backgroundOffWhite"),
                            borderColor: theme.GetColor("textPrimary"),
                            borderRadius: sizes.GetWidth() * 10,
                          ),
                        ],
                      ),
                    );
                  }

                  // --- المنطق الأساسي للتنفيذ ---

                  int? finalBookingId = bookingId;
                  // 1. إذا كان نوع الحجز فعالية (Event)، نحتاج لإنشاء الحجز أولاً
                  if (bookingType == "event" && eventData != null) {
                    // ... (نفس كود جلب الـ availability و createBooking الذي وضعته)
                    final availRes = await ApiService().get(
                      "v1/guest/branches/${eventData!["branch_id"]}/availability",
                      {"date": eventData!["starts_at"].toString().split(" ")[0]},
                      context,
                    );
                    final slots = availRes?["data"]?["time_slots"] as List? ?? [];
                    final availableSlot = slots.firstWhere((s) => s["is_available"] == true, orElse: () => {});

                    if (availableSlot.isEmpty) return;

                    final homeNotifier = ref.read(Home_riverpod.notifier);
                    await homeNotifier.fetchMenus(context, eventData!["branch_id"]);
                    final eventItem = homeNotifier.allMeals.firstWhere((m) => m["item_type"] == "event", orElse: () => {});

                    if (eventItem.isEmpty) return;

                    final booking = await notifier.createBooking(
                      context: context,
                      bookingData: {
                        "branch_id": eventData!["branch_id"],
                        "booking_date": eventData!["starts_at"].toString().split(" ")[0],
                        "start_time": availableSlot["start_time"].toString().substring(0, 5),
                        "end_time": availableSlot["end_time"].toString().substring(0, 5),
                        "party_size": 1,
                        "service_mode": "dine_in",
                        "menuItems": [{"id": eventItem["id"], "title": eventItem["name"]}],
                      },
                    );

                    if (booking != null) {
                      finalBookingId = booking["data"]["id"];
                    }
                  }

                  // 2. الآن نقوم بتوجيه المستخدم بناءً على وسيلة الدفع
                  if (finalBookingId != null) {
                    if (selectedMethod == 3) {
                      // إذا اختار كاش
                      await showCashDialog(finalBookingId);
                    } else {
                      // أي وسيلة أخرى (مدى، فيزا، تابي...) تفتح الـ WebView
                      await handleOnlinePayment(finalBookingId);
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      textLanguage.GetWord("التالي"),
                    ),
                    SizedBox(width: sizes.GetWidth() * 1),
                    SvgPicture.asset(
                      "assets/icon/arrow.svg",
                    ),
                  ],
                ),
                backgroundColor:ref.watch(Payment_riverpod) != -1 ?theme.GetColor("primary"):theme.GetColor("primaryS"),
                borderRadius: sizes.GetWidth()*10,
              ),
            ]
          )
        )
      ),

    );
  }
}

class CheckBoxBox extends ConsumerWidget {
  final int isSelected;
  final String title;
  final String image;

  const CheckBoxBox({
    super.key,
    required this.isSelected,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(Payment_riverpod);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: selected == isSelected
            ? LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Themes().GetColor("textPrimary"),
            Themes().GetColor("primaryA"),
          ],
        )
            : null,
        border: selected != isSelected
            ? Border.all(
          color: Themes().GetColor("background"),
          width: 0.6,
        )
            : null,
        boxShadow: selected != isSelected
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 1,
            offset: Offset(1, 1),
            spreadRadius: 0,
          ),
        ]
            : null,
      ),
      child: Container(
        margin: EdgeInsets.all(selected == isSelected ? 0.6 : 0), // سمك البوردر
        decoration: BoxDecoration(
          color: Themes().GetColor("background"),
          borderRadius: BorderRadius.circular(29.4),
        ),
        child: Container(
          padding: EdgeInsets.all(8.0),
          height: Sizes(context).GetHeight() * 7,
          child: Row(
            children: [
              CheckBox(
                height: Sizes(context).GetHeight() * 2.8,
                value: isSelected,
                borderColor: selected != isSelected
                    ? Colors.grey
                    : Themes().GetColor("textPrimary"),
                groupValue: selected,
                onChanged: (int value) {
                  ref.read(Payment_riverpod.notifier).selectIndex(value);
                },
              ),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              title == TextLanguage().GetWord('نقدي') ?SvgPicture.asset(image):Image.asset(image, height:title=="Tabby"? Sizes(context).GetHeight() * 1.2:Sizes(context).GetHeight() * 3),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class StepsWidget extends StatelessWidget {
  const StepsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StepCircle(number: "1", size: Sizes(context).GetWidth()*14, color:Themes().GetColor("secondary500")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepLine(height:Sizes(context).GetWidth()*2.5,width: Sizes(context).GetWidth()*25, color:Themes().GetColor("textSecondary")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepCircle(number: "2", size: Sizes(context).GetWidth()*14, color:Themes().GetColor("primaryS")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepLine(height:Sizes(context).GetWidth()*2.5,width: Sizes(context).GetWidth()*25, color:Themes().GetColor("textSecondary")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepCircle(number: "3", size: Sizes(context).GetWidth()*14, color:Themes().GetColor("primaryS") ),
      ],
    );
  }
}

class StepCircle extends StatelessWidget {
  final String number;
  final double size;
  final Color color;

  const StepCircle({
    super.key,
    required this.number,
    this.size = 50,
    this.color = Colors.blue,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
class StepLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const StepLine({
    super.key,
    required this.width,
    this.height = 4,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      width: width,
      height: height,
    );
  }
}