import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

// ==============================
// 1️⃣ أنواع الصفحات المتاحة
// ==============================
enum RestaurantSection {
  offers,
  status,
  favorites,
  topPicks,
  events,
  dishOfTheDay,
  closestCheapest,
  mostOrdered,
}

// ==============================
// 2️⃣ أنواع الفلاتر المتاحة
// ==============================
enum RestaurantFilter {
  all,
  openBuffet,
  cuisines,
  fineDine,
  casualDining,
}

// ==============================
// 3️⃣ Extension للتحويل إلى String
// ==============================
extension RestaurantFilterPath on RestaurantFilter {
  String get path {
    switch (this) {
      case RestaurantFilter.all:
        return "all";
      case RestaurantFilter.openBuffet:
        return "open_buffet";
      case RestaurantFilter.cuisines:
        return "cuisines";
      case RestaurantFilter.fineDine:
        return "fine_dine";
      case RestaurantFilter.casualDining:
        return "casual_dining";
    }
  }

  String get displayName {
    switch (this) {
      case RestaurantFilter.all:
        return "All";
      case RestaurantFilter.openBuffet:
        return "Open Buffet";
      case RestaurantFilter.cuisines:
        return "Cuisines";
      case RestaurantFilter.fineDine:
        return "Fine Dining";
      case RestaurantFilter.casualDining:
        return "Casual Dining";
    }
  }
}

