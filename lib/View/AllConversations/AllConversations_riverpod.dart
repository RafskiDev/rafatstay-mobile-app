import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, MaterialPageRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';
import '../Login/Login.dart';
class PageNotifier extends Notifier<int> {
  final storage = GetStorage();
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  List<dynamic> conversations = [];

  // ===== إضافة هذه المتغيرات =====
  int currentPage = 1;
  static const int _perPage = 10;
  bool hasMore = true;
  bool isFetchingMore = false;
  // ================================

  @override
  int build() => 0;

  Future<void> fetchConversations(BuildContext context, {bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore || isFetchingMore) return;
      isFetchingMore = true;
    } else {
      currentPage = 1;
      hasMore = true;
      conversations.clear();
    }

    final response = await ApiService().get(
      "v1/$roles/chat/conversations",
      {"per_page": "$_perPage", "page": "$currentPage"},
      context,
    );

    if (response?["success"] == true) {
      final data = response["data"];
      final items = List<dynamic>.from(data["items"] ?? []);

      if (loadMore) {
        conversations.addAll(items);
      } else {
        conversations = items;
      }

      // تحديث حالة الـ pagination
      final pagination = data["pagination"];
      if (pagination != null) {
        final int lastPage = pagination["last_page"] ?? 1;
        hasMore = currentPage < lastPage;
      } else {
        hasMore = items.length >= _perPage;
      }

      currentPage++;
    }

    isFetchingMore = false;
    ref.notifyListeners();
  }
}
final AllConversations_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
