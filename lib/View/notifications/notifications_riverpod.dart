import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

class NotificationsNotifier extends Notifier<Map<String, List<Map<String, dynamic>>>> {
  @override
  Map<String, List<Map<String, dynamic>>> build() {
    return {};
  }

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;

  // متغيرات خارجية لكي تتحقق منها الواجهة
  bool get isFetching => _isFetching;
  bool get hasMore => _hasMore;

  Future<void> notification(BuildContext context, {bool loadMore = false}) async {
    if (_isFetching) return;
    if (loadMore && !_hasMore) return;

    _isFetching = true;

    // إذا كانت أول مرة، امسح القديم وابدأ من صفحة 1
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      state = {};
    }

    final response = await ApiService().get(
      "v1/$roles/notifications",
      {"page": _currentPage.toString()}, // إرسال رقم الصفحة
      context,
    );

    if (response != null && response['success'] == true) {
      final rawData = response['data'];

      // استخرج الـ groups من داخل data
      final List groups = rawData is Map ? (rawData['groups'] ?? []) : [];

      if (groups.isNotEmpty || !loadMore) {
        Map<String, List<Map<String, dynamic>>> tempMap = Map.from(state);

        for (var group in groups) {
          if (group is Map<String, dynamic>) {
            String date = group['date']?.toString() ?? "Unknown Date";
            List items = group['items'] ?? [];

            List<Map<String, dynamic>> parsedItems =
            items.whereType<Map<String, dynamic>>().toList();

            if (tempMap.containsKey(date)) {
              tempMap[date]!.addAll(parsedItems);
            } else {
              tempMap[date] = parsedItems;
            }
          }
        }

        state = tempMap;

        if (groups.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;
        }
      } else {
        _hasMore = false;
      }
    } else {
      _hasMore = false;
    }

    _isFetching = false;
  }
}

final notifications_riverpod = NotifierProvider<NotificationsNotifier, Map<String, List<Map<String, dynamic>>>>(
  NotificationsNotifier.new,
);