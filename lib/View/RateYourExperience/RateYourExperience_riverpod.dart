import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  TextEditingController controller = TextEditingController(); // tip_amount
  FocusNode focusNodeController = FocusNode();
  TextEditingController birthday = TextEditingController(); // birthday
  FocusNode focusNodeBirthday = FocusNode();

  // ✅ overall_rating + atmosphere_rating
  final ratings = [
    {"title": "Overall rating", "icon": "assets/icon/restaurant.svg", "rate": 0},
    {"title": "Atmosphere", "icon": "assets/icon/restaurant.svg", "rate": 0},
  ];

  // ✅ food_rating + service_rating
  final services = [
    {"title": "Food Quality", "icon": "assets/icon/restaurant.svg", "rate": 0},
    {"title": "Service Speed", "icon": "assets/icon/restaurant.svg", "rate": 0},
  ];

  // ✅ best_employee_id — API يقبل موظف واحد فقط
  final personCard = [
    {"title": "Ahmed Omar (Waiter)", "image": "assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png"},
    {"title": "Ahmed Ali (Chef)", "image": "assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png"},
  ];

  // ❌ غير مدعوم - API لا يقبل sub-ratings للموظفين
  // final reviews = [
  //   {"title": "Attitude", "icon": "assets/icon/restaurant.svg", "rate": 3},
  //   {"title": "Attention to Detail", "icon": "assets/icon/restaurant.svg", "rate": 4},
  // ];

  final Set<int> selectedPersonIndexes = {};

  @override
  int build() {
    ref.onDispose(() {
      controller.dispose();
      focusNodeController.dispose();
      birthday.dispose();
      focusNodeBirthday.dispose();
    });
    return 0;
  }

  void reset() => state = 0;

  void updateRating(int index, int newRate) {
    ratings[index]["rate"] = newRate;
    state++;
  }

  void updateServiceRating(int index, int newRate) {
    services[index]["rate"] = newRate;
    state++;
  }

  // ❌ غير مدعوم - حذف بسبب حذف reviews list
  // void updateReviewRating(int index, int newRate) {
  //   reviews[index]["rate"] = newRate;
  //   state++;
  // }

  void togglePersonSelection(int index) {
    if (selectedPersonIndexes.contains(index)) {
      selectedPersonIndexes.remove(index);
    } else {
      selectedPersonIndexes.add(index);
    }
    state++;
  }

  List<String> getSelectedPersonNames() {
    return selectedPersonIndexes
        .map((i) => personCard[i]["title"].toString())
        .toList();
  }

  Map<String, dynamic> buildReviewBody({required int branchId}) {
    return {
      "branch_id": branchId,
      "overall_rating": ratings[0]["rate"],
      "atmosphere_rating": ratings[1]["rate"],
      "food_rating": services[0]["rate"],
      "service_rating": services[1]["rate"],
      if (controller.text.isNotEmpty)
        "tip_amount": double.tryParse(controller.text),
      if (birthday.text.isNotEmpty)
        "birthday": birthday.text,
      if (selectedPersonIndexes.isNotEmpty)
        "best_employee_id": selectedPersonIndexes.first + 1,
    };
  }

  Future<void> submitReview({required int branchId, required BuildContext context}) async {
    final body = buildReviewBody(branchId: branchId);

    final response = await ApiService().post(
      "v1/guest/reviews",
      body,
      context,
    );
    if (!context.mounted) return;
    if (response != null) {
      ToastMessages(
        context,
        TextLanguage().GetWord("تم إرسال التقييم بنجاح!"),
        Themes().GetColor("success"),
        Themes().GetColor("white"),
      );
    }
  }

}

final RateYourExperience_riverpod =
NotifierProvider<PageNotifier, int>(PageNotifier.new);