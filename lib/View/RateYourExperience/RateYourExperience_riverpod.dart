import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNodeController = FocusNode();
  TextEditingController birthday = TextEditingController();
  FocusNode focusNodeBirthday = FocusNode();
  int selectedPersonIndex = -1;
  final ratings = [
    {"title": "Overall rating","icon":"assets/icon/restaurant.svg", "rate": 3},
    {"title": "Atmosphere","icon":"assets/icon/restaurant.svg", "rate": 4},
  ];
  final services = [
    {"title": "Food Quality","icon":"assets/icon/restaurant.svg","rate": 3},
    {"title": "Service Speed","icon":"assets/icon/restaurant.svg","rate": 4},
];
  final personCard =[
    {"title": "Ahmed Omar (Waiter)","icon":"assets/icon/restaurant.svg","image": "assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png"},
    {"title": "Ahmed Ali (Chef)","icon":"assets/icon/restaurant.svg","image": "assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png"},
  ];
  final reviews = [
    {"title": "Attitude","icon":"assets/icon/restaurant.svg", "rate": 3},
    {"title": "Attention to Detail","icon":"assets/icon/restaurant.svg", "rate": 4},
  ];

  @override
  int build() {
    return 0;
  }

  void reset(){
    state=0;
  }
  void updateRating(int index, int newRate) {
    ratings[index]["rate"] = newRate;
    state++; // 🔥 لإجبار إعادة البناء
  }
  void updateServiceRating(int index, int newRate) {
    services[index]["rate"] = newRate;
    state++;
  }
  void updateReviewRating(int index, int newRate) {
    reviews[index]["rate"] = newRate;
    state++;
  }
  final Set<int> selectedPersonIndexes = {};

  void togglePersonSelection(int index) {
    if (selectedPersonIndexes.contains(index)) {
      selectedPersonIndexes.remove(index); // إلغاء التحديد
    } else {
      selectedPersonIndexes.add(index); // تحديد
    }
    state++; // trigger rebuild
  }

  /// 🔥 ترجع أسماء الأشخاص المحددين
  List<String> getSelectedPersonNames() {
    return selectedPersonIndexes
        .map((i) => personCard[i]["title"].toString())
        .toList();
  }
}

final RateYourExperience_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);