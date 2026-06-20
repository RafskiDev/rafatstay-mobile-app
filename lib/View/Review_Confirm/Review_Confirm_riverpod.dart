import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  List<Map<String, String>> items = [
    {"image": "assets/icon/SiteData.svg", "title": "10/1"},
    {"image": "assets/icon/hour.svg", "title": "12:30"},
    {"image": "assets/icon/user_plus.svg", "title": "2"},
    {"image": "assets/icon/children.svg", "title": "0"},
    {"image": "assets/icon/DineIn.svg", "title": "Dine In"},
  ];

  Map<String, dynamic>? reviewData;
  bool isLoadingReview = false;

  @override
  int build() => 0;

  void loadFromBookingData(Map<String, dynamic> data) {
    String formattedDate = "";
    try {
      final date = DateTime.parse(data['booking_date']?.toString() ?? "");
      formattedDate = "${date.day}/${date.month}";
    } catch (_) {}

    String formattedTime = "";
    try {
      final parts = (data['start_time']?.toString() ?? "").split(":");
      if (parts.length >= 2) formattedTime = "${parts[0]}:${parts[1]}";
    } catch (_) {}
    items = [
      {"image": "assets/icon/SiteData.svg", "title": formattedDate},
      {"image": "assets/icon/hour.svg", "title": formattedTime},
      {"image": "assets/icon/user_plus.svg", "title": data['party_size']?.toString() ?? "0"},
      {"image": "assets/icon/children.svg", "title": data['children_count']?.toString() ?? "0"},
      {"image": "assets/icon/DineIn.svg", "title":data["service_mode"]=="takeaway"?TextLanguage().GetWord("طلب سفري"):data['service_mode_translated']?.toString()??""},
    ];
    ref.notifyListeners();
  }

  // جلب تفاصيل السعر من الـ API
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
    }

    state = state + 1;
    print(response);
  }


  //للأسعار
  String get mealsTotal => reviewData?["pricing"]?["meals_total"]?.toString() ?? "0";
  String get tablePrice => reviewData?["pricing"]?["table_fee"]?.toString() ?? "0";
  String get parkingFee => reviewData?["pricing"]?["parking_fee"]?.toString() ?? "0";
  String get total => reviewData?["pricing"]?["total"]?.toString() ?? "0";
  String get vat => reviewData?["pricing"]?["vat_amount"]?.toString() ?? "0";
}

final Review_Confirm_riverpod =
NotifierProvider<PageNotifier, int>(PageNotifier.new);