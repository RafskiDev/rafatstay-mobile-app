import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  List<Map<String, dynamic>> restaurant = [
      {'label': 'Attitude',          'score': 5, 'max': 5},
      {'label': 'Attention to Detail','score': 3, 'max': 5},
      {'label': 'Professionalism',   'score': 4, 'max': 5},
   ];
  List<Map<String, dynamic>> service = [
    {'label': 'Food Quality',          'score': 5, 'max': 5},
    {'label': 'Service Speed','score': 3, 'max': 5},
    {'label': 'Staff Behavior',   'score': 4, 'max': 5},
  ];


  @override
  int build() => 0;

}
final HistoryDescription_rverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
