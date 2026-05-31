import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:flutter_svg/svg.dart';
import '../../Widget/WidgetButton.dart';
import 'Story_riverpod.dart';
import 'Widget/StoryCommentsSheet.dart';

class Story extends ConsumerStatefulWidget {
  final Map<String, dynamic> branchData;

  const Story({
    super.key,
    required this.branchData,
  });

  @override
  ConsumerState<Story> createState() => _StoryState();
}

class _StoryState extends ConsumerState<Story> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  AnimationController? _progressController;

  Map<int, String?> reactions = {};
  List<Map<String, dynamic>> statuses = [];

  // دالة ذكية لاستخراج الـ branch_id ديناميكياً حسب التصميمين
  int _getBranchId() {
    final id = widget.branchData["branch_id"] ?? widget.branchData["id"];
    return int.tryParse(id?.toString() ?? "0") ?? 0;
  }

  void _initData() {
    // قراءة مصفوفة الستوريات الكاملة أو الـ latest_status بناءً على الاستجابة
    if (widget.branchData["latest_status"] != null) {
      statuses = [Map<String, dynamic>.from(widget.branchData["latest_status"])];
    } else {
      statuses = [];
    }

    for (final status in statuses) {
      final id = int.tryParse(status["id"]?.toString() ?? "0") ?? 0;
      final userReaction = status["reactions"]?["user_reaction"];
      if (id != 0) {
        reactions[id] = userReaction?.toString();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // ✅ جلب الـ ID بشكل ديناميكي آمن
    final int branchId = _getBranchId();
    final bool isBranchFavorited = widget.branchData["is_favorited"] == true;

    if (branchId != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // تحديث حالة الـ Riverpod بالحالة الحقيقية
        ref.read(Story_riverpod.notifier).favoriteStatus[branchId] = isBranchFavorited;
        ref.read(Story_riverpod.notifier).ref.notifyListeners();
      });
    }

    _loadCurrent();
  }

  void _loadCurrent() {
    _progressController?.stop();
    _progressController?.reset();
    _progressController?.removeStatusListener(_onProgressComplete);

    ref.read(Story_riverpod.notifier).startWatching();

    setState(() {});
    _progressController?.duration = const Duration(seconds: 5);
    _progressController?.forward();
    _progressController?.addStatusListener(_onProgressComplete);
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) _nextStory();
  }

  void _nextStory() {
    if (statuses.isEmpty) return;
    final item = statuses[currentIndex];

    ref.read(Story_riverpod.notifier).recordView(
      context,
      item["id"],
      totalDuration: 5,
    );

    if (currentIndex < statuses.length - 1) {
      setState(() => currentIndex++);
      _loadCurrent();
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _loadCurrent();
    }
  }

  @override
  void dispose() {
    _progressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Story_riverpod);
    if (statuses.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("لا توجد ستوريات متوفرة", style: TextStyle(color: Colors.white))),
      );
    }

    final item = statuses[currentIndex];
    final mediaUrl = item["media_url"] ?? "";
    final int statusId = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;

    // ✅ جلب الـ branch_id بشكل ديناميكي آمن
    final int branchId = _getBranchId();
    final String businessName = widget.branchData["business_name"] ?? widget.branchData["name"] ?? "";
    final String? logoUrl = widget.branchData["logo_url"];
    final String timeAgo = widget.branchData["updated_ago"] ?? item["time_ago"] ?? "";
    final bool isFavorited = ref.read(Story_riverpod.notifier).favoriteStatus[branchId] ?? false;
    // احسب القيم
    final int likesCountVal = ref.read(Story_riverpod.notifier).likesCount[statusId]
        ?? int.tryParse(item["reactions"]?["total_count"]?.toString() ?? "0") ?? 0;

    final int dislikesCountVal = ref.read(Story_riverpod.notifier).dislikesCount[statusId]
        ?? int.tryParse(item["reactions"]?["dislikes_count"]?.toString() ?? "0") ?? 0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. الصورة أو الخلفية للستوري
          SizedBox.expand(
            child: mediaUrl.isNotEmpty
                ? Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
              ),
            )
                : Container(color: Colors.grey[900]),
          ),

          // 2. مناطق التنقل (يمين ويسار الشاشة للتنقل)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _prevStory,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _nextStory,
                  ),
                ),
              ],
            ),
          ),

          // 3. خطوط مؤشرات تقدم الستوريات العلوية (Progress Indicators)
          Positioned(
            bottom: Sizes(context).GetHeight() * 5,
            left: Sizes(context).GetWidth() * 2,
            right: Sizes(context).GetWidth() * 2,
            child: Row(
              children: List.generate(statuses.length, (i) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: Sizes(context).GetHeight() * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: i < currentIndex ? Themes().GetColor("primary") : const Color(0xFFD3E9F8),
                    ),
                    child: i == currentIndex
                        ? AnimatedBuilder(
                      animation: _progressController!,
                      builder: (context, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressController?.value ?? 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Themes().GetColor("primary"),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    )
                        : null,
                  ),
                );
              }),
            ),
          ),

          // 4. زر الرجوع والإغلاق
          Positioned(
            right: Sizes(context).GetWidth() * 5,
            top: Sizes(context).GetHeight() * 8,
            child: CircularButton(
              size: Sizes(context).GetHeight() * 5,
              backgroundColor: Themes().GetColor("backgroundOffWhite"),
              borderColor: Themes().GetColor("backgroundOffWhite"),
              onTap: () => Navigator.pop(context),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icon/Arrow_one.svg",
                  height: Sizes(context).GetHeight() * 4,
                ),
              ),
            ),
          ),

          // 5. اسم الفرع + شعار اللوجو ووقت النشر العلوي
          Positioned(
            left: Sizes(context).GetWidth() * 5,
            top: Sizes(context).GetHeight() * 8,
            child: Container(
              decoration: BoxDecoration(
                color: Themes().GetColor("backgroundOffWhite"),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes(context).GetWidth() * 2,
                  vertical: Sizes(context).GetHeight() * 0.5,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Sizes(context).GetHeight() * 2,
                      backgroundColor: Themes().GetColor("secondaryPrimary"),
                      backgroundImage: (logoUrl != null && logoUrl.isNotEmpty) ? NetworkImage(logoUrl) : null,
                      child: (logoUrl == null || logoUrl.isEmpty) ? const Icon(Icons.store, color: Colors.white, size: 16) : null,
                    ),
                    SizedBox(width: Sizes(context).GetWidth() * 2),
                    Text(
                      businessName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(width: Sizes(context).GetWidth() * 1.5),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. عمود الأزرار الجانبية (المفضلة واللايك والديسلايك)
          Positioned(
            left: Sizes(context).GetWidth() * 3,
            top: Sizes(context).GetHeight() * 50,
            child: Column(
              children: [
                // ✅ زر المفضلة التفاعلي الذي يتعامل بديناميكية تامة الآن
                CircularButton(
                  size: Sizes(context).GetHeight() * 5,
                  backgroundColor: isFavorited ? Themes().GetColor("primary") : Themes().GetColor("backgroundOffWhite"),
                  borderColor: Themes().GetColor("backgroundOffWhite"),
                  onTap: () {
                    ref.read(Story_riverpod.notifier).toggleFavorite(context, branchId);
                  },
                  child: SvgPicture.asset("assets/icon/Interested.svg"),
                ),
                SizedBox(height: Sizes(context).GetHeight() * 2),

                // زر الـ Likes
                _statChip(
                  icon: "assets/icon/likes.svg",
                  value: item["reactions"]?["total_count"]?.toString() ?? "0",
                  isActive: reactions[statusId] == "like",
                  onTap: () {
                    setState(() {
                      reactions[statusId] = reactions[statusId] == "like" ? null : "like";
                    });
                    ref.read(Story_riverpod.notifier).toggleReaction(
                      context,
                      statusId,
                      "like",
                      reactions[statusId] == "like", // الحالة قبل التغيير — لازم تحسبها قبل setState
                      likesCountVal,
                    );
                  },
                  context: context,
                ),
                SizedBox(height: Sizes(context).GetHeight() * 1),

                // زر الـ Dislikes
                _statChip(
                  icon: "assets/icon/dislike.svg",
                  value: item["reactions"]?["dislikes_count"]?.toString() ?? "0",
                  isActive: reactions[statusId] == "dislike",
                  onTap: () {
                    final bool wasLiked = reactions[statusId] == "like";
                    final bool wasDisliked = reactions[statusId] == "dislike";

                    setState(() {
                      reactions[statusId] = wasLiked ? null : "like";
                      // إذا كان dislike وحول لـ like، اطرح من الـ dislikes
                      if (wasDisliked) {
                        ref.read(Story_riverpod.notifier).dislikesCount[statusId] =
                            (dislikesCountVal - 1).clamp(0, 999);
                      }
                    });

                    ref.read(Story_riverpod.notifier).toggleReaction(
                      context, statusId, "like", wasLiked, likesCountVal,
                    );
                  },
                  context: context,
                ),
              ],
            ),
          ),
          Positioned(
            left: Sizes(context).GetWidth() * 3,
            top: Sizes(context).GetHeight() * 75,
            child: GestureDetector(
              onTap: () => showStoryComments(context, item["id"]),
              child: Column(
                children: [
                  CircularButton(
                    size: Sizes(context).GetHeight() * 5,
                    backgroundColor: Themes().GetColor("backgroundOffWhite"),
                    borderColor: Themes().GetColor("backgroundOffWhite"),
                    onTap: () => showStoryComments(context, item["id"]),
                    child: SvgPicture.asset("assets/icon/Comment.svg"),
                  ),
                  SizedBox(height: Sizes(context).GetHeight() * 0.5),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes(context).GetWidth() * 2,
                      vertical: Sizes(context).GetHeight() * 0.3,
                    ),
                    decoration: BoxDecoration(
                      color: Themes().GetColor("backgroundOffWhite"),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item["comments_count"]?.toString() ?? "0",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String icon,
    required String value,
    required VoidCallback onTap,
    required BuildContext context,
    bool isActive = false,
  }) {
    return Column(
      children: [
        CircularButton(
          size: Sizes(context).GetHeight() * 5,
          backgroundColor: isActive ? Themes().GetColor("primary") : Themes().GetColor("backgroundOffWhite"),
          borderColor: Themes().GetColor("backgroundOffWhite"),
          onTap: onTap,
          child: SvgPicture.asset(
            icon,
            height: Sizes(context).GetHeight() * 3,
            color: isActive ? Colors.white : null,
          ),
        ),
        SizedBox(height: Sizes(context).GetHeight() * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes(context).GetWidth() * 2,
            vertical: Sizes(context).GetHeight() * 0.3,
          ),
          decoration: BoxDecoration(
            color: Themes().GetColor("backgroundOffWhite"),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(value, style: const TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}