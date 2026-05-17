import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
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
  // ✅ ScrollController في الـ State مو الـ notifier
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
      appBar: buildCustomAppBar(context,"Reviews"),
      backgroundColor: theme.GetColor("background"),
      body: ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            if (reviews.isEmpty && notifier.currentPage == 1) {
              return showLoading();
            }
            return   Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // ✅
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
                      return Padding(
                        padding: EdgeInsets.only(bottom: sizes.GetHeight() * 2),
                        child: ReviewCard(
                          name: item["user"]?["full_name"]?.toString() ?? "غير معروف",
                          date: item["created_at"]?.toString() ?? "",        // ✅
                          comment: item["comment"]?.toString() ?? "",         // ✅
                          rating: item["overall_rating"] ?? 0,
                          image: (item["media"] is List && item["media"].isNotEmpty)
                              ? (item["media"][0]["url"] ?? "").toString()  // ✅
                              : "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                          video: null,
                          imageOnly: null,
                          sizes: sizes,
                          theme: theme,
                          onAvatarTap: ()async {

                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: sizes.GetHeight() * 2),
              ],
            );
          }

      ),
    );
  }
}
