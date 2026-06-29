import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';
import '../../Utils/Them.dart';

class PageNotifier extends Notifier<int> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  int selectedIndex = 0;
  int mainCarouselIndex = 0;
  int cardsCarouselIndex = 0;
  TextLanguage textLanguage = TextLanguage();
  final box = GetStorage();

  // ─── الأيقونات المحلية للتبويبات العلوية فقط ───────────────────────────
  List<Map<String, String>> get events => [
    {"imagePath":'assets/icon/Restaurants.png',"title":textLanguage.GetWord("المطاعم")},
    {"imagePath":'assets/icon/Cafes.png',"title":textLanguage.GetWord("صالات الاستراحة")},
    {"imagePath":'assets/icon/Lounges.png',"title":textLanguage.GetWord("المقاهي")},
    {"imagePath":"assets/icon/OrderToGo.png","title":textLanguage.GetWord("طلب سفري")},
  ];

  String getCategorySlug() {
    switch (selectedIndex) {
      case 0: return "restaurants/";
      case 1: return "lounges/";
      case 2: return "cafes/";
      case 3: return "order-to-go/";
      default: return "restaurants/";
    }
  }
  // ─── البيانات المستلمة من API ───────────────────────────────────────────
  final List<Map<String, dynamic>> homeData = [];

  // الفلاتر من الـ API
  List<Map<String, dynamic>> filtersFromApi = [];
  String activeFilter = "all";

  // الأقسام
  List<Map<String, dynamic>> statuses = [];
  final List<Map<String, dynamic>> eventItems = [];
  final List<Map<String, dynamic>> offerItems = [];
  final List<Map<String, dynamic>> topPicks = [];
  final List<Map<String, dynamic>> closestCheapest = [];
  final List<Map<String, dynamic>> mostOrdered = [];
  final List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> dishOrFlavorItems = [];

  // الفلترة النشطة
  final List<Map<String, dynamic>> filteredItems = [];

  // حالة المفضلة
  final Map<int, bool> favoriteStatus = {};

  // خيارات الترتيب لـ closest & cheapest
  List<Map<String, dynamic>> sortOptions = [];
  String closestCheapestSortBy = "ratio";

  @override
  int build() => 0;

  int selectedCategoryIndex = 0;
  bool showLanguage = false;

  // ─── مفاتيح الأقسام حسب نوع الصفحة ──────────────────────────────────────
  String get _statusKey {
    const keys = ["restaurants_status", "lounges_status", "cafes_status", "order_to_go_status"];
    return keys[selectedIndex];
  }

  String get _topPicksKey {
    return selectedIndex == 3 ? "closest_cheapest" : "top_picks";
  }

  String get _dishKey {
    return selectedIndex == 0 ? "dish_of_the_day" : "flavor_of_the_day";
  }

  String get _offersKey {
    return selectedIndex == 0 ? "offers" : "offers_of_the_day";
  }

  // ─── دوال التحكم في الـ Carousel ────────────────────────────────────────
  void changeMainCarousel(int index) {
    mainCarouselIndex = index;
    ref.notifyListeners();
  }

  void changeCardsCarousel(int index) {
    cardsCarouselIndex = index;
    ref.notifyListeners();
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    ref.notifyListeners();
  }

  void select(int index) {
    state = index;
    selectedIndex = index;
    selectedCategoryIndex = 0;
    cardsCarouselIndex = 0;
    mainCarouselIndex = 0;
    activeFilter = "all";
    ref.notifyListeners();
  }

  void toggleLanguage() {
    showLanguage = !showLanguage;
    ref.notifyListeners();
  }

  // ─── استخراج العناصر من قسم في الـ response ────────────────────────────
  List<Map<String, dynamic>> _extractItems(Map<String, dynamic>? section) {
    if (section == null) return [];
    final items = section['items'];
    if (items is! List) return [];
    return items
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ─── جلب البيانات الرئيسية (طلب واحد فقط!) ─────────────────────────────
  Future<void> fetchHomeData(BuildContext context) async {
    // مسح البيانات القديمة
    _clearAllData();

    final response = await ApiService().get(
      "v1/${_getApiPath()}",
      {"per_page": "5"},
      context,
    );
    final events = response["data"]["sections"]["events"]["items"];
   // print(events);
    if (response == null || response['success'] != true) {
      ref.notifyListeners();
      return;
    }

    final data = response['data'];
    if (data == null) {
      ref.notifyListeners();
      return;
    }
    // حفظ البيانات الكاملة
    if (data is Map<String, dynamic>) {
      homeData.add(data);
    }

    final sections = data['sections'];
    if (sections == null || sections is! Map<String, dynamic>) {
      ref.notifyListeners();
      return;
    }

    // ─── استخراج الفلاتر ─────────────────────────────────────────────────
    final filters = sections['filters'];
    if (filters is List) {
      filtersFromApi = filters
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    // ─── استخراج Status ──────────────────────────────────────────────────
    statuses = _extractItems(sections[_statusKey]);

    // ─── استخراج Events (المطاعم فقط) ───────────────────────────────────
    if (selectedIndex == 0) {
      eventItems.addAll(_extractItems(sections['events']));
    }

    // ─── استخراج Offers ─────────────────────────────────────────────────
    offerItems.addAll(_extractItems(sections[_offersKey]));

    // ─── استخراج Top Picks / Closest Cheapest ───────────────────────────
    if (selectedIndex == 3) {
      // Order to Go: closest_cheapest + most_ordered
      closestCheapest.addAll(_extractItems(sections['closest_cheapest']));
      mostOrdered.addAll(_extractItems(sections['most_ordered']));

      // استخراج خيارات الترتيب
      final ccSection = sections['closest_cheapest'];
      if (ccSection?['sort_options'] is List) {
        sortOptions = (ccSection['sort_options'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } else {
      topPicks.addAll(_extractItems(sections['top_picks']));
    }

    // ─── استخراج Favorites ──────────────────────────────────────────────
    favoriteStatus.clear();
    final favSection = sections['favorites'];
    final favItems = _extractItems(favSection);
    for (var item in favItems) {
      favoriteItems.add({...item, "liked": true});
      final id = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
      if (id != 0) favoriteStatus[id] = true;
    }

    // ─── استخراج Dish of the Day / Flavor of the Day ────────────────────
    final dishSection = sections[_dishKey];
    final dishItems = _extractItems(dishSection);
    for (var item in dishItems) {
      final id = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
      dishOrFlavorItems.add({
        ...item,
        "liked": favoriteStatus[id] ?? false,
      });
    }

    ref.notifyListeners();
  }

  // ─── مسح البيانات ────────────────────────────────────────────────────────
  void _clearAllData() {
    homeData.clear();
    filtersFromApi.clear();
    statuses.clear();
    eventItems.clear();
    offerItems.clear();
    topPicks.clear();
    closestCheapest.clear();
    mostOrdered.clear();
    favoriteItems.clear();
    dishOrFlavorItems.clear();
    filteredItems.clear();
    sortOptions.clear();
    favoriteStatus.clear();
  }

  // ─── مسار الـ API الرئيسي ───────────────────────────────────────────────
  String _getApiPath() {
    const paths = [
      "guest/restaurants",
      "guest/lounges",
      "guest/cafes",
      "guest/order-to-go",
    ];
    return paths[selectedIndex];
  }

  // ─── العناصر المعروضة في الكروت (مع الفلترة) ───────────────────────────
  List<Map<String, dynamic>> get displayItems {
    if (filteredItems.isNotEmpty) return filteredItems;

    if (selectedIndex == 3) return closestCheapest;
    return topPicks;
  }

  // ─── الفلترة باستخدام الـ endpoint المنفصل ──────────────────────────────
  Future<void> filter(BuildContext context, {String filter = "all"}) async {
    activeFilter = filter;
    filteredItems.clear();

    final String safeFilter = filter.trim().isEmpty
        ? "all"
        : filter.trim().toLowerCase().replaceAll(" ", "_");

    final response = await ApiService().get(
      "v1/${_getApiPath()}/filter/$safeFilter",
      {"per_page": "20"},
      context,
    );

    if (response != null && response['data']?['items'] is List) {
      for (var item in response['data']['items']) {
        if (item is Map) {
          filteredItems.add(Map<String, dynamic>.from(item));
        }
      }
    }

    cardsCarouselIndex = 0;
    mainCarouselIndex = 0;
    ref.notifyListeners();
  }

  // ─── تغيير الترتيب في Closest & Cheapest ─────────────────────────────────
  Future<void> changeClosestCheapestSort(BuildContext context, String sortBy) async {
    closestCheapestSortBy = sortBy;
    closestCheapest.clear();

    final lat = box.read("user")?["latitude"];
    final lng = box.read("user")?["longitude"];

    final response = await ApiService().get(
      "v1/guest/order-to-go/closest-cheapest",
      {
        "per_page": "20",
        "sort_by": sortBy,
        if (lat != null) "lat": lat,
        if (lng != null) "lng": lng,
      },
      context,
    );

    if (response != null && response['data']?['items'] is List) {
      for (var item in response['data']['items']) {
        if (item is Map) {
          closestCheapest.add(Map<String, dynamic>.from(item));
        }
      }
    }

    ref.notifyListeners();
  }

  // ─── Toggle Favorite ──────────────────────────────────────────────────────
  Future<void> toggleLike(
      int itemId,
      int index,
      BuildContext context,
      {String type = "branch"}
      ) async {
    final bool isCurrentlyFavorited = favoriteStatus[itemId] ?? false;
    final bool willBeFavorited = !isCurrentlyFavorited;

    // تحديث محلي فوري (Optimistic Update)
    favoriteStatus[itemId] = willBeFavorited;
    _updateFavoriteListLocally(itemId, willBeFavorited, type);
    ref.notifyListeners();

    // إرسال للسيرفر
    final response = await _toggleWithFallback(itemId, type, context);

    if (response != null && response['success'] == true) {
      final bool serverStatus = response['data']?['is_favorited'] == true;
      if (serverStatus != willBeFavorited) {
        // تعديل حسب حالة السيرفر
        favoriteStatus[itemId] = serverStatus;
        _updateFavoriteListLocally(itemId, serverStatus, type);
        ref.notifyListeners();
      }
    } else {
      // التراجع في حالة الفشل
      favoriteStatus[itemId] = isCurrentlyFavorited;
      _updateFavoriteListLocally(itemId, isCurrentlyFavorited, type);
      ref.notifyListeners();
    }
  }

  void _updateFavoriteListLocally(int itemId, bool isFavorited, String type) {
    if (isFavorited) {
      // إضافة للمفضلة إذا لم تكن موجودة
      final exists = favoriteItems.any((e) =>
      (e["id"]?.toString() ?? "") == itemId.toString()
      );
      if (!exists) {
        // البحث عن العنصر في القوائم الأخرى
        Map<String, dynamic>? itemData = _findItemById(itemId);
        if (itemData != null) {
          favoriteItems.insert(0, {
            ...itemData,
            "liked": true,
          });
        }
      }
    } else {
      // حذف من المفضلة
      favoriteItems.removeWhere((e) =>
      (e["id"]?.toString() ?? "") == itemId.toString()
      );
    }
  }

  Map<String, dynamic>? _findItemById(int itemId) {
    // البحث في كل القوائم
    for (var list in [topPicks, closestCheapest, mostOrdered, dishOrFlavorItems]) {
      try {
        final item = list.firstWhere((e) =>
        int.tryParse(e["id"]?.toString() ?? "") == itemId
        );
        return Map<String, dynamic>.from(item);
      } catch (_) {}
    }
    return null;
  }

  Future<Map<String, dynamic>?> _toggleWithFallback(
      int itemId,
      String type,
      BuildContext context
      ) async {
    final response = await ApiService().post(
      "v1/$roles/favorites/toggle",
      {"item_id": itemId, "type": type},
      context,
    );
    if (response != null && response['success'] == true) return response;

    // محاولة بنوع آخر
    final fallbackType = type == "branch" ? "menu_item" : "branch";
    return await ApiService().post(
      "v1/$roles/favorites/toggle",
      {"item_id": itemId, "type": fallbackType},
      context,
    );
  }

  // ─── جلب قائمة المنيو لفرع معين ─────────────────────────────────────────
  List<dynamic> allMeals = [];

  Future<void> fetchMenus(BuildContext context, int branchId) async {
    state = state + 1;

    final response = await ApiService().get(
      "v1/guest/branches/$branchId/menus",
      {},
      context,
    );

    if (response?["success"] == true) {
      final List<dynamic> menus = response["data"] ?? [];
      allMeals = [];

      for (var menu in menus) {
        // عناصر مباشرة
        final items = menu["items"] as List? ?? [];
        for (var item in items) {
          allMeals.add({...item, "menu_name": menu["name"]});
        }

        // أقسام → عناصر
        final sections = menu["sections"] as List? ?? [];
        for (var section in sections) {
          final sectionItems = section["items"] as List? ?? [];
          for (var item in sectionItems) {
            allMeals.add({...item, "section": section["name"]});
          }
        }
      }
    } else {
      ToastMessages(
        context,
        response?["message"] ?? "فشل جلب المنيو",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }
}

// ─── مساعد لfix الصور ──────────────────────────────────────────────────────
String fixImage(String? url) {
  if (url == null || url.isEmpty) return "";
  return url.replaceFirst(
    "https://api.rafatstay.com/uploads/https://api.rafatstay.com/uploads/",
    "https://api.rafatstay.com/uploads/",
  );
}

final Home_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);