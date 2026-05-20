import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../BottomBar/BottomBar.dart';
import '../ForgotPassword/ForgotPassword.dart';
import '../LocationPrompt/LocationPrompt.dart';
import '../SignIn/SignIn.dart';
import '../language/language.dart';
import 'Login_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
class Login extends ConsumerWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentPage = ref.watch(pageProvider);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body:SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(onTap:(){
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
                     child:SvgPicture.asset("assets/icon/language.svg", semanticsLabel: 'Dart Logo')),
                  ],
                ),
                Center(
                    child: SvgPicture.asset("assets/images/logoApps.svg"),
                ),
              Text(textLanguage.GetWord("مرحبًا بكم مرة أخرى في تجربة إقامة راقية"),style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  textLanguage.GetWord("قم بتسجيل الدخول للوصول إلى حجوزاتك وامتيازاتك ورحلة مصممة خصيصًا لراحتك"),
                  textAlign: TextAlign.center, // يجعل كل السطور في الوسط
                ),
                SizedBox(height: sizes.GetHeight()*5),
                WidgetTextField(
                  Controller: ref.read(pageProvider.notifier).emailController,
                  HintText:textLanguage.GetWord("أدخل بريدك الإلكتروني"),
                  iconData:"assets/icon/Email.svg",
                  focusNode: ref.read(pageProvider.notifier).emailNode,
                  nextFocusNode: ref.read(pageProvider.notifier).passwordNode, // ينتقل للحقل التالي
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetTextField(
                  isPassword: true,
                  Controller: ref.read(pageProvider.notifier).passwordController,
                  HintText:textLanguage.GetWord("أدخل كلمة المرور الخاصة بك"),
                  iconData:"assets/icon/lock.svg",
                  focusNode: ref.read(pageProvider.notifier).passwordNode,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                            const ForgotPassword(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // لإزالة المسافة الافتراضية حول النص
                        minimumSize: Size(0, 0), // لتقليل حجم الزر لأقصى حد للنص
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft, // محاذاة النص إذا لزم
                      ),
                      child: Text(
                        textLanguage.GetWord("هل نسيت كلمة السر"),
                        style: TextStyle(
                          color: theme.GetColor("primary"),
                          decoration: TextDecoration.underline,
                          decorationColor: theme.GetColor("primary"), // لون الخط السفلي
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight()*2),
                WidgetButton(
                  isLoading:ref.read(pageProvider.notifier).isLoading,
                  context: context,
                  buttonText:textLanguage.GetWord("تسجيل الدخول"),
                  onPressed: () {
                    ref.read(pageProvider.notifier).login(context);
                   // print("تم الضغط على الزر");
                  },
                  backgroundColor:theme.GetColor("primary"),
                  textColor:theme.GetColor("textPrimary"),
                  isCircular: true,
                ),
                SizedBox(height: sizes.GetHeight()*2),
                orDivider(context),
                SizedBox(height: sizes.GetHeight()*2),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    /*
                    ImageButton(
                      context: context,
                      widthFactor:sizes.GetHeight()*4,
                      imagePath: "assets/images/facebook.png",
                      onPressed: ()async {
                     //   await ref.read(pageProvider.notifier).signInWithFacebook();
                        /*
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                            const LocationPrompt(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );

                         */
                      },
                    ),

                     */
                    if (Theme.of(context).platform == TargetPlatform.android)
                    ImageButton(
                      context: context,
                      widthFactor:sizes.GetHeight()*4,
                      imagePath: "assets/images/google.png",
                      onPressed: ()async {

                        await ref.read(pageProvider.notifier).signIn(context);
                      },
                    ),
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                    ImageButton(
                      context: context,
                      widthFactor:sizes.GetHeight()*4,
                      imagePath: "assets/images/apple.png",
                      onPressed: ()async {
                        await ref.read(pageProvider.notifier).signInWithApple(context);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(textLanguage.GetWord("ليس لديك حساب")),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                            const SignIn(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
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
            ),
          ),
        ),
      ),
    );
  }
}
Widget orDivider(BuildContext context) {
  Themes theme = Themes();
  return Row(
    children: [
      Expanded(
        child: Divider(
          color: theme.GetColor("textSecondary"), // لون الخط
          thickness: 1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          "OR",
          style: TextStyle(
            color: theme.GetColor("textSecondary"),
            fontFamily: "Cairo",
          ),
        ),
      ),
      Expanded(
        child: Divider(
          color: theme.GetColor("textSecondary"),
          thickness: 1,
        ),
      ),
    ],
  );
}
