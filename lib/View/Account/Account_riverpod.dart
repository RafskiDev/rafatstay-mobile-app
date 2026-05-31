import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, MaterialPageRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';
import '../Login/Login.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
class PageNotifier extends Notifier<int> {
  final storage = GetStorage();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  int build() {
    return 0;
  }

  Future<dynamic> LogOut(BuildContext context)async{
    ApiService api = ApiService();
    TextLanguage textLanguage = TextLanguage();
    final response = await api.post(
      "v1/auth/logout",
      {},
      context,
    );
    if(response["success"]==true){
      storage.remove("token");
      storage.remove("user");
      storage.remove("password");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
      );
    }else{
      ToastMessages(context,textLanguage.GetWord("خطأ في المصداقية"),Themes().GetColor("error"),Themes().GetColor("white"));
    }

    return response;
  }

  Future<dynamic> DeleteAccount(BuildContext context) async {
    ApiService api = ApiService();
    TextLanguage textLanguage = TextLanguage();
    final response = await api.delete("v1/auth/account", context, null);
    if(response["success"]==true){
      storage.remove("token");
      storage.remove("user");
      storage.remove("password");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
      );
    }else{
      ToastMessages(context,textLanguage.GetWord("خطأ في المصداقية"),Themes().GetColor("error"),Themes().GetColor("white"));
    }

    return response;
  }

  Future<void> pickAndUploadAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final file = File(picked.path);
    final response = await ApiService().uploadFile(
      "v1/auth/profile",
      file,
      context,
      fieldName: "avatar",
      method: "POST",
      fields: {"_method": "PATCH"},
    );
    if (response?["success"] == true) {
      final user = storage.read("user");
      user["avatar"] = response?["data"]["user"]["avatar"];
      storage.write("user", user);
      state = state + 1; // trigger rebuild
      print(response?["data"]["avatar_url"]);
    }
  }
}

final Account_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
