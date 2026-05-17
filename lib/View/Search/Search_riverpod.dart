// Search_riverpod.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rafatstay/Utils/Them.dart';

import '../../Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  final box = GetStorage();
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();



  // نتائج البحث (branches + menu_items)
  List<dynamic> searchResults = [];

  // عمليات البحث الأخيرة من السيرفر (كل عنصر Map يحتوي id, query, ...)
  List<dynamic> recentSearches = [];

  bool isSearching = false;

  @override
  int build() {
    return 0;
  }

  // 🔍 تنفيذ البحث (يجلب branches + menu_items)
  Future<List<dynamic>?> search(
      BuildContext context, {
        List<String>? cuisines,
        String? rating,
        String? area,
      }) async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      isSearching = false; // ← أضف هذا
      ref.notifyListeners();
      return null;
    }

    isSearching = true; // ← أضف هذا قبل الـ API call
    ref.notifyListeners();
     ApiService api = ApiService();
      // 🟢 بناء الـ parameters بدون فلاتر ثابتة
      Map<String, dynamic> params = {
        "query": query,
        "per_page": "20",
      };
      // 🟢 إضافة الفلاتر فقط إذا تم تمريرها
      if (cuisines != null && cuisines.isNotEmpty) {
        params["cuisines[]"] = cuisines;
      }
      if (rating != null && rating.isNotEmpty) {
        params["rating"] = rating;
      }
      if (area != null && area.isNotEmpty) {
        params["area"] = area;
      }

      final res = await api.get("v1/$roles/search", params, context);
      if (res?["success"] == true) {
        final data = res["data"];
        final branches = (data["branches"]?["items"] ?? []) as List<dynamic>;
        final menuItems = (data["menu_items"]?["items"] ?? []) as List<dynamic>;
        final taggedBranches = branches.map((e) => {
          ...Map<String, dynamic>.from(e as Map), // ✅ cast أولاً
          "type": "branch",
        }).toList();

        final taggedMenuItems = menuItems.map((e) => {
          ...Map<String, dynamic>.from(e as Map), // ✅ cast أولاً
          "type": "menu_item",
        }).toList();

        searchResults = [...taggedBranches, ...taggedMenuItems];

        // 🟢 حفظ البحث في السجل
        /*
        final newSearch = {
          "id": DateTime
              .now()
              .millisecondsSinceEpoch,
          "query": query,
          "results_count": searchResults.length,
          "searched_at": DateTime.now().toIso8601String(),
        };

        recentSearches.removeWhere((element) => element["query"] == query);
        recentSearches.insert(0, newSearch);

        if (recentSearches.length > 10) {
          recentSearches = recentSearches.sublist(0, 10);
        }

         */

        searchController.clear();

        if (context.mounted) {
          ref.notifyListeners();
        }
        isSearching = true; // يبقى true بعد البحث
        ref.notifyListeners();
        return searchResults;
      }

      if (context.mounted) {
        ToastMessages(
          context,
          res?["message"] ?? "خطأ بالبحث",
          Themes().GetColor("error"),
          Themes().GetColor("white"),
        );
      }

    return null;
  }

  Future<Map<String, dynamic>?> checkRestaurantAvailability(BuildContext context, String query) async {
    try {
      ApiService api = ApiService();
      // نطلب نتيجة واحدة فقط للتأكد من الوجود
      final res = await api.get("v1/$roles/search", {"query": query, "per_page": "1"}, context);

      if (res?["success"] == true) {
        final branches = (res["data"]["branches"]?["items"] ?? []) as List;
        final menuItems = (res["data"]["menu_items"]?["items"] ?? []) as List;

        if (branches.isNotEmpty) return Map<String, dynamic>.from(branches.first);
        if (menuItems.isNotEmpty) return Map<String, dynamic>.from(menuItems.first);
      }
    } catch (e) {
      print("Background check error: $e");
    }
    return null; // تعيد null إذا لم تجد شيئاً أو حدث خطأ
  }
  Future<void> fetchRecentSearches(BuildContext context, {int limit = 20}) async {
    ApiService api = ApiService();
    final res = await api.get(
      "v1/$roles/search/recent",
      {"limit": limit.toString()},
      context,
    );
    if (res?["success"] == true) {
      final items = (res["data"]?["items"] ?? []) as List<dynamic>;
      recentSearches.clear();
      searchResults.clear();
      recentSearches = items;
      ref.notifyListeners();
    } else {
      ToastMessages(context, res?["message"] ?? "خطأ في جلب آخر البحث",Themes().GetColor("error"), Themes().GetColor("white"));
    }
    isSearching = false;

  }

  Future<bool> deleteRecentSearch(int id, BuildContext context) async {
    ApiService api = ApiService();
    final res = await api.delete("v1/$roles/search/recent/$id",context,{});
    if(res["success"] == true){
      recentSearches.removeWhere((element) => element["id"] == id);
      ref.notifyListeners();
      return true;
    } else {
      ToastMessages(context, res["message"] ?? "خطأ عند حذف البحث",Themes().GetColor("error"), Themes().GetColor("white"));
      return false;
    }
  }
/*
  Future<bool> checkFavoriteStatusLocal(int index, BuildContext context) async {
    if (index < 0 || index >= searchResults.length) return false;

    final item = searchResults[index];

    try {
      final response = await ApiService().get(
        "v1/$roles/favorites/check",
        {
          "item_id": item["id"].toString(),
          "type": "branch",
        },
        context,
      );

      return response != null &&
          response["data"] != null &&
          response["data"]["is_favorited"] == true;
    } catch (e) {
      print("Error checking favorite status: $e");
      return false;
    }
  }

 */

}

final Search_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
