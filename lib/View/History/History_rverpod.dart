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

  List<Map<String, dynamic>> bookInProgress = [];
  List<Map<String, dynamic>> statusForRestaurants=[];
  Future<void> fetchHistoryScreen({required BuildContext context}) async {
    ApiService api = ApiService();
    final res = await api.get(
      "v1/guest/bookings/history-screen",
      {},
      context,
    );

    if (res?["success"] == true) {
      final data = res?['data'];
      final sections = data?['sections'] ?? {};
      final allBookings = sections['all_bookings']?['items'] ?? [];
      final statusForRestaurants = sections['status_for_restaurants']?['items'] ?? [];
      bookInProgress = List<Map<String, dynamic>>.from(allBookings);
      this.statusForRestaurants=List<Map<String, dynamic>>.from(statusForRestaurants);
      ref.notifyListeners();
    } else {
      ToastMessages(
        context,
        res?["message"] ?? "خطأ في جلب البيانات",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }
}


final History_rverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
