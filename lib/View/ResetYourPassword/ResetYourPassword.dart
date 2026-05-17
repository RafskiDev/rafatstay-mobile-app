import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../../Widget/WidgetTextField.dart';
import 'ResetYourPassword_riverpod.dart';
class ResetYourPassword extends ConsumerWidget {
  const ResetYourPassword({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final sizes=Sizes(context);
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(context,textLanguage.GetWord("إعادة تعيين كلمة المرور الخاصة بك")),
      body:Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5,vertical:sizes.GetHeight()*5),
        child:Column(
          children: [
          Center(child: Text("إنشاء كلمة مرور جديدة لاستعادة الوصول الآمن")),
            SizedBox(height: sizes.GetHeight()*2),
            WidgetTextField(
              isPassword: true,
              Controller: ref.read(ResetYourPassword_riverpod.notifier).firstpasswordController,
              HintText:textLanguage.GetWord("أدخل كلمة المرور الخاصة بك"),
              iconData:"assets/icon/lock.svg",
              focusNode: ref.read(ResetYourPassword_riverpod.notifier).firstpasswordNode,
              nextFocusNode: ref.read(ResetYourPassword_riverpod.notifier).SecondpasswordNode, // ينتقل للحقل التالي
            ),
            SizedBox(height: sizes.GetHeight()*2),
            WidgetTextField(
              isPassword: true,
              Controller: ref.read(ResetYourPassword_riverpod.notifier).SecondasswordController,
              HintText:textLanguage.GetWord("تأكيد كلمة المرور الجديدة"),
              iconData:"assets/icon/lock.svg",
              focusNode: ref.read(ResetYourPassword_riverpod.notifier).SecondpasswordNode,
            ),
            SizedBox(height: sizes.GetHeight()*2),
            WidgetButton(
              context: context,
              buttonText:textLanguage.GetWord("إعادة تعيين كلمة المرور الخاصة بك"),
              onPressed: () {
                WidgetCustomDialog(
                  barrierDismissible:false,
                  context,
                  child:Container(
                    height:sizes.GetHeight()*33,
                    child: Column(
                      children: [
                        SvgPicture.asset("assets/icon/success.svg", semanticsLabel: 'Dart Logo'),
                        Text(
                          textLanguage.GetWord("تم إعادة تعيين كلمة المرور بنجاح"),
                          style:TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height:sizes.GetHeight()*2,),
                        Text(
                          textLanguage.GetWord("كلمة مرورك الجديدة مُفعّلة الآن. سجّل دخولك لمواصلة تجربتك السلسة."),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height:sizes.GetHeight()*2,),
                        WidgetButton(
                          context: context,
                          buttonText:textLanguage.GetWord("تسجيل الدخول"),
                          onPressed: () {
                            // ref.read(SignIn_riverpod.notifier).save();
                            Navigator.pop(context);
                          },
                          backgroundColor:theme.GetColor("secondaryPrimary"),
                          textColor:theme.GetColor("background"),
                          isCircular: true,
                        ),
                      ],
                    ),
                  )
                );
              },
              backgroundColor:theme.GetColor("primary"),
              textColor:theme.GetColor("textPrimary"),
              isCircular: true,
            ),
          ],
        ),
      ),

    );
  }
}
