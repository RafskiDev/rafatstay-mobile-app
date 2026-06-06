import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/TextLanguage.dart';
import '../../Widget/ShowLoading.dart';
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

  // ⭐ متغيرات جديدة لتحكم في التحميل
  bool _imageLoaded = false;
  bool _isLoadingImage = true;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  int _getBranchId() {
    final id = widget.branchData["branch_id"] ?? widget.branchData["id"];
    return int.tryParse(id?.toString() ?? "0") ?? 0;
  }

  void _initData() {
    if (widget.branchData["latest_status"] != null) {
      statuses = [Map<String, dynamic>.from(widget.branchData["latest_status"])];
    } else {
      statuses = [];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final status in statuses) {
        final id = int.tryParse(status["id"]?.toString() ?? "0") ?? 0;
        if (id == 0) continue;

        final reactions = status["reactions"];

        // ✅ العدادات
        ref.read(Story_riverpod.notifier).likesCount[id] =
            int.tryParse(reactions?["likes_count"]?.toString() ?? "0") ?? 0;
        ref.read(Story_riverpod.notifier).dislikesCount[id] =
            int.tryParse(reactions?["dislikes_count"]?.toString() ?? "0") ?? 0;

        // ✅ حالة المستخدم — من is_liked / is_disliked بدل user_reaction
        final bool isLiked = reactions?["is_liked"] == true;
        final bool isDisliked = reactions?["is_disliked"] == true;
        ref.read(Story_riverpod.notifier).userReactions[id] =
        isLiked ? "like" : isDisliked ? "dislike" : null;
      }
      ref.read(Story_riverpod.notifier).ref.notifyListeners();
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    final int branchId = _getBranchId();
    final bool isBranchFavorited = widget.branchData["is_favorited"] == true;

    if (branchId != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(Story_riverpod.notifier).favoriteStatus[branchId] = isBranchFavorited;
        ref.read(Story_riverpod.notifier).ref.notifyListeners();
      });
    }

    // ⭐ لا نبدأ العداد هنا - ننتظر تحميل الصورة
    _preloadCurrentImage();
  }

  // ⭐ دالة جديدة: تحميل الصورة مسبقاً قبل بدء العداد
  void _preloadCurrentImage() {
    if (statuses.isEmpty) {
      setState(() {
        _isLoadingImage = false;
        _imageLoaded = true;
      });
      return;
    }

    final item = statuses[currentIndex];
    final mediaUrl = item["media_url"] ?? "";

    if (mediaUrl.isEmpty) {
      // لا توجد صورة، نبدأ العداد فوراً
      setState(() {
        _isLoadingImage = false;
        _imageLoaded = true;
      });
      _startProgress();
      return;
    }

    setState(() {
      _isLoadingImage = true;
      _imageLoaded = false;
    });

    // إنشاء ImageProvider وتحميلها
    final ImageProvider imageProvider = NetworkImage(mediaUrl);

    _imageListener = ImageStreamListener(
          (ImageInfo info, bool synchronousCall) {
        // ✅ الصورة اكتمل تحميلها
        _imageStream?.removeListener(_imageListener!);

        if (mounted) {
          setState(() {
            _isLoadingImage = false;
            _imageLoaded = true;
          });
          // نبدأ العداد بعد اكتمال التحميل
          _startProgress();
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        // ❌ فشل تحميل الصورة - نبدأ العداد على أي حال
        _imageStream?.removeListener(_imageListener!);

        if (mounted) {
          setState(() {
            _isLoadingImage = false;
            _imageLoaded = true; // نعتبرها محملة حتى لا نعلق
          });
          _startProgress();
        }
      },
    );

    _imageStream = imageProvider.resolve(const ImageConfiguration());
    _imageStream!.addListener(_imageListener!);
  }

  // ⭐ دالة جديدة: بدء العداد بعد التحميل
  void _startProgress() {
    _progressController?.removeStatusListener(_onProgressComplete);
    _progressController?.reset();

    ref.read(Story_riverpod.notifier).startWatching();

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
      setState(() {
        currentIndex++;
        // ⭐ إعادة تعيين حالة التحميل للصورة الجديدة
        _imageLoaded = false;
        _isLoadingImage = true;
      });
      _preloadCurrentImage(); // تحميل الصورة الجديدة
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        // ⭐ إعادة تعيين حالة التحميل للصورة الجديدة
        _imageLoaded = false;
        _isLoadingImage = true;
      });
      _preloadCurrentImage(); // تحميل الصورة الجديدة
    }
  }

  @override
  void dispose() {
    // ⭐ تنظيف مستمع الصورة
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    _progressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Story_riverpod);
    if (statuses.isEmpty) {
      return  Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            TextLanguage().GetWord("لا توجد ستوريات متوفرة"),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final item = statuses[currentIndex];
    final mediaUrl = item["media_url"] ?? "";
    final int statusId = int.tryParse(item["id"]?.toString() ?? "0") ?? 0;

    final int branchId = _getBranchId();
    final String businessName = widget.branchData["business_name"] ?? widget.branchData["name"] ?? "";
    final String? logoUrl = widget.branchData["logo_url"];
    final String timeAgo = widget.branchData["updated_ago"] ?? item["time_ago"] ?? "";
    final bool isFavorited = ref.read(Story_riverpod.notifier).favoriteStatus[branchId] ?? false;

    final int likesCountVal = ref.watch(Story_riverpod.notifier).likesCount[statusId]
        ?? int.tryParse(item["reactions"]?["total_count"]?.toString() ?? "0") ?? 0;

    final int dislikesCountVal = ref.watch(Story_riverpod.notifier).dislikesCount[statusId]
        ?? int.tryParse(item["reactions"]?["dislikes_count"]?.toString() ?? "0") ?? 0;
    final String? currentReaction = ref.watch(Story_riverpod.notifier).userReactions[statusId];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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

          if (_isLoadingImage && !_imageLoaded)
             Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    showLoading(),
                  ],
                ),
              ),
            ),

          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _imageLoaded ? _prevStory : null,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _imageLoaded ? _nextStory : null,
                  ),
                ),
              ],
            ),
          ),

          // 4. خطوط مؤشرات تقدم الستوريات العلوية (Progress Indicators)
          // ⭐ لا نعرض العداد إلا بعد اكتمال التحميل
          if (_imageLoaded)
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
                        color: i < currentIndex
                            ? Themes().GetColor("primary")
                            : const Color(0xFFD3E9F8),
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

          // 5. زر الرجوع والإغلاق
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

          // 6. اسم الفرع + شعار اللوجو ووقت النشر العلوي
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
                      backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                          ? NetworkImage(logoUrl)
                          : null,
                      child: (logoUrl == null || logoUrl.isEmpty)
                          ? const Icon(Icons.store, color: Colors.white, size: 16)
                          : null,
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
          //هذا تبع المفضله وا الاعجاب
          Positioned(
            left: Sizes(context).GetWidth() * 3,
            top: Sizes(context).GetHeight() * 56,
            child: Column(
              children: [
                /*
                // ✅ زر المفضلة التفاعلي الذي يتعامل بديناميكية تامة الآن
                CircularButton(
                  size: Sizes(context).GetHeight() * 5.5,
                 // backgroundColor: isFavorited ? Themes().GetColor("primary") : Themes().GetColor("backgroundOffWhite"),
                  borderColor:Colors.transparent,
                  onTap: () {
                    ref.read(Story_riverpod.notifier).toggleFavorite(context, branchId);
                  },
                  // ✅ هنا يتم تبديل الأيقونة تلقائياً بناءً على حالة المفضلة
                  child: SvgPicture.asset(
                    !isFavorited ? "assets/icon/Interested_fav.svg" : "assets/icon/un_Interested_fav.svg",
                    height: Sizes(context).GetHeight() * 15,
                  ),
                ),
                SizedBox(height: Sizes(context).GetHeight() * 1),

                 */
                // زر الـ Likes
                _statChip(
                  icon: "assets/icon/likes.svg",
                  value: likesCountVal.toString(),  // ← هنا التغيير
                  isActive: currentReaction == "like",  // ← استخدم currentReaction من notifier
                  onTap: () {
                    final bool wasLiked = currentReaction == "like";
                    ref.read(Story_riverpod.notifier).toggleReaction(
                      context,
                      statusId,
                      "like",
                      wasLiked,
                      likesCountVal,
                    );
                  },
                  context: context,
                ),
                SizedBox(height: Sizes(context).GetHeight() * 1),

                // زر الـ Dislikes
                _statChip(
                  icon: "assets/icon/dislike.svg",
                  value: dislikesCountVal.toString(),  // ← من notifier مو من item
                  isActive: currentReaction == "dislike",
                  onTap: () {
                    final bool wasDisliked = currentReaction == "dislike";
                    ref.read(Story_riverpod.notifier).toggleReaction(
                      context,
                      statusId,
                      "dislike",
                      wasDisliked,
                      dislikesCountVal,
                    );
                  },
                  context: context,
                ),
              ],
            ),
          ),
          //هذا تبع الكومنتات
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
          backgroundColor: isActive
              ? Themes().GetColor("primary")
              : Themes().GetColor("backgroundOffWhite"),
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