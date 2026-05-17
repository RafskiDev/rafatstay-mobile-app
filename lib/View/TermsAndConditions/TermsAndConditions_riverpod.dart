import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PageNotifier extends Notifier<int> {

  @override
  int build() {
    return 0;
  }

}

final TermsAndConditions_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);