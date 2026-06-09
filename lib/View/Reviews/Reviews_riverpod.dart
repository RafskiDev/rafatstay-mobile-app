import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';

// 1. كلاس يمثل حالة الصفحة بالكامل لضمان تحديث مستقر للواجهة
class ReviewsState {
  final List<Map<String, dynamic>> reviews;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isLoadingFirstTime;

  ReviewsState({
    required this.reviews,
    required this.currentPage,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isLoadingFirstTime,
  });

  ReviewsState copyWith({
    List<Map<String, dynamic>>? reviews,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isLoadingFirstTime,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingFirstTime: isLoadingFirstTime ?? this.isLoadingFirstTime,
    );
  }
}

class PageNotifier extends Notifier<ReviewsState> {
  @override
  ReviewsState build() {
    // الحالة الابتدائية
    return ReviewsState(
      reviews: [],
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
      isLoadingFirstTime: false,
    );
  }

  Future<void> fetchReviews(
      BuildContext context,
      int branchId, {
        bool loadMore = false,
      }) async {
    // منع تكرار الطلب إذا كان النظام يقوم بالتحميل بالفعل
    if (state.isLoadingMore || (loadMore && !state.hasMore)) return;

    if (loadMore) {
      // نضع حالة "جلب المزيد" قبل أي إجراء آخر لتفادي تكرار الدخول هنا من السكرول
      state = state.copyWith(isLoadingMore: true);
    } else {
      // تحميل لأول مرة أو عمل Refresh
      state = state.copyWith(
        isLoadingFirstTime: state.reviews.isEmpty, // إظهار لودنج رئيسي لو القائمة فارغة
        currentPage: 1,
        hasMore: true,
      );
    }

    final int nextPage = loadMore ? state.currentPage + 1 : 1;

    try {
      final response = await ApiService().get(
        "v1/$roles/branches/$branchId/reviews",
        {
          "per_page": "5",
          "page": nextPage.toString(),
        },
        context,
      );

      print(branchId);

      if (!ref.mounted) return;

      if (response != null && response['data'] != null) {
        final data = response['data'];
        final List items = (data['data'] is List) ? data['data'] : [];
        final List<Map<String, dynamic>> newReviews = List<Map<String, dynamic>>.from(items);

        final lastPage = data['last_page'] ?? 1;
        final bool hasMoreData = nextPage < lastPage;

        state = state.copyWith(
          reviews: loadMore ? [...state.reviews, ...newReviews] : newReviews,
          currentPage: nextPage,
          hasMore: hasMoreData,
          isLoadingMore: false,
          isLoadingFirstTime: false,
        );
      } else {
        // في حال فشل الرد أو كان فارغاً
        state = state.copyWith(isLoadingMore: false, isLoadingFirstTime: false);
      }
    } catch (e) {
      print("Error fetching reviews: $e");
      if (ref.mounted) {
        state = state.copyWith(isLoadingMore: false, isLoadingFirstTime: false);
      }
    }
  }

  void reset() {
    state = ReviewsState(
      reviews: [],
      currentPage: 1,
      hasMore: true,
      isLoadingMore: false,
      isLoadingFirstTime: false,
    );
  }
}

// تعريف الـ Provider بالنوع الجديد للـ State
final reviewsRiverpod = NotifierProvider<PageNotifier, ReviewsState>(PageNotifier.new);