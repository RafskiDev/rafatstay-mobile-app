import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart' show Themes;
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  final box = GetStorage();
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  int selectedIndex = 0;
  int selectedCarouselIndex = 0;
  TextLanguage textLanguage = TextLanguage();

  Map<String, dynamic>? offerData;

  List<Map<String, dynamic>> carouselItems = [];
  List<Map<String, dynamic>> items = [];
  var includedItems = [];

  @override
  int build() => 0;

  void changePage(int index) {
    state = index;
  }

  Future<void> fetchOfferDetails(BuildContext context, int offerId) async {
    ApiService api = ApiService();
    final res = await api.get(
      "v1/guest/offers/$offerId",
      {},
      context,
    );
    if (res?["success"] == true) {
      offerData = res["data"];
      carouselItems = [];
      items = [];
      if (offerData?["image_url"] != null) {
        carouselItems = [
          {"image": offerData!["image_url"]}
        ];
      }
      if (offerData?["included_items"] != null) {
        items = List<Map<String, dynamic>>.from(
          offerData!["included_items"].map(
                (e) => Map<String, dynamic>.from(e),
          ),
        );
      }
      ref.notifyListeners();
    } else {
      // ✅ نظف البيانات وأعلم الـ UI
      offerData = null;
      carouselItems = [];
      items = [];
      ref.notifyListeners();

    }
  }


}

final OffersDetails_riverpod =
NotifierProvider<PageNotifier, int>(PageNotifier.new);