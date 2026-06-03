import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

class PageNotifier extends Notifier<List<Map<String, dynamic>>> {

  @override
  List<Map<String, dynamic>> build() {
    return [];
  }

  void setData(List<Map<String, dynamic>> data) {
    state = data;
  }


  Future<void> toggleFavorite(int index, BuildContext context) async {
    final item = state[index];
    final String type = item["type"] ?? "branch";

    // 👑 1. جلب الحالة الحالية بناءً على المفتاحين لتجنب أي تعارض
    final bool currentStatus = item["is_favorited"] ?? item["liked"] ?? false;
    final bool newStatus = !currentStatus;

    // 👑 2. تحديث الـ UI فوراً (Optimistic Update) ليكون التطبيق سريعاً جداً
    final updated = [...state];
    updated[index] = {
      ...updated[index],
      "is_favorited": newStatus, // تحديث المفتاح الأساسي للـ API
      "liked": newStatus,        // تحديث المفتاح الاحتياطي
    };
    state = updated; // الـ Riverpod هنا سيقوم بتحديث الـ UI تلقائياً

    // 3. إرسال الطلب للسيرفر في الخلفية
    final response = await ApiService().post(
      "v1/guest/favorites/toggle",
      {
        "item_id": item["id"],
        "type": type,
      },
      context,
    );

    // 👑 4. إذا فشل الطلب لأي سبب، نعيد الحالة القديمة حتى لا تخدع المستخدم
    if (response == null) {
      final reverted = [...state];
      reverted[index] = {
        ...reverted[index],
        "is_favorited": currentStatus,
        "liked": currentStatus,
      };
      state = reverted;
    }
  }
}

final filteredResultsProvider =
NotifierProvider<PageNotifier, List<Map<String, dynamic>>>(
  PageNotifier.new,
);
