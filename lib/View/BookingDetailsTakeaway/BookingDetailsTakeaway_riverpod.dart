import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  bool selected = false;
  TextEditingController CarPlate = TextEditingController();
  TextEditingController CarColor = TextEditingController();
  FocusNode CarPlateNode = FocusNode();
  FocusNode CarColorNode = FocusNode();
  final TextLanguage textLanguage = TextLanguage();

  List<Map<String, String>> items = [
    {"image": "assets/icon/SiteData.svg", "title": "10/1"},
    {"image": "assets/icon/hour.svg", "title": "12:30"},
    {"image": "assets/icon/user_plus.svg", "title": "2"},
    {"image": "assets/icon/children.svg", "title": "0"},
    {"image": "assets/icon/DineIn.svg", "title": "Dine In"},
  ];

  @override
  int build() => 0;
  void resetToDefault() {
    selected = false;
    CarPlate.clear();
    CarColor.clear();
    CarPlateNode = FocusNode();
    CarColorNode = FocusNode();

    items = [
      {"image": "assets/icon/SiteData.svg", "title": "10/1"},
      {"image": "assets/icon/hour.svg", "title": "12:30"},
      {"image": "assets/icon/user_plus.svg", "title": "2"},
      {"image": "assets/icon/children.svg", "title": "0"},
      {"image": "assets/icon/DineIn.svg", "title": "Dine In"},
    ];

    bookingDetails = null;
    isLoadingDetails = false;
    garage.clear();

    state = 0; // ← إعادة الحالة الرئيسية
    ref.notifyListeners();
  }

  void loadFromBookingData(Map<String, dynamic> data) {
    String formattedDate = "";
    try {
      final date = DateTime.parse(data['booking_date']?.toString() ?? "");
      formattedDate = "${date.day}/${date.month}";
    } catch (_) {}

    // ── تحويل الوقت من "02:43:00" إلى "02:43" ──
    String formattedTime = "";
    try {
      final timeParts = (data['end_time']?.toString() ?? "").split(":");
      if (timeParts.length >= 2) {
        formattedTime = "${timeParts[0]}:${timeParts[1]}";
      }
    } catch (_) {}
    items.clear();
    items = [
      {"image": "assets/icon/SiteData.svg", "title": formattedDate},
      {"image": "assets/icon/hour.svg", "title": formattedTime},
      {
        "image": "assets/icon/user_plus.svg",
        "title": data['party_size']?.toString() ?? "0",
      },
      {
        "image": "assets/icon/children.svg",
        "title": data['children_count']?.toString() ?? "0",
      },
      {
        "image": "assets/icon/DineIn.svg",
        "title": data['service_mode_translated']?.toString() ?? "",
      },
    ];
    ref.notifyListeners();
  }

  void selectIndex(int index) {
    if (index == 0) {
      state = (state == 1) ? 0 : 1;
    } else if (index == 1) {
      state = (state == 2) ? 0 : 2;
    }
  }

  bool isFirstSelected() => state == 1;
  bool isSecondSelected() => state == 2;
  Future<Map<String, dynamic>?> createTakeawayBooking({
    required BuildContext context,
    required Map<String, dynamic> bookingData,
  }) async {
    // بناء items من menuItems
    final menuItems = (bookingData["menuItems"] as List? ?? []);
    final items = menuItems.map((m) => {
      "menu_item_id": m["id"],
      "item_name": m["title"],
      "quantity": m["count"] ?? 1,
      "cooking_method": m["cooking_method"],
      "doneness_level": m["doneness_level"],
      "notes": m["notes"],
    }).toList();

    final body = {
      "branch_id": bookingData["branch_id"],
      "booking_date": bookingData["booking_date"],
      "start_time": bookingData["start_time"],
      "end_time": bookingData["end_time"],
      "party_size": bookingData["party_size"] ?? 1,
      "children_count": bookingData["children_count"] ?? 0,
      "service_mode": "takeaway",
      "special_requests": bookingData["special_requests"],
      if (items.isNotEmpty) "items": items,

      // باركينج
      if (bookingData["needs_parking"] == true) ...{
        "needs_parking": true,
        "parking_hours": bookingData["parking_hours"],
        "parking_location": bookingData["parking_location"],
        "car_plate": bookingData["car_plate"],
        "car_color": bookingData["car_color"],
      },
    };

    final response = await ApiService().post(
      "v1/$roles/bookings",
      body,
      context,
    );
    if (response?["success"] == true) {
      ToastMessages(
        context,
        "تم إنشاء الحجز بنجاح",
        Colors.green,
        Colors.white,
      );
      return response["data"];
    } else {
      print(response);
      ToastMessages(
        context,
        response?["message"] ?? "فشل إنشاء الحجز",
        Colors.red,
        Colors.white,
      );
      return null;
    }
  }
  Map<String, dynamic>? bookingDetails;
  bool isLoadingDetails = false;

  Future<void> fetchBookingDetails(BuildContext context, int bookingId) async {
    isLoadingDetails = true;
    state = state + 1;
    final response = await ApiService().get(
      "v1/guest/bookings/$bookingId",
      {},
      context,
    );

    isLoadingDetails = false;

    if (response?["success"] == true) {
      bookingDetails = response["data"];
    } else {

      ToastMessages(
        context,
        response?["message"] ?? "فشل جلب تفاصيل الحجز",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
    print(response);

    state = state + 1;
  }
  List<dynamic> garage = [];
  Future<void> garages(BuildContext context, int? branchId) async {
    garage.clear();
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId/parking",
      {},
      context,
    );
    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {

      garage = [response['data']];
    } else {
      garage = [];
    }
    ref.notifyListeners();
  }
  String translateMode(String? val) {
    if (val == null) return "";
    switch (val.trim().toLowerCase()) {
      case 'indoor':
        return textLanguage.GetWord('داخلي'); // ستترجم لعربي أو إنجليزي حسب اللغة الحالية
      case 'outdoor':
        return textLanguage.GetWord('خارجي');
      default:
        return val; // ترجع القيمة كما هي لو لم تكن indoor أو outdoor
    }
  }
}

final BookingDetailsTakeaway_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
