import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../Service/ApiService.dart';

class PageNotifier extends Notifier<int> {
  // ❌ احذف البيانات الوهمية
  // final List<Map<String, dynamic>> favorite = [...]

  // ✅ البيانات الحقيقية
  List<Map<String, dynamic>> allFavorites = [];
  Map<int, bool> favoriteStatus = {};

  @override
  int build() {
    return 0;
  }

  // ==================== جلب كل المفضلة ====================
  Future<void> fetchFavorites(BuildContext context) async {
    ApiService api = ApiService();

    final res = await api.get("v1/guest/favorites", {}, context);

    if (res?["success"] == true) {
      final data = res["data"];

      if (data != null && data["items"] is List) {
        allFavorites = List<Map<String, dynamic>>.from(data["items"]);

        // ✅ حفظ حالة المفضلة
        for (final fav in allFavorites) {
          final item = fav['item'];
          if (item != null && item['id'] != null) {
            favoriteStatus[item['id']] = true;
          }
        }
      } else {
        allFavorites = [];
      }

      state++;
    }
  }

  // ==================== فلترة المفضلة حسب النوع ====================
  List<Map<String, dynamic>> getFavoritesByType(String type) {
    return allFavorites.where((fav) => fav['type'] == type).toList();
  }

  // المطاعم/الفروع فقط
  List<Map<String, dynamic>> get favoriteBranches {
    return getFavoritesByType('branch');
  }

  // الأطباق فقط
  List<Map<String, dynamic>> get favoriteDishes {
    return getFavoritesByType('menu_item');
  }

  // ==================== تبديل المفضلة ====================
  Future<void> toggleFavorite(
      int itemId,
      String type,
      BuildContext context,
      ) async {
    final response = await ApiService().post(
      "v1/guest/favorites/toggle",
      {
        "item_id": itemId.toString(),
        "type": type,
      },
      context,
    );

    if (response != null && response['success'] == true) {
      // عكس الحالة
      favoriteStatus[itemId] = !(favoriteStatus[itemId] ?? false);

      // إعادة جلب المفضلة
      await fetchFavorites(context);
    }
  }
}

final Favorite_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);