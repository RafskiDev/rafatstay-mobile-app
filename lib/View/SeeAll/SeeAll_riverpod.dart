import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

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

enum RestaurantFilter {
  all,
  openBuffet,
  cuisines,
  fineDine,
  casualDining,
}

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

  List<Map<String, dynamic>> searchResults = [];
  Map<int, bool> favoriteStatus = {};

  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMore = true;

  bool isSearching = false;
  bool hasMoreSearch = true;
  int searchPage = 1;

  int currentPage = 1;
  static const int _perPage = 10;

  // ✅ نحفظ الـ sectionKey الحالي
  String _currentSectionKey = "";

  @override
  int build() => 0;

  void _resetSearchSilent() {
    isSearching = false;
    searchResults.clear();
    searchController.clear();
    searchPage = 1;
    hasMoreSearch = true;
  }

  void selectFilter(
      BuildContext context,
      int index,
      String sectionKey,
      Map<String, dynamic> selectedFilter,
      ) {
    selectedFilterIndex = index;
    state++;

    if (index == 0) {
      // ✅ All - يجيب الكل بـ tab=all
      fetchSection(
        context,
        section: currentSection,
        key: sectionKey,
        filter: RestaurantFilter.all,
      );
    } else {
      // ✅ فلتر محدد - يروح لـ endpoint الفلترة
      String filterValue = selectedFilter["key"]?.toString() ??
          selectedFilter["label_en"]?.toString() ??
          "all";

      filterValue = filterValue
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[\s\-]+'), '_');

      final filterEndpoint = _buildFilterEndpoint(sectionKey, filterValue);
      fetchSectionWithEndpoint(context, endpoint: filterEndpoint);
    }
  }

  String _buildFilterEndpoint(String sectionKey, String filterKey) {
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

    isLoading = true;
    isSearching = false;
    currentPage = 1;
    hasMore = false;
    isFetchingMore = false;
    searchResults.clear();
    _clearSection(currentSection);
    state++;

    final response = await ApiService().get(
      endpoint,
      {"per_page": "$_perPage"},
      context,
    );
    if (!ref.mounted) return;

    if (response != null && response['data'] != null) {
      final data = response['data'];
      final items = data['items'];
      final list = items is List
          ? List<Map<String, dynamic>>.from(items)
          : <Map<String, dynamic>>[];

      _appendToSection(currentSection, list, false);
    }

    hasMore = false;
    isLoading = false;
    isFetchingMore = false;
    if (!ref.mounted) return;
    state++;
  }

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
      final branches = data['branches'];
      final items = branches != null ? branches['items'] : [];
      final list = items is List
          ? List<Map<String, dynamic>>.from(items)
          : <Map<String, dynamic>>[];

      final pagination = branches != null ? branches['pagination'] : null;
      if (pagination != null) {
        final int lastPage =
            int.tryParse(pagination['last_page']?.toString() ?? "1") ?? 1;
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
      if (!loadMore) searchResults.clear();
    }

    isLoading = false;
    isFetchingMore = false;
    if (!ref.mounted) return;
    state++;
  }

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
    _resetSearchSilent();
    selectedFilterIndex = 0;
    currentFilter = RestaurantFilter.all;
    currentPage = 1;
    hasMore = true;
    state++;
  }

  Future<void> fetchSection(
      BuildContext context, {
        required RestaurantSection section,
        RestaurantFilter filter = RestaurantFilter.all,
        String? key,
        bool loadMore = false,
      }) async {
    if (!ref.mounted) return;

    if (loadMore) {
      if (!hasMore || isFetchingMore) return;
      isFetchingMore = true;
    } else {
      isSearching = false;
      searchResults.clear();
      searchPage = 1;
      hasMoreSearch = true;
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      _clearSection(section);
    }

    currentSection = section;
    currentFilter = filter;
    _currentSectionKey = key ?? "";

    if (!ref.mounted) return;
    state++;

    final endpoint = _buildEndpoint(section, key ?? "", filter);

    final Map<String, String> params = {
      "per_page": "$_perPage",
      "page": "$currentPage",
     // "tab": filter.path,
    };

    if (section == RestaurantSection.status) {
      params["category_slug"] = (key ?? "").replaceAll("/", "");
      params.remove("tab");
    }

    final response = await ApiService().get(endpoint, params, context);

    if (!ref.mounted) return;

    if (response != null && response['data'] != null) {
      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        hasMore = false;
        isLoading = false;
        isFetchingMore = false;
        if (!ref.mounted) return;
        state++;
        return;
      }

      // ✅ قراءة الفلاتر من data['filters'] مباشرة
      if (!loadMore && data['filters'] is List) {
        final apiFilters = List<Map<String, dynamic>>.from(
            (data['filters'] as List).whereType<Map>());

        final hasAll = apiFilters.any(
                (f) => (f['key'] ?? '').toString().toLowerCase() == 'all');

        filtersList = hasAll
            ? apiFilters
            : [
          {"key": "all", "label_en": "All", "label": "الكل"},
          ...apiFilters,
        ];
      }

      final rawItems =
      section == RestaurantSection.status ? data : data['items'];

      final list = rawItems is List
          ? List<Map<String, dynamic>>.from(rawItems.whereType<Map>())
          : <Map<String, dynamic>>[];

      final pagination =
      section == RestaurantSection.status ? null : data['pagination'];

      if (pagination is Map) {
        final int lastPage =
            int.tryParse(pagination['last_page']?.toString() ?? "1") ?? 1;
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

  Future<void> checkFavoriteStatus(
      int itemId,
      BuildContext context, {
        String type = "branch",
      }) async {
    final response = await ApiService().get(
      "v1/$roles/favorites/check",
      {"item_id": itemId.toString(), "type": type},
      context,
    );

    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {
      favoriteStatus[itemId] = response['data']['is_favorited'] == true;
      state++;
    }
  }

  Future<void> toggleFavorite(
      int itemId,
      BuildContext context,
      String type,
      ) async {
    final response = await ApiService().post(
      "v1/$roles/favorites/toggle",
      {"item_id": itemId.toString(), "type": type},
      context,
    );

    if (response != null && response['success'] == true) {
      favoriteStatus[itemId] = !(favoriteStatus[itemId] ?? false);
      state++;
    }
  }

  List<Map<String, dynamic>> getCurrentList() {
    if (isSearching) return searchResults;

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

  bool getCurrentHasMore() {
    if (isSearching) return hasMoreSearch;
    return hasMore;
  }

  Future<void> loadMoreCurrent(BuildContext context, String key) async {
    if (isSearching) {
      await search(context, loadMore: true);
    } else {
      await fetchSection(
        context,
        section: currentSection,
        filter: currentFilter,
        key: key,
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
    if (key.contains('lounges') ||
        key.contains('cafes') ||
        key.contains('order-to-go')) {
      return 'flavor-of-the-day';
    }
    return 'dish-of-the-day';
  }
}

final SeeAll_riverpod =
NotifierProvider<PageNotifier, int>(PageNotifier.new);