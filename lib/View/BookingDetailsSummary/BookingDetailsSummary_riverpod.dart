import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {

  @override
  int build() {
    return 0;
  }

  Map<String, dynamic>? reviewData;
  bool isLoadingReview = false;

  Future<void> fetchReview(BuildContext context, int bookingId) async {
    isLoadingReview = true;
    state = state + 1;

    final response = await ApiService().get(
      "v1/guest/bookings/$bookingId/review",
      {},
      context,
    );

    isLoadingReview = false;

    if (response?["success"] == true) {
      reviewData = response["data"];
    } else {
      ToastMessages(
        context,
        response?["message"] ?? "فشل جلب تفاصيل السعر",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }

    state = state + 1;
  }

  Future<void> rebook(BuildContext context, int bookingId, Map<String, dynamic> booking) async {
    String formatTime(String? time) {
      if (time == null) return "";
      final parts = time.split(":");
      if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
      return time;
    }
    final body = {
      "booking_date": booking["booking_date"],
      "start_time": formatTime(booking["start_time"]?.toString()),
      "end_time": formatTime(booking["end_time"]?.toString()),
    };
    final response = await ApiService().post(
      "v1/guest/bookings/$bookingId/rebook",
      body,
      context,
    );
    if (response?["success"] == true) {
      ToastMessages(
        context,
        TextLanguage().GetWord("تم إعادة الحجز بنجاح"),
        Themes().GetColor("success"),
        Themes().GetColor("white"),
      );
    } else {
      ToastMessages(
        context,
        TextLanguage().GetWord("فشل إعادة الحجز"),
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }
}

final BookingDetailsSummary_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
