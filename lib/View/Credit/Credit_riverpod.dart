import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
class PageNotifier extends Notifier<int> {
  final cardNumberController = TextEditingController();
  final cardNumberControllerNode = FocusNode();
  final cardholderNameController = TextEditingController();
  final cardholderNameControllerNode = FocusNode();
  final cVVController = TextEditingController();
  final cVVControllerNode = FocusNode();
  final expiryDateController = TextEditingController();
  final expiryDateControllerNode = FocusNode();
  bool agree = false;

  @override
  int build() {
    return 0;
  }
}

final Credit_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);