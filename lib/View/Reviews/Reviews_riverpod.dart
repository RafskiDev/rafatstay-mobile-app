import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  List<Map<String, dynamic>> reviews = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  int build() {
    return 0;
  }

  Future<void> fetchReviews(
      BuildContext context,
      int branchId, {
        bool loadMore = false,
      }) async {

    if (isLoadingMore) return;

    if (loadMore) {
      if (!hasMore) return;
      isLoadingMore = true;
      currentPage++;
    } else {
      currentPage = 1;
      hasMore = true;
      reviews.clear();
      if (ref.mounted) state++;
    }
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId/reviews",
      {
       // "sort_by": "helpful_count",
       // "sort_dir": "desc",
        "per_page": "5",
        "page": currentPage.toString(),
      },
      context,
    );
    if (!ref.mounted) return;
    if (response != null && response['data'] != null) {
      final data = response['data'];
      final List items = (data['data'] is List) ? data['data'] : [];

      if (loadMore) {
        reviews.addAll(List<Map<String, dynamic>>.from(items));
      } else {
        reviews = List<Map<String, dynamic>>.from(items);
      }

      final lastPage = data['last_page'] ?? 1;
      hasMore = currentPage < lastPage;
    }

    isLoadingMore = false;

    if (ref.mounted) state++;
  }

  void reset() {
    reviews.clear();
    currentPage = 1;
    hasMore = true;
    isLoadingMore = false;
    state++;
  }
}

final Reviews_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);