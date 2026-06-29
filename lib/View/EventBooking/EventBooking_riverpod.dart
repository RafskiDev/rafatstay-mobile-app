import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void resetBooking() {
    selectedItemIds = [];
    selectedTableIndex = null;
    eventData = {};
    menuItems = [];
    tables = [];
    itemCounts = {};
    state = 0;
    ref.notifyListeners();
  }

  List<dynamic> menuItems = [];
  List<dynamic> tables = [];
  Map<String, dynamic> eventData = {};
  Map<int, int> itemCounts = {};

  List<String> get tabTitles =>
      menuItems.map((m) => m["name"]?.toString() ?? "").toList();

  List<dynamic> get currentItems {
    if (menuItems.isEmpty) return [];
    final items = menuItems[state]["items"] as List? ?? [];
    return items.map((item) {
      final id = item["id"] as int? ?? 0;
      return {
        "id": id,
        "title": item["name"] ?? "",
        "time": (item["prep_time"] ?? "0").toString().replaceAll(RegExp(r'[^0-9-]'), ''),
        "image": fixImageUrl(item["image"]?.toString()),
        "is_spicy": item["is_spicy"] ?? false,
        "potsEmpty": true,
        "count": itemCounts[id] ?? 0,
        "price": item["price"]?.toString() ?? "0",
        "isEvent": true
      };
    }).toList();
  }

  void changePage(int index) {
    state = index;
  }

  List<int> selectedItemIds = [];

  void incrementItem(int itemId) {
    itemCounts[itemId] = (itemCounts[itemId] ?? 0) + 1;
    if (!selectedItemIds.contains(itemId)) {
      selectedItemIds.add(itemId);
    }
    ref.notifyListeners();
  }

  void decrementItem(int itemId) {
    final current = itemCounts[itemId] ?? 0;
    if (current <= 1) {
      itemCounts.remove(itemId);
      selectedItemIds.remove(itemId);
    } else {
      itemCounts[itemId] = current - 1;
    }
    ref.notifyListeners();
  }

  void toggleItem(int itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
      itemCounts.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
      itemCounts[itemId] = 1;
    }
    ref.notifyListeners();
  }

  Map<String, dynamic>? get selectedTable {
    if (selectedTableIndex == null) return null;
    final table = tables[selectedTableIndex!];
    return {
      "table_id": table["id"],
      "table_name": "Table #${table["id"]}",
      "location_type": table["location_type"] ?? "",
      "table_price": table["price"]?.toString() ?? "0.00",
    };
  }

  Map<String, dynamic> get bookingPayload => {
    "event_id": eventData["id"],
    "table": selectedTableIndex != null ? tables[selectedTableIndex!] : null,
    "items": selectedItemIds.map((id) {
      return menuItems
          .expand((menu) => (menu["items"] as List? ?? []))
          .firstWhere((item) => item["id"] == id, orElse: () => {});
    }).toList(),
  };

  int? selectedTableIndex;

  void selectTable(int index, bool? isAvailable) {
    if (isAvailable == false) return;
    if (selectedTableIndex == index) {
      selectedTableIndex = null;
    } else {
      selectedTableIndex = index;
    }
    ref.notifyListeners();
  }

  Future<void> event(BuildContext context, int eventId) async {
    ApiService api = ApiService();
    final res = await api.get(
      "v1/$roles/events/$eventId",
      {},
      context,
    );
    if (res?["success"] == true) {
      final data = res["data"] as Map<String, dynamic>;
      eventData = data;
      menuItems = data["menus"] ?? [];
      tables = data["tables"] ?? [];
      ref.notifyListeners();
    } else {
      ToastMessages(
        context,
        res?["message"] ?? "خطأ في جلب المنيو",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }

  String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    const base = "https://api.rafatstay.com/uploads/";
    if (url.contains("$base$base")) {
      return url.replaceFirst(base, "");
    }
    return url;
  }
}

final EventBooking_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);