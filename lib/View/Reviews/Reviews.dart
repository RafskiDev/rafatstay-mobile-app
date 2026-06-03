import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/ReviewCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/VideoImageCard.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../Payment/Payment.dart';
import 'Reviews_riverpod.dart';

class Reviews extends ConsumerStatefulWidget {
  final int branchId;
  const Reviews({super.key, required this.branchId});

  @override
  ConsumerState<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends ConsumerState<Reviews> {
  final ScrollController _scrollController = ScrollController();
  late PageNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(Reviews_riverpod.notifier);

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.fetchReviews(context, widget.branchId);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = 200;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      _notifier.fetchReviews(
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
    ref.watch(Reviews_riverpod);
    final notifier = ref.read(Reviews_riverpod.notifier);
    final sizes = Sizes(context);
    final theme = Themes();
    final reviews = notifier.reviews;

    return Scaffold(
      appBar: buildCustomAppBar(context, TextLanguage().GetWord("التقييمات")),
      backgroundColor: theme.GetColor("background"),
      body: ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          if (reviews.isEmpty && notifier.currentPage == 1) {
            return showLoading();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2, vertical: sizes.GetHeight() * 2),
                  itemCount: reviews.length + 1, // +1 للـ loading
                  itemBuilder: (context, index) {
                    if (index == reviews.length) {
                      if (notifier.isLoadingMore) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: showLoading(),
                              ),
                            ),
                            SizedBox(height: sizes.GetHeight() * 2),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    final item = reviews[index];


                    // ✅ استخراج روابط الميديا بشكل آمن وصحيح
                    final mediaList = item["media"] as List? ?? [];



                    // ✅ تأمين جلب أول مسار صورة للتقييم بدون استخدام الترتيب الخارجي (index) لمنع الكراش
                    final String imageOnlyUrl = mediaList.isNotEmpty && mediaList[0]["media_url"] != null
                        ? "${mediaList[0]["media_url"]}"
                        : "";
                    return Padding(
                      padding: EdgeInsets.only(bottom: sizes.GetHeight() * 2),
                      child: ReviewCard(
                        name: item["user"]?["full_name"]?.toString() ?? "غير معروف",
                        date: DateTimeHelper.extractTime(item["created_at"]),
                        comment: item["comment"]?.toString() ?? "",
                        rating: item["overall_rating"] ?? 0,
                        // ✅ تأمين قراءة بيانات الأفاتار للمستخدم حتى لو كانت القيمة لست نصية مباشرة
                        image:item["user"]["avatar_url"]?.toString()??"",
                        video: null,
                        // ✅ تمرير مسار الصورة المصلح والآمن هنا
                        imageOnly: imageOnlyUrl,
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
              SizedBox(height: sizes.GetHeight() * 2),
            ],
          );
        },
      ),
    );
  }
}