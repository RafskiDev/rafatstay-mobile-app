import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../Service/ApiService.dart';
class NotificationsNotifier extends Notifier<Map<String, List<Map<String, String>>>> {
  final box = GetStorage();

  @override
  Map<String, List<Map<String, String>>> build() {
    return {};
  }
  final List<Map<String, dynamic>> notifications = [];
  Future<void> notification(BuildContext context) async {
    final response = await ApiService().get("v1/${roles}/notifications", {}, context);
    if (response == null) return;
    final rawData = response['data'];
    notifications.clear();
    if (rawData is List) {
      for (var item in rawData) {
        if (item is Map<String, dynamic>) notifications.add(item);
      }
    } else if (rawData is Map<String, dynamic>) {
      // لو data جاء Map فيه groups
      final groups = rawData['groups'];
      if (groups is List) {
        for (var item in groups) {
          if (item is Map<String, dynamic>) notifications.add(item);
        }
      }
    }

    print(notifications);
  }
}

final notifications_riverpod = NotifierProvider<NotificationsNotifier, Map<String, List<Map<String, String>>>>(
  NotificationsNotifier.new,
);
