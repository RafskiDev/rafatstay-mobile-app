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
    return res;
  }

  Future<void> fetchReviews(BuildContext context, int staffId) async {
    ApiService api = ApiService();
    final res = await api.get(
      "v1/$roles/branches/$staffId/staff",
      {},
      context,
    );
   // print("staff: $res");
    // التحقق قبل التحويل
    if (res != null && res["success"] == true && res["data"] != null) {
      // بنحول الداتا لـ List مباشرة
      reviews = List<Map<String, dynamic>>.from(res["data"]);
    } else {
      reviews = [];
    }
    reviewController.clear();
    ref.notifyListeners();
  }
  Future<void> addReviewSimple({
    required BuildContext context,
    required int staffId,
    required String comment,
    required int professionalism,
    required int attitudeRating,
    required int attentionRating,

  }) async {
    int total = professionalism + attitudeRating + attentionRating;

    if (professionalism == 0 || attitudeRating == 0 || attentionRating == 0) {
      ToastMessages(context, "الرجاء إعطاء تقييم لجميع الحقول", Colors.red, Colors.white);
      return;
    }
    final body = {
      "professionalism": professionalism,
      "attitude_rating": attitudeRating,
      "attention_to_detail_rating": attentionRating,
      "overall_rating": total ~/ 3,
      "comment": comment,
      "review_type": "review", // مجرد تقييم
    };

    // إرسال POST
    final res = await ApiService().post(
      "v1/$roles/staff/${staffId}/reviews",
      body,
      context,
    );
    if (res["success"] == true) {
      print(res);
      ToastMessages(context,"نجح ارسال التقيم",Colors.green,Colors.white);
      await fetchReviews(context, staffId);
    } else {
      ToastMessages(context,res?["message"],Colors.red,Colors.white);
    }
  }
  int attitudeRating = 0;
  int attentionRating = 0;
  int professionalism = 0;
}

final EmployeeDetails_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
