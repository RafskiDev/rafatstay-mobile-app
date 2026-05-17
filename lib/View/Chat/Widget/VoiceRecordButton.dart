import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/WidgetButton.dart';

class VoiceRecordButton extends StatefulWidget {
  final Function(File audioFile, int duration) onSend;

  const VoiceRecordButton({
    super.key,
    required this.onSend,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  int _recordDuration = 0;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    if (!await _checkPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء السماح باستخدام الميكروفون')),
      );
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
   // final directory = await getTemporaryDirectory();
    final path = '${directory.path}/voice_${DateTime
        .now()
        .millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordDuration = 0;
      });

      _updateDuration();
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;

    setState(() => _isPlaying = true);
    await _player.play(DeviceFileSource(_recordingPath!));
    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  void _cancelRecording() {
    setState(() {
      _recordingPath = null;
      _recordDuration = 0;
      _isRecording = false;
    });
  }

  void _sendRecording() {
    if (_recordingPath != null) {
      widget.onSend(File(_recordingPath!), _recordDuration);
      setState(() {
        _recordingPath = null;
        _recordDuration = 0;
      });
    }
  }

  void _updateDuration() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordDuration++;
        });
        _updateDuration();
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds
        .toString()
        .padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);

    if (_recordingPath != null && !_isRecording) {
      // بعد التسجيل - عرض التحكم
      return Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        decoration: BoxDecoration(
          color: Themes().GetColor("backgroundOffWhite"),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر تشغيل
            CircularButton(
              size: sizes.GetHeight() * 4,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              onTap: _playRecording,
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Themes().GetColor("textPrimary"),
                size: sizes.GetHeight() * 3,
              ),
            ),
            // عرض المدة
            Text(
              _formatDuration(_recordDuration),
              style: TextStyle(
                fontSize: sizes.GetHeight() * 1.8,
                fontWeight: FontWeight.bold,
                color: Themes().GetColor("textPrimary"),
              ),
            ),
            SizedBox(width: sizes.GetWidth() * 2),
            // زر إلغاء
            CircularButton(
              size: sizes.GetHeight() * 4,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              onTap: _cancelRecording,
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: sizes.GetHeight() * 3,
              ),
            ),
            // زر إرسال
            CircularButton(
              size: sizes.GetHeight() * 4,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              onTap: _sendRecording,
              child: SvgPicture.asset(
                "assets/icon/send.svg",
                height: sizes.GetHeight() * 3,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    if (_isRecording) {
      // أثناء التسجيل
      return Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        decoration: BoxDecoration(
          color: Themes().GetColor("backgroundOffWhite"),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مؤشر التسجيل
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: sizes.GetWidth() * 2),
            // عداد الوقت
            Text(
              _formatDuration(_recordDuration),
              style: TextStyle(
                fontSize: sizes.GetHeight() * 1.8,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(width: sizes.GetWidth() * 2),
            // زر إيقاف
            CircularButton(
              size: sizes.GetHeight() * 4,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              onTap: _stopRecording,
              child: Icon(
                Icons.stop,
                color: Colors.red,
                size: sizes.GetHeight() * 3,
              ),
            ),
          ],
        ),
      );
    }

    // الحالة العادية - زر المايك
    return CircularButton(
      size: sizes.GetHeight() * 7,
      backgroundColor: Themes().GetColor("backgroundLight"),
      borderColor: Colors.transparent,
      borderWidth: 0,
      onTap: _startRecording,
      child: SvgPicture.asset(
        "assets/icon/microphone.svg",
        height: sizes.GetHeight() * 3.3,
      ),
    );
  }
}