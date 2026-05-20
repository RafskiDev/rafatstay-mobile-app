import 'package:flutter/material.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../Otp/Otp.dart';
import 'ForgotPassword_riverpod.dart';
class ForgotPassword extends ConsumerWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(context,textLanguage.GetWord("هل نسيت كلمة السر بدون علامه استفهام")),
      body:SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
            child: Column(
              children: [
                Center(
                  child: Image.asset("assets/images/ForgotPassword.png",height:sizes.GetHeight()*30),
                ),
                SizedBox(height:sizes.GetHeight()*2,),
                Text(
                  textLanguage.GetWord("لا تقلق... سنساعدك على استعادة الوصول إلى حسابك في بضع خطوات سريعة"),
                  textAlign: TextAlign.center, // يجعل النص في الوسط
                ),
                SizedBox(height:sizes.GetHeight()*2,),
                WidgetTextField(
                  Controller: ref.read(ForgotPassword_riverpod.notifier).emailController,
                  HintText:textLanguage.GetWord("أدخل بريدك الإلكتروني أو رقم هاتفك"),
                  iconData:"assets/icon/phone_email.svg",
                  focusNode: ref.read(ForgotPassword_riverpod.notifier).emailNode,
                ),
                SizedBox(height:sizes.GetHeight()*2,),
                WidgetButton(
                  context: context,
                  buttonText:textLanguage.GetWord("يؤكد"),
                  onPressed: ()async {
                   await ref.read(ForgotPassword_riverpod.notifier).forgotPassword(context);
                  },
                  backgroundColor:theme.GetColor("primary"),
                  textColor:theme.GetColor("textPrimary"),
                  isCircular: true,
                ),

            SizedBox(height:sizes.GetHeight()*2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(textLanguage.GetWord("ليس لديك حساب")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // لإزالة المسافة الافتراضية حول النص
                        minimumSize: Size(0, 0), // لتقليل حجم الزر لأقصى حد للنص
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft, // محاذاة النص إذا لزم
                      ),
                      child: Text(
                        textLanguage.GetWord("قم بالتسجيل"),
                        style: TextStyle(
                          color: theme.GetColor("primary"),
                          decoration: TextDecoration.underline,
                          decorationColor: theme.GetColor("primary"), // لون الخط السفلي
                        ),
                      ),
                    ),
                  ],
                ),
                ]
            )
          ),
        ),
      ),
    );
  }

}
