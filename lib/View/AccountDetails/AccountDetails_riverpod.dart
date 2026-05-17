import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';
import '../Login/Login.dart';
class PageNotifier extends Notifier<Map<String, dynamic>> {
  final storage = GetStorage();
  final TextEditingController nameController=TextEditingController();
  final TextEditingController emailController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();
  final nameFocus = FocusNode();
  final passwordFocus = FocusNode();
  final emailFocus = FocusNode();
   List<bool> isReadOnly=[true,true,true];
  @override
  Map<String, dynamic> build() {
    return {
      'page': 0,
      'isReadOnly': [true, true, true],
    };
  }

  void toggleReadOnly(int index) {
    final currentList = List<bool>.from(state['isReadOnly']);
    currentList[index] = !currentList[index];
    state = {
      ...state,
      'isReadOnly': currentList,
    };
  }
  void saveData() {
    state = {
      ...state,
      'isReadOnly': [true, true, true],
    };
  }

  Future<dynamic> userEdit(BuildContext context) async {
    ApiService api = ApiService();
    TextLanguage textLanguage = TextLanguage();

    final response = await api.post(
      "auth/update-profile", // أو "auth/update-profile"
      {
        "full_name": nameController.text,
        "email": emailController.text,
        "phone": passwordController.text, // تأكد من الحقل الصحيح
      },
      context,
    );
     print(response);
    if(response["success"] == true) {
      // حدّث بيانات المستخدم في Storage
      storage.write("user", response["data"]);

      ToastMessages(
          context,
          textLanguage.GetWord("تم التحديث بنجاح"),
          Themes().GetColor("success"),
          Themes().GetColor("white")
      );

      // أرجع الحقول لـ readOnly
      saveData();
    } else {
      ToastMessages(
          context,
          textLanguage.GetWord("فشل التحديث"),
          Themes().GetColor("error"),
          Themes().GetColor("white")
      );
    }

    return response;
  }
}

final AccountDetails_riverpod = NotifierProvider<PageNotifier, Map<String, dynamic>>(PageNotifier.new);

