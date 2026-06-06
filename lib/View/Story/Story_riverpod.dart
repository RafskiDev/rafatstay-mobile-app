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

  Future<void> toggleReaction(BuildContext context, int statusId, String type,
      bool isCurrentlyActive, int currentCount) async {
    final String? prevReaction = userReactions[statusId];
    final int prevLikes = likesCount[statusId] ?? 0;
    final int prevDislikes = dislikesCount[statusId] ?? 0;

    // ─── Optimistic Update ───
    if (type == "like") {
      likesCount[statusId] = isCurrentlyActive ? currentCount - 1 : currentCount + 1;
      if (prevReaction == "dislike") {
        dislikesCount[statusId] = (prevDislikes - 1).clamp(0, 999);
      }
    } else {
      dislikesCount[statusId] = isCurrentlyActive ? prevDislikes - 1 : prevDislikes + 1;
      if (prevReaction == "like") {
        likesCount[statusId] = (currentCount - 1).clamp(0, 999);
      }
    }
    userReactions[statusId] = isCurrentlyActive ? null : type;
    state++;

    // ─── API Call ───
    final res = await ApiService().post(
      "v1/guest/statuses/$statusId/react",
      {"reaction_type": type},
      context,
    );

    if (res?['success'] == true) {
      // ✅ نأخذ القيم الحقيقية من السيرفر
      final reactions = res?['data']?['reactions'];

      likesCount[statusId] =
          int.tryParse(reactions?['likes_count']?.toString() ?? '0') ?? 0;
      dislikesCount[statusId] =
          int.tryParse(reactions?['dislikes_count']?.toString() ?? '0') ?? 0;

      // ✅ is_liked / is_disliked بدل user_reaction
      final bool isLiked = reactions?['is_liked'] == true;
      final bool isDisliked = reactions?['is_disliked'] == true;
      userReactions[statusId] = isLiked ? "like" : isDisliked ? "dislike" : null;

      state++;
    } else {
      // ─── Rollback ───
      userReactions[statusId] = prevReaction;
      likesCount[statusId] = prevLikes;
      dislikesCount[statusId] = prevDislikes;
      state++;
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

