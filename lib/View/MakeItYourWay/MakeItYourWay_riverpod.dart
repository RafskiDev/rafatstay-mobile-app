import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import 'MakeItYourWay.dart';

class PageNotifier extends Notifier<int> {
  TextEditingController controller = TextEditingController();
  int? branchId;
   // 1. ما يظهر للمستخدم في الشاشة (UI)
  final cookingTypes = ["Grilled", "Fried", "Baked", "Steamed", "Air Fried"];
  final cookingTypes_ = ["Rare", "Medium Rare", "Medium", "Medium Well", "Well Done"];
  // 2. ما يجب إرساله للخادم (API) - 🔴 يرجى التأكد من هذه القيم مع مطور الخادم
  final apiCookingTypes = ["grilled", "fried", "baked", "steamed", "air_fried"];
  final apiDonenessTypes = ["rare", "medium_rare", "medium", "medium_well", "well_done"];
  int selectedCookingTypeIndex = -1;
  int selectedCookingTypeIndex_ = -1;

  List<Map<String, dynamic>> menuItems = [];

  @override
  int build() => 0;

  /// إضافة صنف من المنيو إلى سلة المستخدم.
  /// يُستخدم في تدفق Order to Go — يجب استدعاء [checkout] بعد اكتمال السلة.
  /// [branchId] معرف الفرع، [menuItemId] معرف الصنف، [quantity] الكمية المطلوبة.
  Future<void> addItemToCart({
    required BuildContext context,
    required int branchId,
    required String menuItemId,
    required int quantity,
    String? notes,
    String? cookingMethod,
    String? doneness,
  }) async {
    final response = await ApiService().post(
      "v1/$roles/cart/items",
      {
        "branch_id": branchId,
        "menu_item_id": menuItemId,
        "quantity": quantity,
        "order_type": "dine_in",//dine_in / takeaway
        if (notes != null && notes.isNotEmpty) "notes": notes,
        if (cookingMethod != null) "cooking_method": cookingMethod,
        if (doneness != null) "doneness": doneness,
      },
      context,
    );
    print("addItemToCart: $response");
  }

  void increaseCount(int index, BuildContext context, int branchId) {
    if (menuItems[index]['potsEmpty'] == true) {
      menuItems[index]['count'] = (menuItems[index]['count'] ?? 0) + 1;
      ref.notifyListeners();
    } else {
      showCustomDialog(context);
    }
  }

  void deleteMeal(int index) {
    if ((menuItems[index]['count'] ?? 0) > 1) {
      menuItems[index]['count'] = (menuItems[index]['count'] ?? 0) - 1;
      ref.notifyListeners();
    }
  }

  bool isSelected(int index) => selectedCookingTypeIndex == index;
  void setSelectedCookingType(int index) {
    if (selectedCookingTypeIndex == index) {
      selectedCookingTypeIndex = -1;
    } else {
      selectedCookingTypeIndex = index;
    }
    ref.notifyListeners();
  }

  bool isSelected_(int index) => selectedCookingTypeIndex_ == index;
  void setSelectedCookingType_(int index) {
    if (selectedCookingTypeIndex_ == index) {
      selectedCookingTypeIndex_ = -1;
    } else {
      selectedCookingTypeIndex_ = index;
    }
    ref.notifyListeners();
  }
  void saveCustomizationsToSelectedMeals() {
    final method = selectedCookingTypeIndex == -1 ? "" : apiCookingTypes[selectedCookingTypeIndex];
    final doneness = selectedCookingTypeIndex_ == -1 ? "" : apiDonenessTypes[selectedCookingTypeIndex_];
    final note = controller.text;

    for (var i = 0; i < menuItems.length; i++) {
      // نتحقق إذا كانت الوجبة محددة من قبل المستخدم
      if (selectedIds.contains(menuItems[i]["id"].toString())) {
        menuItems[i]["selectedCookingType"] = method;
        menuItems[i]["selectedDoneness"] = doneness;
        menuItems[i]["notes"] = note;
      }
    }
  }
  Map<String, dynamic> getItemsForBooking() {
    // هذه الدالة ستقوم الآن بإرجاع الوجبات المحددة (مع الملاحظات) والوجبات الأخرى (بدون ملاحظات)
    final itemsToBook = menuItems.where((m) => (m["count"] ?? 0) > 0 || selectedIds.contains(m["id"].toString())).toList();

    return {
      "items": itemsToBook.map((m) {
        final itemMap = {
          "id": m["id"].toString(),
          "menu_item_id": m["id"].toString(),
          "title": m["title"],
          "price": m["price"],
          "quantity": m["count"] ?? 1,
        };

        if ((m["notes"] ?? "").toString().isNotEmpty) {
          itemMap["notes"] = m["notes"];
        }
        if ((m["selectedCookingType"] ?? "").toString().isNotEmpty) {
          itemMap["cooking_method"] = m["selectedCookingType"];
        }
        if ((m["selectedDoneness"] ?? "").toString().isNotEmpty) {
          itemMap["doneness_level"] = m["selectedDoneness"];
        }

        return itemMap;
      }).toList(),
    };
  }
  Set<String> selectedIds = {};

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id); // إزالة إذا موجود
    } else {
      selectedIds.add(id);    // إضافة الجديد
    }
    state = state + 1; // بدل ref.notifyListeners()
  }
  void refresh() {
    state = state + 1;
  }
}

final MakeItYourWay_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);