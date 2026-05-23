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