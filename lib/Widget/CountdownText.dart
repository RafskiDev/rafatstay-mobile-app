import 'package:flutter/material.dart';
import 'dart:async';
import '../Utils/DateTimeHelper.dart';
class CountdownText extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const CountdownText({required this.bookingData});

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(DateTimeHelper().getRemainingTime(widget.bookingData));
  }
}

class CountdownSeconds extends StatefulWidget {
  final int countdownSeconds;

  const CountdownSeconds({super.key, required this.countdownSeconds});

  @override
  State<CountdownSeconds> createState() => _CountdownSecondsState();
}

class _CountdownSecondsState extends State<CountdownSeconds> {
  Timer? _timer;
  late int _currentSeconds;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.countdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return "00D : 00H : 00M";

    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (days > 0) {
      return "${days.toString().padLeft(2, '0')}D : ${hours.toString().padLeft(2, '0')}H : ${minutes.toString().padLeft(2, '0')}M";
    }
    return "${hours.toString().padLeft(2, '0')}H : ${minutes.toString().padLeft(2, '0')}M : ${seconds.toString().padLeft(2, '0')}S";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_currentSeconds),
    );
  }
}