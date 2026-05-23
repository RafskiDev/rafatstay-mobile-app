import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';
import 'package:uuid/uuid.dart';
import 'package:get_storage/get_storage.dart';
import '../BottomBar/BottomBar.dart';

class PageNotifier extends Notifier<int> {
  final storage = GetStorage();
  bool isLoading = false;
  bool isLoading_ = false;
  // Controllers
  late final TextEditingController full_name;
  late final TextEditingController email;
  late final TextEditingController phone;
  late final TextEditingController password;
  late final TextEditingController confirmPassword;

  // FocusNodes
  late final FocusNode full_nameNode;
  late final FocusNode lastNameNode;
  late final FocusNode emailNode;
  late final FocusNode phoneNode;
  late final FocusNode passwordNode;
  late final FocusNode confirmPasswordNode;

  @override
  int build() {
    // init controllers
    full_name = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();

    // init focus nodes
    full_nameNode = FocusNode();
    lastNameNode = FocusNode();
    emailNode = FocusNode();
    phoneNode = FocusNode();
    passwordNode = FocusNode();
    confirmPasswordNode = FocusNode();

    // dispose safely
    ref.onDispose(() {
      full_name.dispose();
      email.dispose();
      phone.dispose();
      password.dispose();
      confirmPassword.dispose();

      full_nameNode.dispose();
      lastNameNode.dispose();
      emailNode.dispose();
      phoneNode.dispose();
      passwordNode.dispose();
      confirmPasswordNode.dispose();
    });

    return 0;
  }

  // reset form
  void reset() {
    full_name.clear();
    email.clear();
    phone.clear();
    password.clear();
    confirmPassword.clear();

    full_nameNode.unfocus();
    lastNameNode.unfocus();
    emailNode.unfocus();
    phoneNode.unfocus();
    passwordNode.unfocus();
    confirmPasswordNode.unfocus();
  }

  // create user
  Future<dynamic> createUser(BuildContext context) async {
    ref.notifyListeners();
    isLoading=true;
    try {
      ApiService api = ApiService();
      final birthday = DateTime.now().subtract(const Duration(days: 365 * 20));
      final data = {
        "full_name": full_name.text.trim(),
        "phone": phone.text.trim(),
        "email": email.text.trim(),
        "password": password.text,
        "password_confirmation": confirmPassword.text,
        "geneder": "male",
        "birthday":
        "${birthday.year}-${birthday.month.toString().padLeft(
            2, '0')}-${birthday.day.toString().padLeft(2, '0')}",
      };
      final response = await api.post("v1/auth/register", data, context);
      return response;
    }finally{
      ref.notifyListeners();
      isLoading=false;
    }
  }

  Future<void> loginAsGuest(BuildContext context) async {
    ref.notifyListeners();
    isLoading_=true;
    TextLanguage textLanguage = TextLanguage();
    // إنشاء بيانات عشوائية
    final uuid = const Uuid();
    final guestId = uuid.v4().replaceAll('-', '').substring(0, 8);
    final email = "guest_$guestId@rafatstay.com";
    final password = guestId;
    try {
      final response = await ApiService().post(
        "v1/auth/register",
        {
          "full_name": "Guest",
          "email": email,
          "password": password,
          "password_confirmation": password,
          "role": "guest",
        },
        context,
      );

      if (response["success"] == true) {
        storage.write("token", response["data"]["token"]);
        storage.write("user", response["data"]["user"]);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
              (route) => false,
        );
      } else {
        ToastMessages(
          context,
          textLanguage.GetWord("خطأ في إنشاء الحساب"),
          Colors.red,
          Colors.white,
        );
      }
    }finally{
      ref.notifyListeners();
      isLoading_=false;
    }
  }

}


// Provider
final signInRiverpod =NotifierProvider<PageNotifier, int>(PageNotifier.new);
