import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart' show Themes;
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  int selectedIndex = 0;
  int selectedCarouselIndex = 0;
  TextLanguage textLanguage = TextLanguage();

  Map<String, dynamic>? offerData;

  List<Map<String, dynamic>> carouselItems = [];
  List<Map<String, dynamic>> items = [];
  var includedItems = [
    {
      "id": 38,
      "title": "ستيك لحم مشوي",
      "description": "ستيك لحم أنجوس مشوي مع صوص خاص",
      "price": 95.00,
      "image": "/storage/menu/grilled-steak.jpg",
      "status": "available",
      "calories": 720,
      "count": 1,
      "is_spicy": false,
      "sold_count": 0,
      "potsEmpty": true,
      "section": "الأطباق الرئيسية",
      "time": null,
    }
  ];

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
      print(offerData);
      ref.notifyListeners();
    } else {
      ToastMessages(
        context,
        res?["message"] ?? "خطأ في جلب تفاصيل العرض",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }

}

final OffersDetails_riverpod =
NotifierProvider<PageNotifier, int>(PageNotifier.new);