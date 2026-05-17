// lib/Service/LoadingService.dart
import 'package:flutter/material.dart';
class LoadingService {
  // 🟢 ValueNotifier بدلاً من Provider
  static final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  static void show() {
    isLoading.value = true;
  }

  static void hide() {
    isLoading.value = false;
  }
}