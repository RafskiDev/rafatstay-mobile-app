import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Account/Account.dart';
import '../Booking/Booking.dart';
import '../Favorite/Favorite.dart';
import '../Home/Home.dart';
class PageNotifier extends Notifier<int> {
  @override
  int build() => 0;
  final List<Widget> pages = [
    Home(),
    Center(child: Text("Services Page")),
    Favorite(),
    Booking(),
    Account(),
  ];
  void changePage(int index) => state = index;
}

final BottomBar_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
