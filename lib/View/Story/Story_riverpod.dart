import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

class PageNotifier extends Notifier<int> {

  // ─── متغيرات التتبع ───
  DateTime? _startTime;      // وقت بداية المشاهدة
  int watchedSeconds = 0;    // كم ثانية شاهد
  double watchPercentage = 0; // كم بالمئة شاهد

  @override
  int build() => 0;

  // ─── تشغيل العداد ───
  void startWatching() {
    _startTime = DateTime.now();
  }

  // ─── حساب المشاهدة ───
  void calculateWatch(int totalDurationSeconds) {
    if (_startTime == null) return;
    watchedSeconds = DateTime.now().difference(_startTime!).inSeconds;
    if (totalDurationSeconds > 0) {
      watchPercentage = (watchedSeconds / totalDurationSeconds * 100).clamp(0, 100);
    }
  }

  // ─── تسجيل المشاهدة ───
  Future<void> recordView(BuildContext context, int statusId, {int totalDuration = 0}) async {
    calculateWatch(totalDuration);
     await ApiService().post(
      "v1/guest/statuses/$statusId/view",
      {
        "watch_percentage": watchPercentage.toInt(),
        "watched_duration": watchedSeconds,
        "completed": watchPercentage >= 90, // اعتبره مكتمل إذا شاهد 90%+
      },
      context,
    );
   ref.notifyListeners();
  }
  final Map<int, bool> favoriteStatus = {};
  final Map<int, int> likesCount = {};
  final Map<int, int> dislikesCount = {};
  final Map<int, String?> userReactions = {}; // أضف هذا

  Future<void> toggleReaction(BuildContext context, int statusId, String type, bool isCurrentlyActive, int currentCount) async {
    // Optimistic update
    if (type == "like") {
      likesCount[statusId] = isCurrentlyActive ? currentCount - 1 : currentCount + 1;
    } else {
      dislikesCount[statusId] = isCurrentlyActive ? currentCount - 1 : currentCount + 1;
    }
    userReactions[statusId] = isCurrentlyActive ? null : type; // optimistic
    state++;

    final res = await ApiService().post(
      "v1/guest/statuses/$statusId/react",
      {"reaction_type": type},
      context,
    );

    if (res?['success'] == true) {
      final action = res?['data']?['action'];
      final reaction = res?['data']?['reaction'];

      // الحالة الحقيقية من السيرفر
      userReactions[statusId] = action == "created" ? reaction : null;

      if (type == "like") {
        likesCount[statusId] = action == "created" ? currentCount + 1 : currentCount - 1;
      } else {
        dislikesCount[statusId] = action == "created" ? currentCount + 1 : currentCount - 1;
      }
      state++;
    } else {
      // تراجع
      userReactions[statusId] = isCurrentlyActive ? type : null;
      if (type == "like") likesCount[statusId] = currentCount;
      else dislikesCount[statusId] = currentCount;
      state--;
    }
  }
  // 1. تبديل حالة المفضلة (مع تحديث لحظي للواجهة)
  void toggleLike(int itemId, String type, BuildContext context) async {
    bool isLiked = favoriteStatus[itemId] ?? false;

    // 1. تحديث الحالة فوراً داخلياً
    favoriteStatus[itemId] = !isLiked;

    // 2. تحديث الـ State الخاص بالـ Notifier لإجبار الواجهة على التغيير المباشر
    state = state + 1; // تغيير الحالة لعمل تريجر لإعادة البناء اللحظي
    ref.notifyListeners();

    // 3. إرسال الطلب في الخلفية
    final res = await ApiService().post(
        "v1/$roles/favorites/toggle",
        {"item_id": itemId, "type": "status"},
        context
    );
    print(res);
    // 4. التراجع الذكي في حال فشل الـ API لـ أي سبب
    if (res?['success'] != true) {
      favoriteStatus[itemId] = isLiked; // إرجاع الحالة السابقة
      state = state - 1;
      ref.notifyListeners();
    }
  }
  Future<void> toggleFavorite(BuildContext context, int branchId) async {
    bool currentStatus = favoriteStatus[branchId] ?? false;

    // تحديث لحظي
    favoriteStatus[branchId] = !currentStatus;
    state++;
    ref.notifyListeners();

    final res = await ApiService().post(
        "v1/guest/favorites/toggle", // الرابط الصحيح للمفضلة
        {"item_id": branchId, "type": "branch"},
        context
    );

    if (res?['success'] != true) {
      favoriteStatus[branchId] = currentStatus; // تراجع في حال الخطأ
      state--;
      ref.notifyListeners();
    }
  }
}
// Provider
final Story_riverpod =NotifierProvider<PageNotifier, int>(PageNotifier.new);

