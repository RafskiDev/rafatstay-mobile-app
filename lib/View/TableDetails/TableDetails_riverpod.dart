import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class TablesNotifier extends Notifier<int> {
  // البيانات
  Map<String, dynamic>? tableDetails;
  bool isLoadingDetails = false;
  bool isTableChosen = false;

  @override
  int build() => 0;

  void changePage_() {
    isTableChosen = !isTableChosen;
    ref.notifyListeners();
  }
  void setChosen(bool value) {
    isTableChosen = value;
    ref.notifyListeners();
  }
  Future<void> fetchTableDetails(
      BuildContext context,
      int branchId,
      int tableId, {
        required String date,
        required String startTime,
        required String endTime,
        required int partySize,
      }) async {
    isLoadingDetails = true;
    ref.notifyListeners();

    final response = await ApiService().get(
      "v1/guest/branches/$branchId/tables/$tableId",
      {
        "date": date.toString(),
        "start_time": startTime.toString(),
        "end_time": endTime.toString(),
        "party_size": partySize.toString(),
      },
      context,
    );
    if (response?["success"] == true) {
      tableDetails = response?["data"] as Map<String, dynamic>?;
    } else {
      ToastMessages(
        context,
        response?["message"] ?? "فشل جلب تفاصيل الطاولة",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
      tableDetails = null;
    }

    isLoadingDetails = false;
    ref.notifyListeners();
  }
  String getStatusLabel(String code) {
    switch (code) {
      case 'available':
        return TextLanguage().GetWord("متاحة");
      case 'unavailable':
        return TextLanguage().GetWord("غير متاحة");
      default:
        return code;
    }
  }
  String getLocationLabel(String code) {
    switch (code) {
      case 'indoor':
        return TextLanguage().GetWord("داخلي");
      case 'outdoor':
        return TextLanguage().GetWord("خارجي");
      default:
        return code;
    }
  }
  String getFeatureTitle(String key) {
    switch (key) {
      case 'window':
        return TextLanguage().GetWord("قرب النافذة");
      case 'quiet_area':
        return TextLanguage().GetWord("منطقة هادئة");
      case 'non_smoking':
        return TextLanguage().GetWord("لا تدخين");
      default:
        return key;
    }
  }
  final List<Map<String, dynamic>> staticFeatures = [
    {'icon': 'window'},
    {'icon': 'quiet_area'},
    {'icon': 'non_smoking'},
  ];
}

final TableDetails_riverpod = NotifierProvider<TablesNotifier, int>(() {
  return TablesNotifier();
});