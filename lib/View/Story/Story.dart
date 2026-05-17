import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/svg.dart';
import '../../Service/ApiService.dart';
import '../../Widget/WidgetButton.dart';
import 'Story_riverpod.dart';

class Story extends ConsumerStatefulWidget {
  final String image;
  final String icon;
  final String text;
  final List<Map<String, dynamic>> statuses;

  const Story({
    super.key,
    required this.image,
    required this.icon,
    required this.text,
    required this.statuses,
  });

  @override
  ConsumerState<Story> createState() => _StoryState();
}

class _StoryState extends ConsumerState<Story> {
  int currentIndex = 0;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  void _loadCurrent() {
    _controller?.dispose();
    _controller = null;
   // ref.read(Story_riverpod.notifier).isLiked = false;
  //  ref.read(Story_riverpod.notifier).isDisliked = false;
  //  print(widget.statuses);
    ref.read(Story_riverpod.notifier).startWatching();
    final item = widget.statuses[currentIndex];
    final isVideo = item["media_type"] == "video";

    if (isVideo) {
      final url = "$baseUrl/storage/${item["media_path"]}";
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller!.play();
          }
        });

      _controller!.addListener(() {
        if (!mounted) return;
        setState(() {});
        final pos = _controller!.value.position;
        final dur = _controller!.value.duration;
        if (dur.inSeconds > 0 && pos >= dur) {
          _nextStory();
        }
      });
    } else {
      setState(() {});
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) _nextStory();
      });
    }
  }

  void _nextStory() {
    final item = widget.statuses[currentIndex];
    final duration = _controller?.value.duration.inSeconds ?? 5;

    // ─── سجل قبل الانتقال ───
    ref.read(Story_riverpod.notifier).recordView(
      context,
      item["id"],
      totalDuration: duration,
    );

    if (currentIndex < widget.statuses.length - 1) {
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
    _controller?.dispose();
    super.dispose();
  }

  double get progress {
    if (_controller == null || !_controller!.value.isInitialized) return 0;
    final dur = _controller!.value.duration.inMilliseconds;
    if (dur == 0) return 0;
    return _controller!.value.position.inMilliseconds / dur;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.statuses[currentIndex];
    final isVideo = item["media_type"] == "video";
    final mediaUrl = "https://yourdomain.com/storage/${item["media_path"]}";
    final caption = item["caption"] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── الميديا (فيديو أو صورة) ───
          SizedBox.expand(
            child: isVideo
                ? (_controller != null && _controller!.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
                : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ))
                : Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                widget.image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ─── مؤشرات الستوريات (أعلى) ───
          Positioned(
            top: Sizes(context).GetHeight() * 5,
            left: Sizes(context).GetWidth() * 2,
            right: Sizes(context).GetWidth() * 2,
            child: Row(
              children: List.generate(widget.statuses.length, (i) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: Sizes(context).GetHeight() * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: i < currentIndex
                          ? Themes().GetColor("primary")
                          : i == currentIndex
                          ? Themes().GetColor("primary").withOpacity(0.6)
                          : const Color(0xFFD3E9F8),
                    ),
                    child: i == currentIndex && isVideo
                        ? FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Themes().GetColor("primary"),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                        : null,
                  ),
                );
              }),
            ),
          ),

          // ─── زر الرجوع ───
          Positioned(
            right: Sizes(context).GetWidth() * 5,
            top: Sizes(context).GetHeight() * 7,
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

          // ─── اسم الفرع + الوقت ───
          Positioned(
            right: Sizes(context).GetWidth() * 5,
            top: Sizes(context).GetHeight() * 14,
            child: Container(
              decoration: BoxDecoration(
                color: Themes().GetColor("backgroundOffWhite"),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(Sizes(context).GetWidth() * 1, 0, Sizes(context).GetWidth() * 2, 0),
                child: Row(
                  children: [
                    CircularButton(
                      size: Sizes(context).GetHeight() * 5,
                      backgroundColor: Themes().GetColor("secondaryPrimary"),
                      borderColor: Themes().GetColor("secondaryPrimary"),
                      onTap: () {},
                      child: Center(
                        child: Image.asset(
                          widget.icon,
                          height: Sizes(context).GetHeight() * 4,
                        ),
                      ),
                    ),
                    SizedBox(width: Sizes(context).GetWidth() * 1),
                    Text("15 minutes ago.", style: const TextStyle(fontSize: 9)),
                    Text(widget.text),
                  ],
                ),
              ),
            ),
          ),

          // ─── كابشن ───
          if (caption.isNotEmpty)
            Positioned(
              bottom: Sizes(context).GetHeight() * 8,
              left: Sizes(context).GetWidth() * 5,
              right: Sizes(context).GetWidth() * 5,
              child: Text(
                caption,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          // ─── زر اللايك ───
          Positioned(
            left: Sizes(context).GetWidth() * 5,
            top: Sizes(context).GetHeight() * 45,
            child: CircularButton(
              size: Sizes(context).GetHeight() * 5,
              backgroundColor: Themes().GetColor("backgroundOffWhite"),
              borderColor: Themes().GetColor("backgroundOffWhite"),
              onTap: () {
                final item = widget.statuses[currentIndex];
                ref.read(Story_riverpod.notifier).toggleReaction(context, item["id"], "like");
              },
              child: Center(
                child: SvgPicture.asset(
                  "assets/icon/likes.svg",
                  height: Sizes(context).GetHeight() * 3,
                ),
              ),
            ),
          ),

          // ─── زر الدسلايك ───
          Positioned(
            left: Sizes(context).GetWidth() * 5,
            top: Sizes(context).GetHeight() * 52,
            child: CircularButton(
              size: Sizes(context).GetHeight() * 5,
              backgroundColor: Themes().GetColor("backgroundOffWhite"),
              borderColor: Themes().GetColor("backgroundOffWhite"),
              onTap: () {
                final item = widget.statuses[currentIndex];
                ref.read(Story_riverpod.notifier).toggleReaction(context, item["id"], "dislike");
              },
              child: Center(
                child: SvgPicture.asset(
                  "assets/icon/dislike.svg",
                  color:Themes().GetColor("textPrimary"),
                  height: Sizes(context).GetHeight() * 3,
                ),
              ),
            ),
          ),

          // ─── التنقل (ضغط يمين/يسار) ───
          Row(
            children: [
              Expanded(child: GestureDetector(onTap: _prevStory)),
              Expanded(child: GestureDetector(onTap: _nextStory)),
            ],
          ),
        ],
      ),
    );
  }
}