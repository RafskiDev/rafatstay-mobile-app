import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class HistoryDescriptionNotifier extends Notifier<void> {
  // متغيرات الحالة
  bool isLoading = false;
  Map<String, dynamic>? bookingDetails;
  String? error;

  @override
  void build() {
    // لا شيء مبدئياً
  }

  Future<void> fetchBookingDetails(int bookingId, BuildContext context) async {
    // بدء التحميل
    isLoading = true;
    bookingDetails = null;
    error = null;
    ref.notifyListeners();

    ApiService api = ApiService();
    final res = await api.get(
      "v1/guest/bookings/$bookingId/history-screen",
      {},
      context,
    );

    if (res?["success"] == true) {
      bookingDetails = res?['data'];
      isLoading = false;
      error = null;
      ref.notifyListeners();
    } else {
      error = res?["message"] ?? "حدث خطأ";
      bookingDetails = null;
      isLoading = false;
      ToastMessages(
        context,
        error!,
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
    ref.notifyListeners();
  }
}

final historyDescriptionProvider = NotifierProvider<HistoryDescriptionNotifier, void>(
  HistoryDescriptionNotifier.new,
);