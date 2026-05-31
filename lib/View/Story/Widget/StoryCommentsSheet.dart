import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../Service/ApiService.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/ShowLoading.dart';
import 'package:flutter_svg/svg.dart';

// ─── Notifier ───────────────────────────────────────────────────────────────
class StoryCommentsNotifier extends Notifier<int> {
  List<Map<String, dynamic>> comments = [];
  int totalCount = 0;
  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  bool isSending = false;
  int? _currentStatusId;

  @override
  int build() => 0;

  Future<void> fetchComments(BuildContext context, int statusId, {bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore || isFetchingMore) return;
      isFetchingMore = true;
    } else {
      if (_currentStatusId == statusId && comments.isNotEmpty) return;
      _currentStatusId = statusId;
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      comments.clear();
    }
    state++;

    final response = await ApiService().get(
      "v1/guest/statuses/$statusId/comments",
      {"per_page": "15", "page": "$currentPage"},
      context,
    );

    if (response?["success"] == true) {
      final data = response["data"];
      totalCount = data?["status"]?["comments_count"]
          ?? data?["summary"]?["total_count"]
          ?? 0;

      final list = data?["comments"] as List? ?? [];
      final newItems = List<Map<String, dynamic>>.from(list);

      if (loadMore) {
        comments.addAll(newItems);
      } else {
        comments = newItems;
      }

      final pagination = data?["pagination"];
      hasMore = pagination != null
          ? currentPage < (pagination["last_page"] ?? 1)
          : false;
      currentPage++;
    } else {
      hasMore = false;
    }

    isLoading = false;
    isFetchingMore = false;
    state++;
  }

  Future<void> sendComment(BuildContext context, int statusId, String content) async {
    if (content.trim().isEmpty) return;
    isSending = true;
    state++;

    final response = await ApiService().post(
      "v1/guest/statuses/$statusId/comments",
      {"content": content.trim()},
      context,
    );

    if (response?["success"] == true) {
      final newComment = Map<String, dynamic>.from(response["data"]);
      comments.insert(0, newComment);
      totalCount++;
    }

    isSending = false;
    state++;
  }

  void reset() {
    _currentStatusId = null;
    comments.clear();
    totalCount = 0;
    currentPage = 1;
    hasMore = true;
    isLoading = false;
    isFetchingMore = false;
    state++;
  }
}

final storyCommentsProvider = NotifierProvider<StoryCommentsNotifier, int>(
  StoryCommentsNotifier.new,
);

// ─── Bottom Sheet ────────────────────────────────────────────────────────────
void showStoryComments(BuildContext context, int statusId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFAF5EB),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => StoryCommentsSheet(statusId: statusId),
  );
}

// ─── Sheet Widget ─────────────────────────────────────────────────────────────
class StoryCommentsSheet extends ConsumerStatefulWidget {
  final int statusId;
  const StoryCommentsSheet({super.key, required this.statusId});

  @override
  ConsumerState<StoryCommentsSheet> createState() => _StoryCommentsSheetState();
}

class _StoryCommentsSheetState extends ConsumerState<StoryCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // reset بدون state++ ثم fetch
      ref.read(storyCommentsProvider.notifier).reset();
      ref.read(storyCommentsProvider.notifier).fetchComments(context, widget.statusId);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(storyCommentsProvider.notifier).fetchComments(
        context,
        widget.statusId,
        loadMore: true,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(storyCommentsProvider);
    final notifier = ref.read(storyCommentsProvider.notifier);
    final sizes = Sizes(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) {
          return Column(
            children: [
              // ─── Handle ───
              Container(
                margin: EdgeInsets.symmetric(vertical: sizes.GetHeight() * 1),
                width: sizes.GetWidth() * 10,
                height: sizes.GetHeight() * 0.5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
      
              // ─── Title ───
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Comment ${notifier.totalCount}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Themes().GetColor("textPrimary"),
                      ),
                    ),
                    Divider(color: Colors.grey[300]),
                  ],
                ),
              ),
      
              // ─── Comments List ───
              Expanded(
                child: notifier.isLoading
                    ? Center(child: showLoading())
                    : notifier.comments.isEmpty
                    ? Center(
                  child: Text(
                    "لا يوجد تعليقات",
                    style: TextStyle(color: Themes().GetColor("textSecondary")),
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
                  itemCount: notifier.comments.length + (notifier.isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= notifier.comments.length) {
                      return Center(child: showLoading());
                    }
                    return _CommentCard(
                      comment: notifier.comments[index],
                      sizes: sizes,
                    );
                  },
                ),
              ),
      
              // ─── Input ───
              _CommentInput(
                controller: _controller,
                isSending: notifier.isSending,
                onSend: () async {
                  final text = _controller.text;
                  _controller.clear();
                  await ref.read(storyCommentsProvider.notifier).sendComment(
                    context,
                    widget.statusId,
                    text,
                  );
                },
                sizes: sizes,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Comment Card ─────────────────────────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;
  final Sizes sizes;

  const _CommentCard({required this.comment, required this.sizes});

  @override
  Widget build(BuildContext context) {
    final user = comment["user"] ?? {};
    final avatarUrl = user["avatar_url"] ?? "";
    final name = user["name"] ?? "";
    final content = comment["content"] ?? "";
    final timeAgo = comment["time_ago"] ?? "";

    return Container(
      margin: EdgeInsets.only(bottom: sizes.GetHeight() * 1.5),
      padding: EdgeInsets.all(sizes.GetWidth() * 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: sizes.GetHeight() * 2.5,
                backgroundColor: Colors.grey[200],
                backgroundImage: avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Icon(Icons.person, size: sizes.GetHeight() * 2.5, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: sizes.GetWidth() * 2),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Themes().GetColor("textPrimary"),
                ),
              ),
              SizedBox(width: sizes.GetWidth() * 2),
              Text(
                ". $timeAgo",
                style: TextStyle(fontSize: 11, color: Themes().GetColor("textSecondary")),
              ),
            ],
          ),
          SizedBox(height: sizes.GetHeight() * 1),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: Themes().GetColor("textPrimary"),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Comment Input ────────────────────────────────────────────────────────────
class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final Sizes sizes;

  const _CommentInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        sizes.GetWidth() * 4,
        sizes.GetHeight() * 1,
        sizes.GetWidth() * 4,
        sizes.GetHeight() * 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Comment .....",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: sizes.GetWidth() * 2),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              width: sizes.GetHeight() * 5,
              height: sizes.GetHeight() * 5,
              decoration: BoxDecoration(
                color: Themes().GetColor("textPrimary"),
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Center(
                child: SvgPicture.asset(
                  "assets/icon/send.svg",
                  height: Sizes(context).GetHeight() * 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}