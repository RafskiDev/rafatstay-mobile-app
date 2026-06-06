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
import '../Login/Login.dart'; // تأكد من صحة مسار صفحة اللوجن لديك
import 'ResetYourPassword_riverpod.dart';

class ResetYourPassword extends ConsumerWidget {
  final String email; // ← استقبال الإيميل هنا بشكل إجباري ومضمون
  final String otp;   // ← استقبال الـ OTP هنا بشكل إجباري ومضمون

  const ResetYourPassword({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final sizes = Sizes(context);
    final notifier = ref.watch(ResetYourPassword_riverpod.notifier);

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar: buildCustomAppBar(context, textLanguage.GetWord("إعادة تعيين كلمة المرور الخاصة بك")),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 5, vertical: sizes.GetHeight() * 5),
          child: Column(
            children: [
              Center(child: Text(textLanguage.GetWord("إنشاء كلمة مرور جديدة لاستعادة الوصول الآمن"))),
              SizedBox(height: sizes.GetHeight() * 2),
              WidgetTextField(
                isPassword: true,
                Controller: notifier.firstpasswordController,
                HintText: textLanguage.GetWord("أدخل كلمة المرور الخاصة بك"),
                iconData: "assets/icon/lock.svg",
                focusNode: notifier.firstpasswordNode,
                nextFocusNode: notifier.SecondpasswordNode,
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              WidgetTextField(
                isPassword: true,
                Controller: notifier.SecondasswordController,
                HintText: textLanguage.GetWord("تأكيد كلمة المرور الجديدة"),
                iconData: "assets/icon/lock.svg",
                focusNode: notifier.SecondpasswordNode,
              ),
              SizedBox(height: sizes.GetHeight() * 3),
              WidgetButton(
                context: context,
                buttonText: textLanguage.GetWord("إعادة تعيين كلمة المرور الخاصة بك"),
                onPressed: () async {
                  FocusScope.of(context).unfocus(); // إغلاق الكيبورد

                  // استدعاء دالة الـ API وتمرير المتغيرات المضمونة الممررة في الأعلى
                  final result = await notifier.submitResetPassword(
                    context: context,
                    email: email,
                    otp: otp,
                  );
                  if (context.mounted) {
                    if (result["success"] == true) {
                      notifier.reset();
                      WidgetCustomDialog(
                        barrierDismissible: false,
                        context,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: sizes.GetHeight() * 35,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset("assets/icon/success.svg", semanticsLabel: 'Success Logo', height: sizes.GetHeight() * 8),
                              SizedBox(height: sizes.GetHeight() * 1.5),
                              Text(
                                textLanguage.GetWord("تم إعادة تعيين كلمة المرور بنجاح"),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: sizes.GetHeight() * 1),
                              Text(
                                textLanguage.GetWord("كلمة مرورك الجديدة مُفعّلة الآن. سجّل دخولك لمواصلة تجربتك السلسة."),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: sizes.GetHeight() * 2),
                              WidgetButton(
                                context: context,
                                buttonText: textLanguage.GetWord("تسجيل الدخول"),
                                onPressed: () {
                                  Navigator.pop(context); // إغلاق الديالوج
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => Login()),
                                        (route) => false, // حذف صفحات الاستعادة تماماً من الذاكرة لأمان المستخدم
                                  );
                                },
                                backgroundColor: theme.GetColor("secondaryPrimary"),
                                textColor: theme.GetColor("background"),
                                isCircular: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // إظهار رسالة الخطأ القادمة من السيرفر مباشرة
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? textLanguage.GetWord("حدث خطأ ما")),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                backgroundColor: theme.GetColor("primary"),
                textColor: theme.GetColor("textPrimary"),
                isCircular: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}