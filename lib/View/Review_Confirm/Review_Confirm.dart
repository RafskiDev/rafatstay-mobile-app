import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/CountdownText.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../Payment/Payment.dart';
import '../Payment/Payment_riverpod.dart';
import 'Review_Confirm_riverpod.dart';
class Review_Confirm extends ConsumerStatefulWidget {
  final String? name;
  final Map<String, dynamic> bookingData;
  const Review_Confirm({super.key, required this.bookingData, this.name});

  @override
  ConsumerState<Review_Confirm> createState() => _Review_ConfirmState();
}

class _Review_ConfirmState extends ConsumerState<Review_Confirm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       ref.read(Review_Confirm_riverpod.notifier).loadFromBookingData(widget.bookingData);
       final bookingId = widget.bookingData["id"];
       ref.read(Review_Confirm_riverpod.notifier).fetchReview(context, bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Review_Confirm_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final items = ref.watch(Review_Confirm_riverpod.notifier).items;
    final tablePrice = double.tryParse(widget.bookingData["table_price"]?.toString() ?? '0') ?? 0;

    return  Scaffold(
      appBar:buildCustomAppBar(context,textLanguage.GetWord("مراجعة وتأكيد")),
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
                  Text(widget.name ?? "",style: TextStyle(color:theme.GetColor("primary"),fontWeight: FontWeight.bold,decoration: TextDecoration.underline,decorationColor:theme.GetColor("primary"))),
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
                      padding:EdgeInsets.symmetric(horizontal:sizes.GetHeight()*0.2),
                      child: BadgeBox(
                        sizes: sizes,
                        theme: theme,
                        text: items[index]["title"].toString(),
                        svgPath:items[index]["image"].toString(),
                      ),
                    );
                  },
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
                      SizedBox(width:sizes.GetWidth()*1,),
                      CountdownText(bookingData: widget.bookingData),
                    ],
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              InfoRow(
                title: textLanguage.GetWord('السعر الإجمالي للوجبات'),
                value: ref.watch(Review_Confirm_riverpod.notifier).mealsTotal,
                icons: ["assets/icon/dollar.svg", "assets/icon/SAR.svg"],
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              InfoRow(
                title: textLanguage.GetWord("سعر الطاولة"),
                value:tablePrice.toString(),
                icons: ["assets/icon/dollar.svg", "assets/icon/SAR.svg"],
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              InfoRow(
                title: textLanguage.GetWord("سعر الموقف"),
                value: ref.watch(Review_Confirm_riverpod.notifier).parkingFee,
                icons: ["assets/icon/dollar.svg", "assets/icon/SAR.svg"],
              ),
              SizedBox(height: sizes.GetHeight() * 1),
              InfoRow(
                title: "",//Total (15% VAT Included)
                value: ref.watch(Review_Confirm_riverpod.notifier).total,
                size: sizes.GetHeight() * 2.5,
                icons: ["assets/icon/dollar.svg", "assets/icon/SAR.svg"],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              SquareButton(
                width: sizes.GetWidth() * 50,
                height: sizes.GetHeight() * 5,
                onTap: ()async {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                       Payment(
                         bookingId: widget.bookingData["id"],
                         bookingType: "booking",
                         restaurantDetails:widget.bookingData,
                       ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      textLanguage.GetWord("دفع"),
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
                backgroundColor:theme.GetColor("primary"),
                borderRadius:sizes.GetWidth()*10,
              ),
            ]
          )
        )
      )
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
      width: sizes.GetWidth() * 22,
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
class InfoRow extends StatelessWidget {
  final String title;          // النص على اليسار
  final String value;          // الرقم أو القيمة
  final List<String> icons;    // مسارات الصور (SVG)
  final double? size;


  const InfoRow({
    super.key,
    required this.title,
    required this.value,
    required this.icons,
     this.size,
  });

  @override
  Widget build(BuildContext context) {
    Themes theme = Themes();
    Sizes sizes = Sizes(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:size==null? TextStyle(fontSize: sizes.GetHeight() * 2):TextStyle(fontSize: size),
        ),
        Row(
          children: [
            ...icons.map((icon) => Padding(
              padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
              child: SvgPicture.asset(
                icon,
                color: theme.GetColor("textPrimary"),
                width:size?? sizes.GetHeight() * 2,
              ),
            )),
            Text(
              value,
              style:size==null? TextStyle(fontSize: sizes.GetHeight() * 2):TextStyle(fontSize: size),
            ),
          ],
        ),
      ],
    );
  }
}
