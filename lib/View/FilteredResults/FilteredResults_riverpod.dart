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
    final String type = item["type"] ?? "branch"; // ✅
  //  print(type);
    final response = await ApiService().post(
      "v1/guest/favorites/toggle",
      {
        "item_id": item["id"],
        "type":type,
      },
      context,
    );
    ref.notifyListeners();
    if (response != null) {
      final updated = [...state];

      updated[index] = {
        ...updated[index],
        "liked": !(updated[index]["liked"] ?? false),
      };

      state = updated;
    }
    ref.notifyListeners();
  }
}

final filteredResultsProvider =
NotifierProvider<PageNotifier, List<Map<String, dynamic>>>(
  PageNotifier.new,
);
