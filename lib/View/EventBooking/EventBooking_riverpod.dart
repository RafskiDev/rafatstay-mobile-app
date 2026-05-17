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
    state = 0;
    ref.notifyListeners();
  }
  List<String> get tabTitles =>
      menuItems.map((m) => m["name"]?.toString() ?? "").toList();
  Map<String, dynamic> eventData = {};
  List<dynamic> menuItems = [];
  List<dynamic> tables = [];

  void changePage(int index) {
    state = index;
  }

  List<int> selectedItemIds = [];
  void toggleItem(int itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
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

  Future<void> event(BuildContext context, int branchId) async {
    ApiService api = ApiService();

    final res = await api.get(
      "v1/$roles/events/${branchId}",
      {},
      context,
    );
    if (res?["success"] == true) {
      final data = res["data"] as Map<String, dynamic>;
      eventData = data;                        // ✅ كل بيانات الـ event
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
}

final EventBooking_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
