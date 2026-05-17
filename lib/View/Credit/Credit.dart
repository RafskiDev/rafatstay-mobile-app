import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../PayNow/PayNow.dart';
import 'Credit_riverpod.dart';
class Credit extends ConsumerWidget {
  Credit({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(Credit_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return  Scaffold(
      appBar:buildCustomAppBar(context,"Credit"),
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
                      Controller: ref.read(Credit_riverpod.notifier).cardNumberController,
                      HintText:textLanguage.GetWord("رقم البطاقة"),
                      iconData:"assets/icon/CardNumber.svg",
                      focusNode: ref.read(Credit_riverpod.notifier).cardNumberControllerNode,
                    ),
                    SizedBox(height:sizes.GetHeight()*2,),
                    WidgetTextField(
                      isPassword: false,
                      Controller: ref.read(Credit_riverpod.notifier).cardholderNameController,
                      HintText:textLanguage.GetWord("اسم حامل البطاقة"),
                      iconData:"assets/icon/CardholderName.svg",
                      focusNode: ref.read(Credit_riverpod.notifier).cardholderNameControllerNode,
                    ),
                    SizedBox(height:sizes.GetHeight()*2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width:sizes.GetWidth()*45,
                          child: WidgetTextField(
                            isPassword: false,
                            Controller: ref.read(Credit_riverpod.notifier).expiryDateController,
                            HintText:textLanguage.GetWord('تاريخ انتهاء الصلاحية'),
                            iconData:"assets/icon/ExpiryDate.svg",
                            focusNode: ref.read(Credit_riverpod.notifier).expiryDateControllerNode,
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
                            Controller: ref.read(Credit_riverpod.notifier).cVVController,
                            HintText:"CVV",
                            iconData:"assets/icon/cvv.svg",
                            focusNode: ref.read(Credit_riverpod.notifier).cVVControllerNode,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height:sizes.GetHeight()*2,),
                    Row(
                      children: [
                        CheckBoxSvg(
                          onChanged:(bool value) {
                          //  ref.read(Credit_riverpod.notifier).checkBoxSvg(value);
                          },
                          initialValue: false,
                        ),
                        SizedBox(width:sizes.GetWidth()*1,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(textLanguage.GetWord('حفظ معلومات البطاقة')),
                            Text(textLanguage.GetWord('سيتم تخزين بيانات بطاقتك بشكل آمن'))
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height:sizes.GetHeight()*2,),
                    SquareButton(
                      width: sizes.GetWidth() * 50,
                      height: sizes.GetHeight() * 6,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                PayNow(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );

                        /*
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                PaywithMada(),
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
                            textLanguage.GetWord("حفظ"),
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
                          SvgPicture.asset(
                            "assets/icon/arrow.svg",
                          ),
                        ],
                      ),
                      backgroundColor:theme.GetColor("primary"),
                      borderRadius: sizes.GetWidth()*10,
                    ),
                  ]
              )
          )
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
        StepLine(height:Sizes(context).GetWidth()*2.5,width: Sizes(context).GetWidth()*25, color:Themes().GetColor("secondary500")),
        SizedBox(width: Sizes(context).GetWidth()*1,),
        StepCircle(number: "2", size: Sizes(context).GetWidth()*14, color:Themes().GetColor("secondary500")),
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