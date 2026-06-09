import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ReviewCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import 'Reviews_riverpod.dart';

class Reviews extends ConsumerStatefulWidget {
  final int branchId;
  const Reviews({super.key, required this.branchId});

  @override
  ConsumerState<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends ConsumerState<Reviews> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // استدعاء التحميل الأول عند بناء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewsRiverpod.notifier).fetchReviews(context, widget.branchId);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = 200;
    // التأكد من وصول المستخدم لقرب نهاية القائمة
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      ref.read(reviewsRiverpod.notifier).fetchReviews(
        context,
        widget.branchId,
        loadMore: true,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة الستيت بالكامل، أي تغيير هنا سيحدث الواجهة فوراً بشكل آمن
    final reviewState = ref.watch(reviewsRiverpod);
    final sizes = Sizes(context);
    final theme = Themes();
    final reviews = reviewState.reviews;

    return Scaffold(
      appBar: buildCustomAppBar(context, TextLanguage().GetWord("التقييمات")),
      backgroundColor: theme.GetColor("background"),
      body: Builder(
        builder: (context) {
          // إذا كان أول تحميل والقائمة فارغة، اعرض مؤشر التحميل الرئيسي
          if (reviewState.isLoadingFirstTime && reviews.isEmpty) {
            return Center(child: showLoading());
          }

          // إذا انتهى التحميل ولا يوجد بيانات
          if (reviews.isEmpty) {
            return Center(
              child: Text(
                TextLanguage().GetWord("لا توجد تقييمات حالياً"),
                style: TextStyle(color: theme.GetColor("text"), fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.GetWidth() * 2,
                    vertical: sizes.GetHeight() * 2,
                  ),
                  // زيادة 1 لعرض الـ Loader بالأسفل عند جلب بيانات إضافية
                  itemCount: reviews.length + 1,
                  itemBuilder: (context, index) {
                    // إذا وصلنا للعنصر الأخير (الـ Loader السفلي)
                    if (index == reviews.length) {
                      if (reviewState.isLoadingMore) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: showLoading()),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    final item = reviews[index];
                    final mediaList = item["media"] as List? ?? [];
                    // استخراج روابط الميديا بشكل آمن
                    final imageMedia = mediaList.firstWhere(
                          (m) => m["media_type"] == "image",
                      orElse: () => null,
                    );

                    final String imageUrl = imageMedia != null
                        ? (imageMedia["media_url"]?.toString() ?? "")
                        : "";
                    return Padding(
                      padding: EdgeInsets.only(bottom: sizes.GetHeight() * 2),
                      child: ReviewCard(
                        name: item["user"]?["full_name"]?.toString() ?? "غير معروف",
                        date: DateTimeHelper.extractTime(item["created_at"]),
                        comment: item["comment"]?.toString() ?? "",
                        rating: item["overall_rating"] ?? 0,
                        image: item["user"]?["avatar_url"]?.toString() ?? "",
                        video: null,
                        imageOnly: imageUrl,
                        sizes: sizes,
                        theme: theme,
                        mediaItems: List<dynamic>.from(mediaList),
                        onAvatarTap: () async {
                          // الأكشن الخاص بالضغط على الأفاتار
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}