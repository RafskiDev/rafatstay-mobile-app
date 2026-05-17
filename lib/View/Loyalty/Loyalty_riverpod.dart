import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

class LoyaltyNotifier extends Notifier<Map<String, List<Map<String, dynamic>>>> {
  @override
  Map<String, List<Map<String, dynamic>>> build() => {};

  List<dynamic> loyaltyHistory = [];

  Future<void> fetchLoyaltyHistory(BuildContext context, {String? type}) async {
    final response = await ApiService().get(
      "v1/$roles/loyalty/history",
      {if (type != null) "type": type},
      context,
    );

    if (response?["success"] == true) {
      final data = response["data"];
      if (data is List) {
        loyaltyHistory = data;
      } else if (data is Map) {
        loyaltyHistory = data["items"] ?? data["data"] ?? [];
      }
      state = _groupByDate(loyaltyHistory);
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(List<dynamic> items) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    for (var item in items) {
      final map = Map<String, dynamic>.from(item);
      DateTime date = DateTime.tryParse(map["created_at"] ?? "") ?? now;
      DateTime simpleDate = DateTime(date.year, date.month, date.day);

      String key;
      if (simpleDate == today) {
        key = 'Today';
      } else if (simpleDate == yesterday) {
        key = 'Yesterday';
      } else {
        const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        key = weekdays[simpleDate.weekday - 1];
      }

      grouped.putIfAbsent(key, () => []).add(map);
    }

    return grouped;
  }
  Map<String, dynamic>? loyaltyProfile;
  Future<void> fetchLoyaltyProfile(BuildContext context) async {
    final response = await ApiService().get(
      "v1/$roles/loyalty/profile",
      {},
      context,
    );

    if (response?["success"] == true) {
      loyaltyProfile = response["data"];
      state = {...state};
    }
  }
}

final Loyalty_riverpod = NotifierProvider<LoyaltyNotifier, Map<String, List<Map<String, dynamic>>>>(
  LoyaltyNotifier.new,
);