import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';

class FiltersNotifier extends Notifier<int> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  // Data from API
  List<Map<String, dynamic>> cuisines = [];
  List<Map<String, dynamic>> ratings = [];
  List<Map<String, dynamic>> areas = [];

  // Selected filters
  List<String> selectedCuisines = [];
  String? selectedRating;
  String? selectedArea;



  @override
  int build() {
    return 0;
  }

  /// جلب الفلاتر المتاحة من API
  Future<void> getSearchFilters(BuildContext context, {List<String>? categorySlug}) async {


    ApiService api = ApiService();
    TextLanguage textLanguage = TextLanguage();

    ref.notifyListeners();

      // بناء الـ query parameters
      Map<String, dynamic>? queryParams;
      if (categorySlug != null && categorySlug.isNotEmpty) {
        queryParams = {
          'category_slugs': categorySlug,
        };
      }

      final response = await api.get(
        "v1/guest/search/filters",
        queryParams,
        context,
      );
      if (response != null && response["success"] == true) {
        final data = response["data"];

        cuisines = (data["cuisines"] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ?? [];

        ratings = (data["ratings"] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ?? [];

        areas = (data["areas"] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ?? [];
        print(areas);

      } else {
        ToastMessages(
          context,
          "فشل تحميل الفلاتر",
          Colors.red,
          Colors.white,
        );
      }
  }

  /// تبديل اختيار المطبخ
  void toggleCuisine(String key) {
    if (selectedCuisines.contains(key)) {
      selectedCuisines.remove(key);
    } else {
      selectedCuisines.add(key);
    }
    ref.notifyListeners();
  }

  /// فحص إذا كان المطبخ محدد
  bool isCuisineSelected(String key) {
    return selectedCuisines.contains(key);
  }

  /// اختيار التقييم (واحد فقط)
  void selectRating(String key) {
    // إذا ضغط على نفس التقييم، يلغيه
    if (selectedRating == key) {
      selectedRating = null;
    } else {
      selectedRating = key;
    }
    ref.notifyListeners();
  }

  /// فحص إذا كان التقييم محدد
  bool isRatingSelected(String key) {
    return selectedRating == key;
  }

  Future<List<dynamic>> searchWithFilters(BuildContext context, {int perPage = 20}) async {
    ApiService api = ApiService();

    try {
      // بناء queryParams
      final Map<String, String> queryParams = {};

      if (searchController.text.isNotEmpty) {
        queryParams['query'] = searchController.text;
      }

      if (selectedCuisines.isNotEmpty) {
        // تحويل المصفوفة لنص مفصول بفواصل
       // queryParams['cuisines'] = selectedCuisines.join(',');
        for (String cuisine in selectedCuisines) {
          queryParams['cuisines[$cuisine]'] = cuisine;
        }
      }

      if (selectedRating != null) {
       // queryParams['rating'] = selectedRating!;
        queryParams['min_rating'] = selectedRating!;
      }

      if (selectedArea != null && selectedArea!.isNotEmpty) {
        queryParams['area'] = selectedArea!;
      }

      queryParams['per_page'] = perPage.toString();
     /// print(queryParams);

      final response = await api.get('v1/guest/search',queryParams,context);
    //  print("✅ Search Response: $response");

      if (response != null && response['success'] == true) {

        final data = response['data'];

        /// نتائج الفروع
        if (data['branches'] != null &&
            data['branches']['items'] is List) {
          return data['branches']['items'];
        }

        /// نتائج المنيو
        if (data['menu_items'] != null &&
            data['menu_items']['items'] is List) {
          return data['menu_items']['items'];
        }
      }

      return [];
    } catch (e) {
      print("❌ Error in searchWithFilters: $e");
      return [];
    }
  }

}


final Filters_riverpod = NotifierProvider<FiltersNotifier, int>(FiltersNotifier.new);