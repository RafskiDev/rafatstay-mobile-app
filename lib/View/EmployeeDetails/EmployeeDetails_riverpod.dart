import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController reviewController = TextEditingController();

   List<Map<String, dynamic>> reviews = [

  ];

  @override
  int build() => 0;

  Future<void> available(BuildContext context, int branchId)async{
    ApiService api = ApiService();
    final res = await api.get(
      "v1/$roles/branches/$branchId/availability",
      {},
      context,
    );
    print(res);
    return res;
  }

  Future<void> fetchReviews(BuildContext context, int branchId) async {
    ApiService api = ApiService();
    final res = await api.get(
      "v1/$roles/branches/$branchId/reviews",
      {},
      context,
    );

    // التحقق قبل التحويل
    if (res != null &&
        res["data"] != null &&
        res["data"]["data"] != null) {
      reviews = List<Map<String, dynamic>>.from(res["data"]["data"]);
    } else {
      reviews = [];
    }
   // print(reviews);

    reviewController.clear();
    ref.notifyListeners();
  }
  Future<void> addReviewSimple({
    required BuildContext context,
    required int branchId,
    required String comment,
    required int professionalism,
    required int attitudeRating,
    required int attentionRating,

  }) async {
    // جسم الطلب
    final body = {
      "branch_id": branchId,
      "professionalism": professionalism,
      "attitude_rating": attitudeRating,
      "attention_to_detail_rating": attentionRating,
      "overall_rating": (professionalism + attitudeRating + attentionRating) ~/ 3,
      "comment": comment,
      "review_type": "review", // مجرد تقييم
    };

    // إرسال POST
    final res = await ApiService().post(
      "v1/$roles/reviews",
      body,
      context,
    );
    if (res["success"] == true) {
      await fetchReviews(context, branchId);
    } else {
      ToastMessages(context,res?["message"],Colors.red,Colors.white);
    }
  }
  int attitudeRating = 0;
  int attentionRating = 0;
  int professionalism = 0;
}

final EmployeeDetails_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
