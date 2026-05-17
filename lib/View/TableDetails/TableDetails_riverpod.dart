import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  List<Map<String, dynamic>> items = [];
  bool isTableChosen = false;

  @override
  int build() => 0;
  void changePage(int index) {
    state = index;
  }
  void changePage_() {
    isTableChosen = !isTableChosen;
    ref.notifyListeners();
  }
  Map<String, dynamic>? tableDetails;
  bool isLoadingTable = false;

  Future<void> fetchTableDetails(
      BuildContext context,
      int branchId, {
        String? date,
        String? startTime,
        String? endTime,
        int? partySize,
      }) async {
    final response = await ApiService().get(
      "v1/guest/branches/$branchId/tables",
      {
      //  if (date != null) "date": date,
      //  if (partySize != null) "party_size": partySize,
      },
      context,
    );

    if (response?["success"] == true) {
      tableDetails = response["data"];
    } else {
      ToastMessages(
        context,
        response?["message"] ?? "فشل جلب تفاصيل الطاولة",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
    print(tableDetails);
    state++;
  }
}

final TableDetails_riverpod =NotifierProvider<PageNotifier, int>(PageNotifier.new);

