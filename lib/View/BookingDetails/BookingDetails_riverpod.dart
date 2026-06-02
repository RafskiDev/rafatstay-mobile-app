import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
class PageNotifier extends Notifier<int> {
  bool selected = false;
  TextEditingController CarPlate = TextEditingController();
  TextEditingController CarColor = TextEditingController();
  FocusNode CarPlateNode = FocusNode();
  FocusNode CarColorNode = FocusNode();
  final TextLanguage textLanguage = TextLanguage();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, String>> items = [
    {"image": "assets/icon/SiteData.svg", "title": "10/1"},
    {"image": "assets/icon/hour.svg", "title": "12:30"},
    {"image": "assets/icon/user_plus.svg", "title": "2"},
    {"image": "assets/icon/children.svg", "title": "0"},
    {"image": "assets/icon/DineIn.svg", "title": "Dine In"},
  ];

  @override
  int build() => 0;
  set isLoading(bool value) {
    _isLoading = value;
    ref.notifyListeners();
  }
  void loadFromBookingData(Map<String, dynamic> data) {
    ref.notifyListeners();
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

  String extractHour(String time) {
    return int.parse(time.split(':')[0]).toString();
  }

  void selectIndex(int index) {
    if (index == 0) {
      state = (state & 1) != 0 ? 0 : 1;
    } else if (index == 1) {
      state = (state & 2) != 0 ? 0 : 2;
    }
    ref.notifyListeners();
  }


  bool isFirstSelected() => (state & 1) != 0;
  bool isSecondSelected() => (state & 2) != 0;

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


final BookingDetails_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);