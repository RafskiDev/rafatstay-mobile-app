import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  @override
  int build() => 0;
  bool like=false;
  void resetBooking() {
    state = 0;
    ref.notifyListeners();
  }

  void changePage(int index) {
    state = index;
  }
  List<Map<String, dynamic>> bookCompleted = [];
  Future<void> booking({required BuildContext context, required String status}) async {
    ApiService api = ApiService();
    final Map<String, String> params = {};
    params["status"] = status;
    final res = await api.get(
      "v1/$roles/bookings",
      {},
      context,
    );
    if (res?["success"] == true) {
      final data = res?['data'];
      final items = data?['items'] ?? [];
      bookCompleted =List<Map<String, dynamic>>.from(items);
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

final History_rverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
