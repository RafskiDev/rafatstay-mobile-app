import 'dart:async';

import 'package:flutter/material.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../Login/Login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ResetYourPassword/ResetYourPassword.dart';
import 'otp_riverpod.dart';
class Otp extends ConsumerStatefulWidget {
  final String email;
  const Otp({super.key, required this.email});

  @override
  ConsumerState<Otp> createState() => _OtpState();
}

class _OtpState extends ConsumerState<Otp> {
  Timer? _timer;
  String _enteredOtp = "";
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(otp_riverpod.notifier).reset();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(otp_riverpod.notifier).tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final sizes=Sizes(context);
    final seconds = ref.watch(otp_riverpod); // ← أضف هذا
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(context,textLanguage.GetWord("التحقق من OTP")),
      body:SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5,vertical:sizes.GetHeight()*5),
          child:Column(
            children: [
              Image.asset("assets/images/otp.png",height:sizes.GetHeight()*30,),
              SizedBox(height:sizes.GetHeight()*2,),
              Text(
                textLanguage.GetWord("لقد أرسلنا لك رمز التحقق المكون من 4 أرقام. يرجى إدخال الرمز لإكمال عملية التحقق."),
                textAlign: TextAlign.center, // يجعل النص في الوسط
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              CustomOtpWidget(
                fieldCount: 6,
                onChanged: (otp) {
                  _enteredOtp = otp; // تحديث قيمة الرمز المدخل
                },
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    textLanguage.GetWord("متاح في 10 دقيقة"),
                    textAlign: TextAlign.center, // يجعل النص في الوسط
                  ),
                  Text(
                    _formatTime(seconds), // ← العداد هنا
                    style: TextStyle(
                      color: seconds > 0
                          ? theme.GetColor("primary")
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                children: [
                  WidgetButton(
                    context: context,
                    buttonText:textLanguage.GetWord("إعادة إرسال الرمز"),
                    borderColor:theme.GetColor("textPrimary"),
                    onPressed: () {
                      /*
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                          const ResetYourPassword(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                       */
                    },
                    backgroundColor:theme.GetColor("background"),
                    textColor:theme.GetColor("textPrimary"),
                    isCircular: true,
                  ),
                  WidgetButton(
                    context: context,
                    buttonText: textLanguage.GetWord("رمز التحقق"),
                    onPressed: () async {
                      // 1. التأكد أن المستخدم أدخل الـ 6 أرقام كاملة قبل إرسال الطلب
                      if (_enteredOtp.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(textLanguage.GetWord("يرجى إدخال رمز التحقق كاملاً المكون من 6 أرقام")),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return; // إيقاف العملية
                      }

                      // 2. بدء عملية التحقق عبر الـ API
                      final response = await ref.read(otp_riverpod.notifier)
                          .verifyOtp(context, widget.email, _enteredOtp);

                      if (mounted) {
                        // 3. إذا كان الرمز صحيحاً (نجاح)
                        if (response["success"] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(textLanguage.GetWord("تم التحقق بنجاح!")),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          // الانتقال لصفحة تعيين كلمة المرور بعد ثانية تلقائياً
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) =>  ResetYourPassword(email: widget.email, otp: _enteredOtp)),
                              );
                            }
                          });
                        }
                        // 4. إذا كان الرمز خاطئاً
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(textLanguage.GetWord("رمز التحقق غير صحيح، حاول مجدداً")),
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
              SizedBox(height:sizes.GetHeight()*2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(textLanguage.GetWord("ليس لديك حساب")),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                            (route) => false, // حذف كل الصفحات السابقة
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
            ],
          ),
        ),
      ),

    );
  }
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
