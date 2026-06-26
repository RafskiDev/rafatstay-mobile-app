import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Service/ApiService.dart';
class PageNotifier extends Notifier<int> {
  List<Map<String, dynamic>> meals = [];
  int currentIndex=0;
  int slected = 1;

  @override
  int build() {
    return 0;
  }
  void changeSelected(int index) {
    slected = index;
    state++;
  }

  void changePage(int index){
    state = index;
    currentIndex=index;
    ref.notifyListeners();
  }
  Map<String, dynamic>? mealData;
  bool isLoadingMeal = false;

  Future<void> fetchMealDetails(BuildContext context, int menuItemId) async {
    isLoadingMeal = true;
    state = state + 1;
    final response = await ApiService().get(
      "v1/$roles/menu-items/$menuItemId",
      null,
      context,
    );
    isLoadingMeal = false;

    if (response?["success"] == true) {
      mealData = response["data"];
      // تحديث الـ meals للكاروسيل من media_paths
      final mediaPaths = mealData?["media_paths"] as List? ?? [];
      if (mediaPaths.isNotEmpty) {
        meals = mediaPaths.map<Map<String, dynamic>>((url) => {"image": url}).toList();
      }
    }
    state = state + 1;
  }
  List<dynamic> branches = [];
  Future<void> branch(BuildContext context) async {
    final branchId = mealData?["branch"]?["id"]; // يجيب 1 من mealData
    branches.clear();
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId",
      {},
      context,
    );
    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {

      branches = [response['data']];
    } else {
      branches = [];
    }
    if (branches.isNotEmpty) {
      final photos = branches[0]['photos'];

      for (var photo in photos) {
       // print(photo['url']);
      }
    }
    ref.notifyListeners();
  }

}

final MealDetails_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);