class PageNotifier extends Notifier<int> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchNode = FocusNode();

  RestaurantSection currentSection = RestaurantSection.offers;
  RestaurantFilter currentFilter = RestaurantFilter.all;

  // قوائم البيانات العادية
  List<Map<String, dynamic>> offers = [];
  List<Map<String, dynamic>> status = [];
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> topPicks = [];
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> dishOfDay = [];
  List<Map<String, dynamic>> closestCheapest = [];
  List<Map<String, dynamic>> mostOrdered = [];
  List<Map<String, dynamic>> filtersList = [];
  int selectedFilterIndex = 0;
  // قائمة منفصلة لنتائج البحث
  List<Map<String, dynamic>> searchResults = [];

  Map<int, bool> favoriteStatus = {};

  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMore = true;

  // متغيرات للبحث
  bool isSearching = false;
  bool hasMoreSearch = true;
  int searchPage = 1;

  int currentPage = 1;
  static const int _perPage = 10;

  @override
  int build() => 0;


  void selectFilter(BuildContext context, int index, String sectionKey, Map<String, dynamic> selectedFilter) {
    selectedFilterIndex = index;
    currentPage = 1;
    hasMore = true;
    state++;

    // نستخدم selectedFilter الممرر مباشرة بدلاً من filtersList[index]
    String filterValue = selectedFilter["key"]?.toString() ??
        selectedFilter["label_en"]?.toString() ??
        "all";

    filterValue = filterValue.trim().toLowerCase().replaceAll(" ", "_");

    if (index == 0) {
      fetchSection(context, section: currentSection, key: sectionKey);
    } else {
      final filterEndpoint = _buildFilterEndpoint(sectionKey, filterValue);
      fetchSectionWithEndpoint(context, endpoint: filterEndpoint);
    }
  }

  String _buildFilterEndpoint(String sectionKey, String filterKey) {
    // sectionKey مثلاً: "restaurants/"
    // النتيجة: v1/guest/restaurants/filter/open_buffet
    final cleanKey = sectionKey.endsWith('/')
        ? sectionKey.substring(0, sectionKey.length - 1)
        : sectionKey;
    return "v1/$roles/$cleanKey/filter/$filterKey";
  }

  Future<void> fetchSectionWithEndpoint(
      BuildContext context, {
        required String endpoint,
      }) async {
    if (!ref.mounted) return;
    currentPage = 1;
    hasMore = true;
    isLoading = true;
    _clearSection(currentSection);
    resetSearch();
    state++;

    final response = await ApiService().get(
      endpoint,
      {"per_page": "$_perPage", "page": "$currentPage"},
      context,
    );

    if (!ref.mounted) return;
    if (response != null && response['data'] != null) {
      final data = response['data'];
      final items = data['items'];
      final list = items is List
          ? List<Map<String, dynamic>>.from(items)
          : <Map<String, dynamic>>[];

      final pagination = data['pagination'];
      if (pagination != null) {
        hasMore = currentPage < (pagination['last_page'] ?? 1);
      } else {
        hasMore = list.length >= _perPage;
      }

      _appendToSection(currentSection, list, false);
      currentPage++;
    } else {
      hasMore = false;
    }

    isLoading = false;
    isFetchingMore = false;
    if (!ref.mounted) return;
    state++;
  }

  // ==================== دالة البحث الجديدة ====================
  Future<void> search(
      BuildContext context, {
        bool loadMore = false,
      }) async {
    if (!ref.mounted) return;

    if (loadMore) {
      if (!hasMoreSearch || isFetchingMore) return;
      isFetchingMore = true;
    } else {
      searchPage = 1;
      hasMoreSearch = true;
      isLoading = true;
      isSearching = true;
      searchResults.clear();
      _clearSection(currentSection);
    }

    if (!ref.mounted) return;
    state++;

    final endpoint = "v1/$roles/search";
    final response = await ApiService().get(
      endpoint,
      {
        "per_page": "$_perPage",
        "page": "$searchPage",
        "query": searchController.text.trim(),
      },
      context,
    );

    if (!ref.mounted) return;

    if (response != null && response['data'] != null) {
      final data = response['data'];

      // ✅ قراءة عناصر القائمة من data['menu_items']['items']
      //  final menuItems = data['menu_items'];

      // ✅ قراءة pagination من data['menu_items']['pagination']
      final branches = data['branches'];
      final items = branches != null ? branches['items'] : [];
      final list = items is List
          ? List<Map<String, dynamic>>.from(items)
          : <Map<String, dynamic>>[];

      final pagination = branches != null ? branches['pagination'] : null;
      if (pagination != null) {
        final int lastPage = pagination['last_page'] ?? 1;
        hasMoreSearch = searchPage < lastPage;
      } else {
        hasMoreSearch = list.length >= _perPage;
      }

      if (loadMore) {
        searchResults.addAll(list);
      } else {
        searchResults = list;
      }

      searchPage++;
    } else {
      hasMoreSearch = false;
      if (!loadMore) {
        searchResults.clear();
      }
    }
    for (final item in searchResults) {
      final id = item['id'];
      print(id);
    }
    isLoading = false;
    isFetchingMore = false;

    if (!ref.mounted) return;
    state++;
  }

  // ==================== إعادة تعيين حالة البحث ====================
  void resetSearch() {
    isSearching = false;
    searchResults.clear();
    searchController.clear();
    searchPage = 1;
    hasMoreSearch = true;
    currentPage = 1;
    hasMore = true;
    state++;
  }

  void resetAll() {
    resetSearch(); // يصفر البحث والصفحات
    selectedFilterIndex = 0; // يصفر الفلتر المختار
    currentFilter = RestaurantFilter.all;
    state++;
  }
  // ==================== جلب القسم العادي ====================
  Future<void> fetchSection(
      BuildContext context, {
        required RestaurantSection section,
        RestaurantFilter filter = RestaurantFilter.all,
        String? key,
        bool loadMore = false,
      }) async {
    if (!ref.mounted) return;

    if (isSearching && !loadMore) return;

    if (loadMore) {
      if (!hasMore || isFetchingMore) return;
      isFetchingMore = true;
    } else {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      _clearSection(section);
      resetSearch();
    }

    currentSection = section;
    currentFilter = filter;

    if (!ref.mounted) return;
    state++;

    final endpoint = _buildEndpoint(section, key ?? "", filter);

    final Map<String, String> params = {
      "per_page": "$_perPage",
      "page": "$currentPage",
    };

    if (section == RestaurantSection.status) {
      params["category_slug"] = (key ?? "").replaceAll("/", "");
    }

    final response = await ApiService().get(endpoint, params, context);

    if (!ref.mounted) return;
    if (response != null && response['data'] != null) {
      final data = response['data'];

      final rawItems = section == RestaurantSection.status ? data : data['items'];
      final list = rawItems is List
          ? List<Map<String, dynamic>>.from(rawItems)
          : <Map<String, dynamic>>[];

      final pagination = section == RestaurantSection.status ? null : data['pagination'];
      if (pagination != null) {
        final int lastPage = pagination['last_page'] ?? 1;
        hasMore = currentPage < lastPage;
      } else {
        hasMore = list.length >= _perPage;
      }

      _appendToSection(section, list, loadMore);

      if (section == RestaurantSection.favorites) {
        for (final favorite in list) {
          final item = favorite['item'];
          final id = int.tryParse(item?['id']?.toString() ?? "0") ?? 0;
          final type = favorite['type'] ?? 'menu_item';
          if (id != 0) checkFavoriteStatus(id, context, type: type);
        }
      } else if (section != RestaurantSection.events &&
          section != RestaurantSection.status &&
          section != RestaurantSection.offers) {
        final itemType = _getItemType(section);
        for (final item in list) {
          final id = int.tryParse(item['id']?.toString() ?? "0") ?? 0;
          if (id != 0) checkFavoriteStatus(id, context, type: itemType);
        }
      }

      currentPage++;
    } else {
      hasMore = false;
    }

    isLoading = false;
    isFetchingMore = false;

    if (!ref.mounted) return;
    state++;
  }


  // ==================== فحص حالة المفضلة ====================
  Future<void> checkFavoriteStatus(int itemId, BuildContext context,{String type="branch"}) async {

    final response = await ApiService().get(
      "v1/$roles/favorites/check",
      {"item_id": itemId.toString(), "type": type},
      context,
    );

    if (response != null && response['success'] == true && response['data'] != null) {
      favoriteStatus[itemId] = response['data']['is_favorited'] == true;
      state++;
    }
    //  print(response['data']);
  }

  // ==================== تبديل حالة المفضلة ====================
  Future<void> toggleFavorite(int itemId, BuildContext context, String type) async {
    final response = await ApiService().post(
      "v1/$roles/favorites/toggle",
      {"item_id": itemId.toString(), "type":type},
      context,
    );

    if (response != null && response['success'] == true) {
      // عكس الحالة الحالية
      favoriteStatus[itemId] = !(favoriteStatus[itemId] ?? false);
      state++; // لتحديث الـ UI
    }
  }
  // ==================== دوال مساعدة ====================

  /// إرجاع القائمة الحالية (إما البحث أو القسم الحالي)
  List<Map<String, dynamic>> getCurrentList() {
    if (isSearching) {
      return searchResults;
    }

    switch (currentSection) {
      case RestaurantSection.offers:
        return offers;
      case RestaurantSection.status:
        return status;
      case RestaurantSection.favorites:
        return favorites;
      case RestaurantSection.topPicks:
        return topPicks;
      case RestaurantSection.events:
        return events;
      case RestaurantSection.dishOfTheDay:
        return dishOfDay;
      case RestaurantSection.closestCheapest:
        return closestCheapest;
      case RestaurantSection.mostOrdered:
        return mostOrdered;
    }
  }

  /// هل هناك المزيد من البيانات للتحميل؟
  bool getCurrentHasMore() {
    if (isSearching) {
      return hasMoreSearch;
    }
    return hasMore;
  }

  /// تحميل المزيد حسب الحالة (بحث أو عادي)
  Future<void> loadMoreCurrent(BuildContext context, String roles) async {
    if (isSearching) {
      await search(
        context,
        loadMore: true,
      );
    } else {
      await fetchSection(
        context,
        section: currentSection,
        filter: currentFilter,
        key: roles, // نفترض أن roles هو الـ key
        loadMore: true,
      );
    }
  }

  void _clearSection(RestaurantSection section) {
    switch (section) {
      case RestaurantSection.offers:
        offers.clear();
        break;
      case RestaurantSection.status:
        status.clear();
        break;
      case RestaurantSection.favorites:
        favorites.clear();
        break;
      case RestaurantSection.topPicks:
        topPicks.clear();
        break;
      case RestaurantSection.events:
        events.clear();
        break;
      case RestaurantSection.dishOfTheDay:
        dishOfDay.clear();
        break;
      case RestaurantSection.closestCheapest:
        closestCheapest.clear();
        break;
      case RestaurantSection.mostOrdered:
        mostOrdered.clear();

        break;
    }
  }

  void _appendToSection(
      RestaurantSection section,
      List<Map<String, dynamic>> list,
      bool loadMore,
      ) {
    switch (section) {
      case RestaurantSection.offers:
        loadMore ? offers.addAll(list) : offers = list;
        break;
      case RestaurantSection.status:
        loadMore ? status.addAll(list) : status = list;
        break;
      case RestaurantSection.favorites:
        loadMore ? favorites.addAll(list) : favorites = list;
        break;
      case RestaurantSection.topPicks:
        loadMore ? topPicks.addAll(list) : topPicks = list;
        break;
      case RestaurantSection.events:
        loadMore ? events.addAll(list) : events = list;
        break;
      case RestaurantSection.dishOfTheDay:
        loadMore ? dishOfDay.addAll(list) : dishOfDay = list;
        break;
      case RestaurantSection.closestCheapest:
        closestCheapest = list;
        break;
      case RestaurantSection.mostOrdered:
        mostOrdered = list;
        break;
    }
  }

  String _buildEndpoint(
      RestaurantSection section,
      String key,
      RestaurantFilter filter,
      ) {
    final base = "$roles/$key";
    switch (section) {
      case RestaurantSection.offers:
        return "v1/${base}offers";
      case RestaurantSection.status:
        return "v1/$roles/statuses";
      case RestaurantSection.favorites:
        return "v1/$roles/favorites";
      case RestaurantSection.topPicks:
        return "v1/${base}top-picks";
      case RestaurantSection.events:
        return "v1/${base}events";
      case RestaurantSection.dishOfTheDay:
        return "v1/${base}${_getDishOfDaySuffix(key)}";
      case RestaurantSection.closestCheapest:
        return "v1/${base}closest-cheapest";
      case RestaurantSection.mostOrdered:
        return "v1/${base}most-ordered";
    }
  }

  String _getItemType(RestaurantSection section) {
    switch (section) {
      case RestaurantSection.topPicks:
        return "branch";
      case RestaurantSection.dishOfTheDay:
        return "menu_item";
      case RestaurantSection.favorites:
        return "menu_item";
      default:
        return "branch";
    }
  }

  String _getDishOfDaySuffix(String key) {
    if (key.contains('lounges') || key.contains('cafes') || key.contains('order-to-go')) {
      return 'flavor-of-the-day';
    }
    return 'dish-of-the-day';
  }
}

final SeeAll_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);