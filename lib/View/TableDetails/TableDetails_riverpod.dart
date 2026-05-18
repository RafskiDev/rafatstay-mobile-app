import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
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
}

final TableDetails_riverpod = NotifierProvider<TablesNotifier, int>(() {
  return TablesNotifier();
});