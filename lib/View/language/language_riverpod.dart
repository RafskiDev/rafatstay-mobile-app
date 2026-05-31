import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
class PageNotifier extends Notifier<int> {
  final storage = GetStorage();
  TextLanguage textLanguage=TextLanguage();
  final List<Map<String, String>> languages = [
    {
      "label": "English",
      "native": "English",
      "code": "en",
    },
    {
      "label": "العربية",
      "native": "Arabic",
      "code": "ar",
    },
  ];

  @override
  int build() {
    final saved = storage.read("Language");
    return (saved is int) ? saved : 0;
  }

  void selectIndex(int index) {
    textLanguage.ChangeLanguge(index);
    state = index;
  }

  Future<dynamic> updatePreferences(BuildContext context,String language) async {
    ApiService api = ApiService();
    final Map<String, dynamic> data = {
      "preferred_language":language,
      "latitude": 30.30,
      "longitude": 30.30,
    };
    final response = await api.post(
      "auth/preferences",
      data,
      context,
    );
     await storage.write("user", response["data"]["user"]);
    return response;
  }

}

final language_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
