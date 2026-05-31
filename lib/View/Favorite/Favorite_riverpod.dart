import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../Service/ApiService.dart';

class PageNotifier extends Notifier<int> {
  // ✅ تقسيم البيانات الحقيقية بناءً على الأقسام الجديدة القادمة من السيرفر
  List<Map<String, dynamic>> favoriteBranches = [];
  List<Map<String, dynamic>> favoriteDishes = [];
  List<Map<String, dynamic>> statusBranches = []; // أقسام الستوريات المفضلة
  List<Map<String, dynamic>> interestBranches = []; // ✅ إضافة قسم الاهتمامات الجديد
  Map<int, bool> favoriteStatus = {};

  @override
  int build() {
    return 0;
  }

  // ==================== جلب شاشة المفضلة الكاملة ====================
  Future<void> fetchFavorites(BuildContext context) async {
    ApiService api = ApiService();

    // ✅ التعديل هنا لضرب رابط الشاشة الكاملة ليعيد الأقسام الأربعة وكل التفاصيل
    final res = await api.get("v1/guest/favorites/screen", {}, context);
    print(res);
    if (res?["success"] == true) {
      final data = res["data"];

      if (data != null && data["sections"] != null) {
        final sections = data["sections"];

        // 1. جلب فروع المطاعم المفضلة
        if (sections["favorite_restaurants"] != null && sections["favorite_restaurants"]["items"] is List) {
          favoriteBranches = List<Map<String, dynamic>>.from(sections["favorite_restaurants"]["items"]);
          for (final item in favoriteBranches) {
            if (item['item_id'] != null) favoriteStatus[item['item_id']] = true;
          }
        }

        // 2. جلب الأطباق المفضلة
        if (sections["favorite_dishes"] != null && sections["favorite_dishes"]["items"] is List) {
          favoriteDishes = List<Map<String, dynamic>>.from(sections["favorite_dishes"]["items"]);
          for (final item in favoriteDishes) {
            if (item['item_id'] != null) favoriteStatus[item['item_id']] = true;
          }
        }

        // 3. جلب أقسام الحالات (Statuses) للفرع
        if (sections["status"] != null && sections["status"]["items"] is List) {
          statusBranches = List<Map<String, dynamic>>.from(sections["status"]["items"]);
          print(statusBranches);
        }
        // 4. ✅ جلب قسم الاهتمامات (Interests) الجديد وتخزينه وحفظ حالته كمفضلة
        if (sections["interests"] != null && sections["interests"]["items"] is List) {
          interestBranches = List<Map<String, dynamic>>.from(sections["interests"]["items"]);
          for (final item in interestBranches) {
            if (item['item_id'] != null) {
              // بما أنها قادمة في شاشة المفضلة إذن هي مفضلة تلقائياً حتى يغيرها المستخدم
              favoriteStatus[item['item_id']] = true;
            }
          }
        }
      } else {
        favoriteBranches = [];
        favoriteDishes = [];
        statusBranches = [];
        interestBranches = [];
      }

      state++;
    }
  }

  // ==================== تبديل المفضلة ====================
  Future<void> toggleFavorite(
      int itemId,
      String type,
      BuildContext context,
      ) async {

    // 1. حفظ الحالة السابقة للرجوع إليها في حال فشل السيرفر
    final bool wasFavorited = favoriteStatus[itemId] ?? true;

    // 2. التحديث اللحظي للواجهة (Optimistic Update)
    favoriteStatus[itemId] = !wasFavorited;

    if (wasFavorited) {
      // حذف العنصر فوراً من القوائم المحلية لكي يختفي من الشاشة بدون انتظار السيرفر
      if (type == 'branch') {
        favoriteBranches.removeWhere((item) => item['item_id'] == itemId);
        interestBranches.removeWhere((item) => item['item_id'] == itemId || item['branch_id'] == itemId);
        statusBranches.removeWhere((item) => item['item_id'] == itemId || item['branch_id'] == itemId);
      } else if (type == 'menu_item') {
        favoriteDishes.removeWhere((item) => item['item_id'] == itemId);
      }
    }

    // إجبار الواجهة على التحديث فوراً
    state++;

    // 3. إرسال الطلب للسيرفر في الخلفية
    final response = await ApiService().post(
      "v1/guest/favorites/toggle",
      {
        "item_id": itemId.toString(),
        "type": type,
      },
      context,
    );

    // 4. التحقق من رد السيرفر
    if (response != null && response['success'] == true) {
      // العملية نجحت، نجلب البيانات بصمت لضمان التزامن التام ومزامنة العدادات (ETA وغيرها)
      fetchFavorites(context);
    } else {
      // في حال فشل الطلب (مثلاً انقطع الإنترنت)، نعيد العنصر للحالة السابقة حمايةً للبيانات
      favoriteStatus[itemId] = wasFavorited;
      await fetchFavorites(context);
    }
  }
}

final Favorite_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);