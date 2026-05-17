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

  bool isLiked = false;
  bool isDisliked = false;

  Future<void> toggleReaction(BuildContext context, int statusId, String type) async {
    await ApiService().post(
      "v1/guest/statuses/$statusId/react",
      {"reaction_type": type},
      context,
    );

    if (type == "like") {
      isLiked = !isLiked;
      if (isLiked) isDisliked = false;
    } else {
      isDisliked = !isDisliked;
      if (isDisliked) isLiked = false;
    }

    ref.notifyListeners();
  }

}
// Provider
final Story_riverpod =NotifierProvider<PageNotifier, int>(PageNotifier.new);

