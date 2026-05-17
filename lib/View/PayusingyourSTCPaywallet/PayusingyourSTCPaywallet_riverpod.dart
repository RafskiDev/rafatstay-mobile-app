import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController STCPay = TextEditingController();
  final STCPayNode = FocusNode();

  @override
  int build() {
    return 0;
  }



}

final PayusingyourSTCPaywallet_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);