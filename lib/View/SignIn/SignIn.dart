import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../language/language.dart';
import 'SignIn_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
class SignIn extends ConsumerWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    ref.watch(signInRiverpod);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final sizes=Sizes(context);
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      body:SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
            child:Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap:(){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                              const language(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child:SvgPicture.asset("assets/icon/language.svg"),
                     ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight()*5),
                Center(
                    child:Text(
                      textLanguage.GetWord("ابدأ رحلتك مع الفخامة المصممة خصيصًا لك"),
                      style:TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
                Center(
                  child: Text(
                    textLanguage.GetWord(
                        "قم بإنشاء حسابك للحصول على مزايا حصرية وكسب نقاط والاستمتاع بالعروض المخصصة."
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: sizes.GetHeight()*4),
                WidgetTextField(
                  Controller: ref.read(signInRiverpod.notifier).full_name,
                  HintText:textLanguage.GetWord("أدخل اسمك الكامل"),
                  iconData:"assets/icon/accountDeactivate.svg",
                  focusNode: ref.read(signInRiverpod.notifier).full_nameNode,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetTextField(
                  Controller: ref.read(signInRiverpod.notifier).email,
                  HintText:textLanguage.GetWord("أدخل بريدك الإلكتروني"),
                  iconData:"assets/icon/Email.svg",
                  focusNode: ref.read(signInRiverpod.notifier).emailNode,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetTextField(
                  keyboardType: TextInputType.number,
                  inputFormattersList: [FilteringTextInputFormatter.digitsOnly],
                  Controller: ref.read(signInRiverpod.notifier).phone,
                  HintText:textLanguage.GetWord("أدخل رقم هاتفك"),
                  iconData:"assets/icon/phone.svg",
                  focusNode: ref.read(signInRiverpod.notifier).phoneNode,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetTextField(
                  isPassword: true,
                  Controller: ref.read(signInRiverpod.notifier).password,
                  HintText:textLanguage.GetWord("أدخل كلمة المرور الخاصة بك"),
                  iconData:"assets/icon/lock.svg",
                  focusNode: ref.read(signInRiverpod.notifier).passwordNode,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetTextField(
                  isPassword: true,
                  Controller: ref.read(signInRiverpod.notifier).confirmPassword,
                  HintText:textLanguage.GetWord("تأكيد كلمة المرور الجديدة"),
                  iconData:"assets/icon/lock.svg",
                  focusNode: ref.read(signInRiverpod.notifier).confirmPasswordNode,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetButton(
                  isLoading:ref.read(signInRiverpod.notifier).isLoading,
                  context: context,
                  buttonText:textLanguage.GetWord("اشتراك"),
                  onPressed: ()async {
                    await ref.read(signInRiverpod.notifier).createUser(context);
                  },
                  backgroundColor:theme.GetColor("primary"),
                  textColor:theme.GetColor("textPrimary"),
                  isCircular: true,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetButton(
                  isLoading:ref.read(signInRiverpod.notifier).isLoading_,
                  context: context,
                  buttonText:textLanguage.GetWord("جرب كضيف"),
                  borderColor:theme.GetColor("textPrimary"),
                  onPressed: () {
                    ref.read(signInRiverpod.notifier).loginAsGuest(context);
                  },
                  backgroundColor:theme.GetColor("background"),
                  textColor:theme.GetColor("textPrimary"),
                  isCircular: true,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(textLanguage.GetWord("لديك حساب بالفعل")+"؟"),
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
                        textLanguage.GetWord("تسجيل الدخول"),
                        style: TextStyle(
                          color: theme.GetColor("primary"),
                          decoration: TextDecoration.underline,
                          decorationColor: theme.GetColor("primary"), // لون الخط السفلي
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
