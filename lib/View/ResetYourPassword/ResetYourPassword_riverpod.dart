import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Service/ApiService.dart';
// تأكد من عمل استيراد لكلاس الـ ApiService الخاص بك هنا
// import '../../Services/ApiService.dart';

class PageNotifier extends Notifier<int> {
  TextEditingController firstpasswordController = TextEditingController();
  FocusNode firstpasswordNode = FocusNode();

  TextEditingController SecondasswordController = TextEditingController();
  FocusNode SecondpasswordNode = FocusNode();

  @override
  int build() {
    return 0;
  }

  void dispose() {
    firstpasswordController.dispose();
    firstpasswordNode.dispose();
    SecondasswordController.dispose();
    SecondpasswordNode.dispose();
  }

  void reset() {
    firstpasswordController.clear();
    firstpasswordNode.unfocus();
    SecondasswordController.clear();
    SecondpasswordNode.unfocus();
  }

  // دالة إرسال طلب تغيير كلمة المرور والتحقق من الشروط
  Future<Map<String, dynamic>> submitResetPassword({
    required BuildContext context, // أضفنا الـ context هنا لكي نمرره للـ ApiService
    required String email,
    required String otp,
  }) async {
    final password = firstpasswordController.text.trim();
    final passwordConfirmation = SecondasswordController.text.trim();

    // 1. التحقق من تطابق كلمتي المرور قبل إرسال الطلب للسيرفر
    if (password != passwordConfirmation) {
      return {"success": false, "message": "كلمتا المرور غير متطابقتين!"};
    }

    // 2. التحقق من طول كلمة المرور (حسب التوثيق 8 أحرف على الأقل)
    if (password.length < 8) {
      return {"success": false, "message": "يجب أن تكون كلمة المرور 8 أحرف أو أكثر"};
    }

    try {
      // استدعاء كلاس الـ ApiService الخاص بك بناءً على الطريقة التي أرسلتها
      ApiService api = ApiService();

      // تجهيز البيانات المطلوبة للخطوة 3 (Reset Password) حسب التوثيق
      final data = {
        "email": email,
        "otp": otp,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };

      // إرسال الطلب إلى رابط تعيين كلمة المرور الجديدة
      final response = await api.post(
        "v1/auth/reset-password", // الرابط الخاص بالخطوة الثالثة
        data,
        context,
      );
      // الـ response سيرجع مباشرة ويحتوي على ["success"] إما true أو false ومعه الرسالة القادمة من الباكيند
      return response;

    } catch (e) {
      return {"success": false, "message": "حدث خطأ في الاتصال بالسيرفر"};
    }
  }
}

final ResetYourPassword_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);