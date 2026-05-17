import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rafatstay/View/Payment/Payment.dart';
import 'package:gal/gal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/ReviewCard.dart';
import '../../Widget/Ticket.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../../Widget/WidgetTextField.dart';
import '../BottomBar/BottomBar.dart';
import '../Credit/Credit.dart';
import '../PayusingyourSTCPaywallet/PayusingyourSTCPaywallet.dart';
import '../PaywithMada/PaywithMada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import 'PayNow_riverpod.dart';
import 'package:rafatstay/Widget/Ticket.dart' show Ticket;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
class PayNow extends ConsumerWidget {
  PayNow({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
  //  ref.watch(Payment_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return  Scaffold(
      appBar:buildCustomAppBar(context,"PayNow"),
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
                  Text(textLanguage.GetWord('استخدم بطاقة مدين مادا الخاصة بك'),style: TextStyle(color:theme.GetColor("textSecondary")),),
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              WidgetTextField(
                isPassword: false,
                Controller: ref.read(PayNow_riverpod.notifier).cardNumberController,
                HintText:"0000   0000   0000   0000",
                iconData:"assets/icon/CardNumber.svg",
                focusNode: ref.read(PayNow_riverpod.notifier).cardNumberControllerNode,
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              WidgetTextField(
                isPassword: false,
                Controller: ref.read(PayNow_riverpod.notifier).cardholderNameController,
                HintText:"Anas Ahmed",
                iconData:"assets/icon/CardholderName.svg",
                focusNode: ref.read(PayNow_riverpod.notifier).cardholderNameControllerNode,
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width:sizes.GetWidth()*45,
                    child: WidgetTextField(
                      isPassword: false,
                      Controller: ref.read(PayNow_riverpod.notifier).expiryDateController,
                      HintText:"12/12",
                      iconData:"assets/icon/ExpiryDate.svg",
                      focusNode: ref.read(PayNow_riverpod.notifier).expiryDateControllerNode,
                    ),
                  ),
                  SizedBox(
                    width:sizes.GetWidth()*45,
                    child: WidgetTextField(
                      keyboardType: TextInputType.number,
                      inputFormattersList: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      isPassword: false,
                      Controller: ref.read(PayNow_riverpod.notifier).cVVController,
                      HintText:"123",
                      iconData:"assets/icon/cvv.svg",
                      focusNode: ref.read(PayNow_riverpod.notifier).cVVControllerNode,
                    ),
                  ),
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                children: [
                  CheckBoxSvg(
                    onChanged:(bool value) {
                     // ref.read(PayNow_riverpod.notifier).checkBoxSvg(value);
                    },
                    initialValue: false,
                  ),
                  SizedBox(width:sizes.GetWidth()*1,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textLanguage.GetWord('حفظ معلومات البطاقة')),
                    ],
                  ),
                  SizedBox(width:sizes.GetWidth()*1,),
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              PriceRow(
                labelText:TextLanguage().GetWord("السعر الإجمالي للوجبات"),
                amount: '2300',
               ),
              SizedBox(height:sizes.GetHeight()*2,),
              PriceRow(
                labelText:TextLanguage().GetWord("سعر الطاولة"),
                amount: '2300',
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              PriceRow(
                labelText:TextLanguage().GetWord("سعر الموقف"),
                amount: '2300',
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              PriceRow(
                labelText:'${TextLanguage().GetWord('الإجمالي')} (${15}% ${TextLanguage().GetWord('شامل الضريبة')})',
                amount: '2300',
                sizes:Sizes(context).GetWidth()*5,
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              SquareButton(
                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 6,
                onTap: () {
                  showOtpDialog(context);
                  /*
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          PayNow(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );

                   */
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${TextLanguage().GetWord('يدفع')} ${"2,500"}",
                    ),
                    SizedBox(width: sizes.GetWidth() * 1),
                    SvgPicture.asset(
                      "assets/icon/SAR.svg",
                      color: theme.GetColor("textPrimary"),
                    ),
                  ],
                ),
                backgroundColor:theme.GetColor("primary"),
                borderRadius: sizes.GetWidth()*10,
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              SquareButton(
                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 6,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => Payment(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                        (route) => false, // هذا يحذف كل الوجهات السابقة
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TextLanguage().GetWord('تغيير طريقة الدفع'),
                    ),
                  ],
                ),
                backgroundColor:theme.GetColor("background"),
                borderRadius: sizes.GetWidth()*10,
                borderColor:theme.GetColor("primary"),
              ),
            ],
          ),
        ),
      )

    );
  }

  Future<void> showOtpDialog(BuildContext context) {
    return WidgetCustomDialog(
      barrierDismissible:false,
      backgroundColor:Themes().GetColor("background"),
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: Sizes(context).GetHeight() * 2),
          CustomOtpWidget(
            fieldCount: 4, // عدد خانات OTP
            onVerify: (otp) async {
              // ضع هنا منطق التحقق من OTP
              print("OTP entered: $otp");
              // مثال: تحقق وهمي، إذا كان "1234" صحيح
              if (otp == "1234") {
                return true;
              }
              return false;
            },
          ),

          SizedBox(height: Sizes(context).GetHeight() * 2),
          Text(
            TextLanguage().GetWord('رمز التحقق لمرة واحدة لإتمام عملية الدفع. معلوماتك آمنة تمامًا.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes(context).GetHeight() * 2.5,
              color: Themes().GetColor("textPrimary"),
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight() * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${TextLanguage().GetWord('متوفر في')} ${30} ${TextLanguage().GetWord('ثوانٍ')}",
                style: TextStyle(
                  color: Themes().GetColor("textSecondary"),
                ),
              ),
              Text(
                "20 s",
                style: TextStyle(
                  color: Themes().GetColor("textSecondary"),
                ),
              ),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight() * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SquareButton(
                width: Sizes(context).GetWidth() * 30,
                height: Sizes(context).GetHeight() * 5,
                onTap: () {

                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TextLanguage().GetWord("إعادة إرسال الرمز"),
                    ),
                  ],
                ),
                backgroundColor:Themes().GetColor("background"),
                borderRadius: Sizes(context).GetWidth()*10,
                borderColor:Themes().GetColor("primary"),
              ),
              SquareButton(
                width: Sizes(context).GetWidth() * 45,
                height: Sizes(context).GetHeight() * 5,
                onTap: () async {
                  Navigator.pop(context);
                  await showDialogSuccessful(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TextLanguage().GetWord('تأكيد الدفع'),
                    ),
                  ],
                ),
                backgroundColor:Themes().GetColor("primary"),
                borderRadius: Sizes(context).GetWidth()*10,
              ),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
        ],
      ),
    );
  }
  Future<void> showDialogSuccessful(BuildContext context) {
    final GlobalKey ticketKey = GlobalKey();
    return WidgetCustomDialog(
      barrierDismissible:false,
      backgroundColor:Themes().GetColor("background"),
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
             key: ticketKey,
            child: Ticket(
              bookingNumber: 300,
              payAmount: 2500,
              checkInDate: "10/1",
              checkInTime: "12:00",
              childrenCount: 0,
              tableNumber: "5 Indoor",
              width: Sizes(context).GetWidth() * 80,
              height: Sizes(context).GetHeight() * 30,
              party_size: 0,
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight() * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularButton(
                  size: Sizes(context).GetHeight() * 6,
                onTap: () {
                  shareTicket(context,ticketKey);
                },
                backgroundColor:Themes().GetColor("backgroundLight"),
                borderColor: Colors.transparent,
                child:SvgPicture.asset("assets/icon/sharing.svg",height: Sizes(context).GetHeight()*3)
              ),
              SizedBox(width: Sizes(context).GetWidth() * 3),
              CircularButton(
                  size: Sizes(context).GetHeight() * 6,
                  onTap: () {
                    downloadTicket(context,ticketKey);
                  },
                  backgroundColor:Themes().GetColor("backgroundLight"),
                  borderColor: Colors.transparent,
                  child:SvgPicture.asset("assets/icon/download.svg",height: Sizes(context).GetHeight()*3)
              ),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight() * 2),
          Text(
            TextLanguage().GetWord("تمت عملية الدفع بنجاح! سنقوم بتجهيز طلبك في الموعد المحدد."),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes(context).GetHeight() * 2.5,
              color: Themes().GetColor("textPrimary"),
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight() * 2),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SquareButton(
                width: Sizes(context).GetWidth() * 45,
                height: Sizes(context).GetHeight() * 5,
                onTap: () {

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BottomBar(initialIndex:3)),
                        (route) => false,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TextLanguage().GetWord("عرض الحجز"),
                    ),
                  ],
                ),
                backgroundColor:Themes().GetColor("primary"),
                borderRadius: Sizes(context).GetWidth()*10,
              ),
              SizedBox(height: Sizes(context).GetHeight() * 1),
              SquareButton(
                width: Sizes(context).GetWidth() * 45,
                height: Sizes(context).GetHeight() * 5,
                onTap: ()  {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BottomBar()),
                        (route) => false,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TextLanguage().GetWord("العودة إلى الصفحة الرئيسية"),
                    ),
                  ],
                ),
                backgroundColor:Themes().GetColor("background"),
                borderRadius: Sizes(context).GetWidth()*10,
                borderColor:Themes().GetColor("primary"),
              ),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
        ],
      ),
    );
  }
  Future<void> shareTicket(BuildContext context,GlobalKey ticketKey) async {
    try {
      final String url = "https://yourapp.com/booking/";

      await Share.share(
        "تذكرة الحجز رقم \n\nشاهد التفاصيل عبر الرابط:\n$url",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشلت المشاركة: $e')),
      );
    }
  }
  Future<void> downloadTicket(BuildContext context,GlobalKey ticketKey) async {
    try {
      // التقط صورة التذكرة
      final boundary = ticketKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // احفظ مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(pngBytes);

      // احفظ في الاستوديو
      await Gal.putImage(filePath);
      ToastMessages(context,'تم الحفظ',Themes().GetColor("success"),Themes().GetColor("white"));
    } catch (e) {
      if (e.toString().contains('permission')) {
        ToastMessages(context,'❌ يرجى منح إذن الوصول للصور',Themes().GetColor("error"),Themes().GetColor("white"));
      } else {
        ToastMessages(context,'فشل الحفظ',Themes().GetColor("error"),Themes().GetColor("white"));
      }
    }
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
        StepLine(height:Sizes(context).GetWidth()*2.5,width: Sizes(context).GetWidth()*25, color:Themes().GetColor("secondary500")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepCircle(number: "2", size: Sizes(context).GetWidth()*14, color:Themes().GetColor("secondary500")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepLine(height:Sizes(context).GetWidth()*2.5,width: Sizes(context).GetWidth()*25, color:Themes().GetColor("secondary500")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepCircle(number: "3", size: Sizes(context).GetWidth()*14, color:Themes().GetColor("secondary500") ),
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
        Row(
          children: [
            SvgPicture.asset(height:sizes==null?Sizes(context).GetHeight()*1.8:sizes,"assets/icon/dollar.svg"),
            SizedBox(width:Sizes(context).GetWidth()*1,),
            SvgPicture.asset(height: sizes==null?Sizes(context).GetHeight()*1.8:sizes,"assets/icon/SAR.svg",color:Themes().GetColor("textPrimary"),),
            SizedBox(width:Sizes(context).GetWidth()*1,),
            Text(amount,style: sizes!=null?TextStyle(fontSize:sizes):null),
          ],
        ),
      ],
    );
  }
}
