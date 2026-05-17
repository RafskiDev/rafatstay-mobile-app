import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:image_picker/image_picker.dart';

class PageNotifier extends Notifier<int> {
  Timer? timer;

  @override
  int build() {
    return 0;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state++;
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
    state = 0;
  }
  String get formattedTime {
    final minutes = (state ~/ 60).toString().padLeft(2, '0');
    final seconds = (state % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}

final Call_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);