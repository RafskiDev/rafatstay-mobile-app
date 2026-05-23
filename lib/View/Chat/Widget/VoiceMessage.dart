import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
class VoiceMessage extends StatefulWidget {
  final String voiceUrl;
  final bool sentByMe;
  final String time;
  final int duration;
  final double progress;

  const VoiceMessage({
    super.key,
    required this.voiceUrl,
    this.sentByMe = false,
    this.time = "",
    this.duration = 5,
    this.progress = 0.0,
  });

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _currentProgress = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
   // _currentProgress = widget.progress-1;
    _currentProgress = widget.progress;
  }

  void _initPlayer() {
    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentProgress = -1;
        });
      }
    });

    _player.onPositionChanged.listen((position) {
      if (mounted && widget.duration > 0) {
        setState(() {
          _currentProgress = position.inSeconds / widget.duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (widget.voiceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن تشغيل هذا الملف')),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        setState(() => _isLoading = true);

        if (widget.voiceUrl.startsWith("http")) {
          await _player.play(UrlSource(widget.voiceUrl));
        } else {
          await _player.play(DeviceFileSource(widget.voiceUrl));
        }

        setState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تشغيل الصوت: ${e.toString()}')),
      );
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int _getRemainingSeconds() {
    if (_currentProgress <= 0) return widget.duration; // 👈 عند الإرسال
    return (widget.duration * (1 - _currentProgress)).round();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final int totalBars = 30;

    return Container(
      constraints: BoxConstraints(
        maxWidth: sizes.GetWidth() * 70,
        minWidth: sizes.GetWidth() * 40,
      ),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: widget.sentByMe
            ? Themes().GetColor("primaryA")
            : Themes().GetColor("primaryS"),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ مهم جداً
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي (زر التشغيل + الموجة)
          Row(
            mainAxisSize: MainAxisSize.min, // ✅ بدلاً من max
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // زر التشغيل/الإيقاف
              GestureDetector(
                onTap: _playPause,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sizes.GetWidth() * 2),
              // شكل الموجة (Waveform)
              SizedBox(
                width: sizes.GetWidth() * 44, // عرض ثابت
                height: sizes.GetHeight() * 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalBars, (index) {
                    double height = (8 + ((index * 13) % 20) * 1.5).toDouble();
                    bool isPlayed = (index / totalBars) <= _currentProgress;
                    return Container(
                      width: 3,
                      height: height,
                      decoration: BoxDecoration(
                        color: isPlayed
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.GetHeight() * 1),
          // الوقت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_getRemainingSeconds()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                widget.time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}