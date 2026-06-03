import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:get_storage/get_storage.dart';
import '../../Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  int selectedIndex = 0;
  int mainCarouselIndex = 0;
  int cardsCarouselIndex = 0;
  TextLanguage textLanguage = TextLanguage();
  final box = GetStorage();

  List<Map<String, String>> get events => [
    {"imagePath":'assets/icon/Restaurants.png',"title":textLanguage.GetWord("المطاعم"),"key": "IMAG"},
    {"imagePath":'assets/icon/Cafes.png',"title":textLanguage.GetWord("صالات الاستراحة"),"key": "IMAG"},
    {"imagePath":'assets/icon/Lounges.png',"title":textLanguage.GetWord("المقاهي"),"key": "IMAG"},
    {"imagePath":"assets/icon/OrderToGo.png","title":textLanguage.GetWord("طلب سفري"),"key":"IMAG"},
  ];

  final List<Map<String, dynamic>> home          = [];
  List<Map<String, dynamic>> statuses = [];
  final List<Map<String, dynamic>> event         = [];
  final List<Map<String, dynamic>> favorite      = [];
  final List<Map<String, dynamic>> dish          = [];
  final List<Map<String, dynamic>> topPicks      = [];
  final List<Map<String, dynamic>> closestCheapest = [];
  final List<Map<String, dynamic>> mostOrdered     = [];
  final List<dynamic>              filters          = [];
  final Map<int, bool>             favoriteStatus   = {};

  List<Map<String, dynamic>> offers = [];
  String closestCheapestSortBy = "ratio";

  @override
  int build() => 0;

  int selectedCategoryIndex = 0;

  void changeMainCarousel(int index) { mainCarouselIndex = index; ref.notifyListeners(); }
  void changeCardsCarousel(int index) {
    cardsCarouselIndex = index;

    ref.notifyListeners();
  }

  void toggleLike_favorite(int index) { favorite[index]["liked"] = !(favorite[index]["liked"] as bool); ref.notifyListeners(); }
  void DishofTheDay(int index) { dish[index]["liked"] = !(dish[index]["liked"] as bool); ref.notifyListeners(); }
  void selectCategory(int index) { selectedCategoryIndex = index; ref.notifyListeners(); }

  void select(int index) {
    state = index;
    selectedIndex = index;
    selectedCategoryIndex = 0;
    ref.notifyListeners();
  }

  // ─── مسارات الـ API ────────────────────────────────────────────────────────
  String _getApiPath() {
    switch (selectedIndex) {
      case 0: return "$roles/restaurants";
      case 1: return "$roles/lounges";
      case 2: return "$roles/cafes";
      case 3: return "$roles/order-to-go";
      default: return "$roles/restaurants";
    }
  }

  String _getFilterPath(String filterValue) {
    switch (selectedIndex) {
      case 0: return "$roles/restaurants/filter/$filterValue";
      case 1: return "$roles/lounges/filter/$filterValue";
      case 2: return "$roles/cafes/filter/$filterValue";
      case 3: return "$roles/order-to-go/filter/$filterValue";
      default: return "$roles/restaurants/filter/$filterValue";
    }
  }

  String _getOffersPath() {
    switch (selectedIndex) {
      case 0: return "$roles/restaurants/offers";
      case 1: return "$roles/lounges/offers";
      case 2: return "$roles/cafes/offers";
      case 3: return "$roles/order-to-go/offers";
      default: return "$roles/restaurants/offers";
    }
  }

  String _getDishOfDayPath() {
    switch (selectedIndex) {
      case 0: return "$roles/restaurants/dish-of-the-day";
      case 1: return "$roles/lounges/flavor-of-the-day";
      case 2: return "$roles/cafes/flavor-of-the-day";
      case 3: return "$roles/order-to-go/flavor-of-the-day";
      default: return "$roles/restaurants/dish-of-the-day";
    }
  }

  String getTopPicksKey() {
    switch (selectedIndex) {
      case 0: return "restaurants/";
      case 1: return "lounges/";
      case 2: return "cafes/";
      case 3: return "order-to-go/";
      default: return "restaurants/";
    }
  }

  String _getEventsPath() => "$roles/restaurants/events";

  String _getStatusKey() {
    switch (selectedIndex) {
      case 0: return "restaurants_status";
      case 1: return "lounges_status";
      case 2: return "cafes_status";
      case 3: return "order_to_go_status";
      default: return "restaurants_status";
    }
  }

  String _getTopPicksPath() {
    switch (selectedIndex) {
      case 0: return "$roles/restaurants/top-picks";
      case 1: return "$roles/lounges/top-picks";
      case 2: return "$roles/cafes/top-picks";
      case 3: return "$roles/order-to-go/closest-cheapest";
      default: return "$roles/restaurants/top-picks";
    }
  }

  String getStatusKey() => _getStatusKey();

  List<dynamic> get displayItems => filters.isNotEmpty ? filters : topPicks;
  final List<String> categorySlug = [
    "restaurants",
    "lounges",
    "cafes",
    "order-to-go"
  ];
  Future<void> restaurants(BuildContext context, {bool showLoader = true}) async {
    final results = await Future.wait([
      ApiService().get("v1/${_getApiPath()}", {}, context),
      ApiService().get(
        "v1/$roles/statuses",
        {
          "category_slug": categorySlug[selectedIndex],
          "per_page": "4",
        },
        context,
      ),
      ApiService().get(
        "v1/${_getOffersPath()}",
        {"per_page": "4"},
        context,
      ),
      ApiService().get(
        "v1/${_getTopPicksPath()}",
        {"per_page": "4"},
        context,
      ),
      ApiService().get(
        "v1/$roles/favorites",
        {},
        context,
      ),
      ApiService().get(
        "v1/${_getDishOfDayPath()}",
        {"per_page": "4"},
        context,
      ),
      if (selectedIndex == 0)
        ApiService().get("v1/${_getEventsPath()}", {"per_page": "4"}, context)
      else
        Future.value(null),
    ]);

    final homeResponse   = results[0];
    final statusResponse = results[1];
    final offersResponse = results[2];
    final topResponse    = results[3];
    final favResponse    = results[4];
    final dishResponse   = results[5];
    final eventResponse = results[6];
    // ─── تنظيف البيانات ───
    home.clear();
    statuses.clear();
    offers.clear();
    topPicks.clear();
    favorite.clear();
    dish.clear();
    event.clear();

    if (selectedIndex == 0 && eventResponse?['data']?['items'] is List) {
      for (var item in eventResponse['data']['items']) {
        if (item is Map<String, dynamic>) event.add(item);
      }
    }
    // ─── Home ───
    if (homeResponse?['data'] != null) {
      final data = homeResponse['data'];
      if (data is Map<String, dynamic>) {
        home.add(data);
      }
    }


    // ─── Status ───
    final statusItems = statusResponse?['data'];
    if (statusItems is List) statuses = List<Map<String, dynamic>>.from(statusItems);


    // ─── Offers ───
    final offerItems = offersResponse?['data']?['items'];
    if (offerItems is List) {
      offers = List<Map<String, dynamic>>.from(offerItems);
    }
    // ─── Top Picks ───
    final topItems = topResponse?['data']?['items'];
    if (topItems is List) {
      for (var item in topItems) {
        if (item is Map) {
          topPicks.add(Map<String, dynamic>.from(item));
        }
      }
    }
    // ─── Favorites ───
    favoriteStatus.clear();
    if (favResponse?['success'] == true &&
        favResponse?['data']?['items'] is List) {
      for (var item in favResponse['data']['items']) {
        favorite.add({...item, "liked": true});

        final id = int.tryParse(item["item_id"]?.toString() ?? "0") ?? 0;
        if (id != 0) favoriteStatus[id] = true;
      }
    }
    // ─── Dish of the Day ───
    final dishItems = dishResponse?['data']?['items'];
    if (dishItems is List) {
      dish.clear();

      for (var item in dishItems) {
        if (item is Map) {
          final id = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;

          dish.add({
            ...Map<String, dynamic>.from(item),
            "liked": favoriteStatus[id] ?? false,
          });
        }
      }
    }

    ref.notifyListeners();
  }

  /*
  Future<void> restaurants(BuildContext context,{bool showLoader = true}) async {
    home.clear();
    statuses.clear();
    event.clear();
    favorite.clear();
    dish.clear();
    topPicks.clear();
    offers.clear();
    closestCheapest.clear();
    mostOrdered.clear();
    cardsCarouselIndex = 0;
    mainCarouselIndex = 0;
    // ─── Home Data ────────────────────────────────────────────────────────
    final homeResponse = await ApiService().get("v1/${_getApiPath()}", {}, context);
    if (homeResponse != null && homeResponse['data'] != null) {
      final data = homeResponse['data'];
      if (data is Map<String, dynamic>) home.add(data);
    }
    // ─── Status ───────────────────────────────────────────────────────────
     List category_slug = ["restaurants","lounges","cafes","order-to-go"];
     final statusResponse = await ApiService().get(
        "v1/$roles/statuses",
        {
          "category_slug": category_slug[selectedIndex],
          "per_page": "4",
        },
        context,
    );
    final statusItems = statusResponse?['data'];
    if (statusItems is List) statuses = List<Map<String, dynamic>>.from(statusItems);
    // ─── Offers ───────────────────────────────────────────────────────────
    final offersResponse = await ApiService().get(
      "v1/${_getOffersPath()}", {"per_page": "4"}, context,
    );
    final offerItems = offersResponse?['data']?['items'];
    if (offerItems is List) offers = List<Map<String, dynamic>>.from(offerItems);

    // ─── Top Picks / Closest Cheapest ─────────────────────────────────────
    final topResponse = await ApiService().get(
      "v1/${_getTopPicksPath()}", {"per_page": "4"}, context,
    );
    if (topResponse != null && topResponse['data']?['items'] is List) {
      final List sourceList = topResponse['data']['items'];
      for (var item in sourceList) {
        if (item is Map) topPicks.add(Map<String, dynamic>.from(item));
      }
    }

    // ─── Favorites ────────────────────────────────────────────────────────
    final favResponse = await ApiService().get("v1/$roles/favorites", {}, context);
    if (favResponse != null && favResponse['success'] == true) {
      favoriteStatus.clear();
      final dataContainer = favResponse['data'];
      if (dataContainer != null && dataContainer['items'] is List) {
        for (var item in dataContainer['items']) {
          if (item is Map<String, dynamic>) {
            favorite.add({...item, "liked": true});
            final int itemId = int.tryParse(item["item_id"]?.toString() ?? "0") ?? 0;
            if (itemId != 0) favoriteStatus[itemId] = true;
          }
        }
      }
    }

    // ─── Dish of the Day ──────────────────────────────────────────────────
    final dishResponse = await ApiService().get(
      "v1/${_getDishOfDayPath()}", {"per_page": "4"}, context,
    );
    if (dishResponse != null && dishResponse['data'] != null) {
      final data = dishResponse['data'];
      final List sourceList = (data['items'] is List) ? data['items'] : [];
      for (var item in sourceList) {
        if (item is Map) {
          final int itemId = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;
          dish.add({...Map<String, dynamic>.from(item), "liked": favoriteStatus[itemId] ?? false});
        }
      }
    }

    // ─── Events (مطاعم فقط) ───────────────────────────────────────────────
    if (selectedIndex == 0) {
      final eventResponse = await ApiService().get(
        "v1/${_getEventsPath()}?per_page=4", {}, context,
      );
      if (eventResponse != null && eventResponse['data']?['items'] is List) {
        for (var item in eventResponse['data']['items']) {
          if (item is Map<String, dynamic>) event.add(item);
        }
      }
    }

    // ─── Order to Go أقسام إضافية ─────────────────────────────────────────
    if (selectedIndex == 3) {
      // Closest Cheapest
      final ccResponse = await ApiService().get(
        "v1/$roles/order-to-go/closest-cheapest",
        {"per_page": "4", "sort_by": closestCheapestSortBy, "lat": "24.7136", "lng": "46.6753"},
        context,
      );
      if (ccResponse != null && ccResponse['data']?['items'] is List) {
        for (var item in ccResponse['data']['items']) {
          if (item is Map) closestCheapest.add(Map<String, dynamic>.from(item));
        }
      }

      // Most Ordered
      final moResponse = await ApiService().get(
        "v1/$roles/order-to-go/most-ordered", {"per_page": "4"}, context,
      );
      if (moResponse != null && moResponse['data']?['items'] is List) {
        for (var item in moResponse['data']['items']) {
          if (item is Map) mostOrdered.add(Map<String, dynamic>.from(item));
        }
      }
    }

    // ─── Favorite Status ──────────────────────────────────────────────────
    for (var item in getTopPickItems(home)) {
      final int itemId = item["id"] ?? 0;
      checkFavoriteStatus(itemId, context);
    }

    ref.notifyListeners();

  }
  */
  // ─── 2️⃣ دالة الفلترة ──────────────────────────────────────────────────────
  Future<void> filter(BuildContext context, {String filter = "all"}) async {
    final String safeFilter = filter.trim().isEmpty
        ? "all"
        : filter.trim().toLowerCase().replaceAll(" ", "_");

    filters.clear();

    final response = await ApiService().get(
      "v1/${_getFilterPath(safeFilter)}", {"per_page": "20"}, context,
    );
    if (response != null && response['data']?['items'] is List) {
      for (var item in response['data']['items']) {
        if (item is Map) filters.add(Map<String, dynamic>.from(item));
      }
    }

    cardsCarouselIndex = 0;
    mainCarouselIndex = 0;
    ref.notifyListeners();
  }



  // ─── تغيير Sort في Closest & Cheapest ────────────────────────────────────
  void changeClosestCheapestSort(BuildContext context, String sortBy) async {
    closestCheapestSortBy = sortBy;
    closestCheapest.clear();
    final lat = box.read("user")["latitude"];
    final lng = box.read("user")["longitude"];
    if (lat == null || lng == null) return;
    final response = await ApiService().get(
      "v1/$roles/order-to-go/closest-cheapest",
      {"per_page": "4", "sort_by": sortBy, "lat":lat, "lng":lng},
      context,
    );
    if (response != null && response['data']?['items'] is List) {
      for (var item in response['data']['items']) {
        if (item is Map) closestCheapest.add(Map<String, dynamic>.from(item));
      }
    }
    ref.notifyListeners();
  }

  // ─── Toggle Favorite ──────────────────────────────────────────────────────
  void toggleLike(int itemId, int index, BuildContext context, {String type = "branch"}) async {
    final bool isCurrentlyFavorited = favoriteStatus[itemId] ?? false;
    final bool willBeFavorited = !isCurrentlyFavorited;

    favoriteStatus[itemId] = willBeFavorited;

    if (willBeFavorited) {
      Map<String, dynamic> itemData = {};

      if (type == "menu_item") {
        final dishItem = dish.firstWhere(
              (element) {
            final id = element["item"]?["id"] ?? element["id"] ?? element["branch_id"];
            return int.tryParse(id?.toString() ?? "") == itemId;
          },
          orElse: () => {},
        );
        if (dishItem.isNotEmpty) itemData = dishItem;
      } else {
       // final allItems = [...getTopPickItems(home), ...closestCheapest, ...mostOrdered];
        final allItems = [...getTopPickItems(home), ...topPicks, ...closestCheapest, ...mostOrdered];
        itemData = allItems.firstWhere(
              (element) {
            final id = element["id"] is int ? element["id"] : int.tryParse(element["id"]?.toString() ?? "");
            return id == itemId;
          },
          orElse: () => {},
        );
      }

      if (itemData.isNotEmpty) {
        /*
        final String name = type == "menu_item"
            ? (itemData["name"] ?? itemData["title"] ?? "").toString()
            : (itemData["business_name"] ?? itemData["name"] ?? "").toString();
        final String image = (itemData["image"] ?? itemData["image_url"] ?? "").toString();

         */
        favorite.insert(0, {
          ...itemData,
          "item_id": itemId,
          "type": type,
          "liked": true,
          "item": {
            "id": itemId,
            "business_name": itemData["business_name"] ?? itemData["name"] ?? itemData["title"] ?? "",
            "image": fixImage(itemData["image"] ?? itemData["image_url"]),
          },
          "distance_km": itemData["distance_km"],
          "eta_minutes": itemData["eta_minutes"],
          "min_price": itemData["min_price"],
        });
        print(favorite);
      }
    } else {
      favorite.removeWhere((element) {
        final id = element["item"]?["id"]?.toString() ?? element["id"]?.toString() ?? "";
        return id == itemId.toString();
      });
    }

    ref.notifyListeners();

    final response = await _toggleWithFallback(itemId, type, context);

    if (response != null && response['success'] == true) {
      final bool serverStatus = response['data']?['is_favorited'] == true;
      if (serverStatus != willBeFavorited) {
        favoriteStatus[itemId] = serverStatus;
        if (!serverStatus) {
          favorite.removeWhere((element) {
            final id = element["item"]?["id"]?.toString() ?? element["id"]?.toString() ?? "";
            return id == itemId.toString();
          });
        }
        ref.notifyListeners();
      }
    } else {
      favoriteStatus[itemId] = isCurrentlyFavorited;
      favorite.removeWhere((element) {
        final id = element["item"]?["id"]?.toString() ?? element["id"]?.toString() ?? "";
        return id == itemId.toString();
      });
      ref.notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _toggleWithFallback(int itemId, String type, BuildContext context) async {
    final response = await ApiService().post(
      "v1/$roles/favorites/toggle", {"item_id": itemId, "type": type}, context,
    );
    print(response);
    if (response != null && response['success'] == true) return response;

    final fallbackType = type == "branch" ? "menu_item" : "branch";
    return await ApiService().post(
      "v1/$roles/favorites/toggle", {"item_id": itemId, "type": fallbackType}, context,
    );
  }

  // ─── Favorite Status ──────────────────────────────────────────────────────
  void checkFavoriteStatus(int itemId, BuildContext context) async {
    final response = await ApiService().get(
      "v1/$roles/favorites/check",
      {"item_id": itemId.toString(), "type": "branch"},
      context,
    );
    if (response != null && response['success'] == true && response['data'] != null) {
      favoriteStatus[itemId] = response['data']['is_favorited'] == true;
      ref.notifyListeners();
    }
  }

  List<Map<String, dynamic>> getTopPickItems(List homes) {
    try {
      if (homes.isEmpty) return [];
      final sections = homes[0]["sections"];
      if (sections == null) return [];
      final topPicks = sections["top_picks"];
      if (topPicks == null) return [];
      final rawItems = topPicks["items"];
      if (rawItems is! List) return [];
      return rawItems.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
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
        // items مباشرة (event items)
        final items = menu["items"] as List? ?? [];
        for (var item in items) {
          allMeals.add({...item, "menu_name": menu["name"]});
        }

        // sections → items
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

  bool showLanguage = false;

  void toggleLanguage() {
    showLanguage = !showLanguage;
    ref.notifyListeners();
  }
}

String fixImage(String? url) {
  if (url == null || url.isEmpty) return "";

  return url.replaceFirst(
    "https://api.rafatstay.com/uploads/https://api.rafatstay.com/uploads/",
    "https://api.rafatstay.com/uploads/",
  );
}
final Home_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
