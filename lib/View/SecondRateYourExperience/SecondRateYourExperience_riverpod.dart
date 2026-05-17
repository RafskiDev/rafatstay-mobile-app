import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNodeController = FocusNode();

  final ratings = [
    {"title": "Overall rating","icon":"assets/icon/restaurant.svg", "rate": 3},
    {"title": "Atmosphere","icon":"assets/icon/restaurant.svg", "rate": 4},
  ];
  final services = [
    {"title": "Food Quality","icon":"assets/icon/restaurant.svg","rate": 3},
    {"title": "Service Speed","icon":"assets/icon/restaurant.svg","rate": 4},
  ];


  @override
  int build() {
    return 0;
  }

  void reset(){
    state=0;
  }

}

final SecondRateYourExperience_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);