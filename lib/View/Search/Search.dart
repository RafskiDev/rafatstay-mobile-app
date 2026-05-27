import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../FilteredResults/FilteredResults.dart';
import '../Filters/Filters.dart';
import '../Payment/Payment.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import 'Search_riverpod.dart';

class Search extends ConsumerStatefulWidget  {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(Search_riverpod.notifier).fetchRecentSearches(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Search_riverpod);
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final notifier = ref.watch(Search_riverpod.notifier);

    return Scaffold(
        appBar: buildCustomAppBar(context, "Search"),
        backgroundColor: theme.GetColor("background"),
        body: ValueListenableBuilder<bool>(
            valueListenable: LoadingService.isLoading,
            builder: (context, isLoading, child) {
              return isLoading ? showLoading() : Container(
                  padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
                  child: SingleChildScrollView(
                      child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    textLanguage.GetWord('ما الذي تبحث عنه؟'),
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sizes.GetHeight() * 2),
                            Row(
                              children: [
                                Expanded(
                                  child: WidgetTextField(
                                    hintTextColor: theme.GetColor("textPrimary"),
                                    borderColor: theme.GetColor("primary"),
                                    Controller: ref.read(Search_riverpod.notifier).searchController,
                                    HintText: textLanguage.GetWord("بحث"),
                                    iconData: "assets/icon/Search.svg",
                                    iconColor: theme.GetColor("textPrimary"),
                                    Horizontal: sizes.GetWidth() * 2,
                                    focusNode: ref.read(Search_riverpod.notifier).searchNode,
                                    onFieldSubmitted: (value) async {
                                      await notifier.search(context);
                                    },
                                  ),
                                ),
                                SizedBox(width: sizes.GetWidth() * 2),
                                CircularButton(
                                  borderColor: theme.GetColor("primary"),
                                  size: Sizes(context).GetWidth() * 13,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1, animation2) => Filters(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  },
                                  child: SvgPicture.asset("assets/icon/Filters.svg"),
                                )
                              ],
                            ),
                            SizedBox(height: sizes.GetHeight() * 2),
                            if (notifier.searchResults.isEmpty)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      textLanguage.GetWord('عمليات البحث الأخيرة'),
                                      style: TextStyle(color: theme.GetColor("textSecondary")),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (notifier.isSearching && notifier.searchResults.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: Text(
                                    textLanguage.GetWord("لا توجد بيانات تم العثور عليها"),
                                    style: TextStyle(
                                      color: theme.GetColor("textSecondary"),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            if (notifier.recentSearches.isNotEmpty &&
                                notifier.searchResults.isEmpty &&
                                !notifier.isSearching)
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: notifier.recentSearches.length,
                                itemBuilder: (_, index) {
                                  final item = notifier.recentSearches[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // تم استخدام Expanded هنا لحماية النص الطويل عند الضغط عليه
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              final notifier = ref.read(Search_riverpod.notifier);
                                              String searchText = item["name"] ?? item["query"] ?? "";
                                              final restaurantData = await notifier.checkRestaurantAvailability(context, searchText);
                                              if (restaurantData != null) {
                                                if (context.mounted) {
                                                  await Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (_, __, ___) => RestaurantDetalis(
                                                        title: (restaurantData["business_name"] ?? restaurantData["name"]).toString(),
                                                        branchId: restaurantData["business_id"],
                                                      ),
                                                      transitionDuration: Duration.zero,
                                                      reverseTransitionDuration: Duration.zero,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ToastMessages(
                                                  context,
                                                  textLanguage.GetWord("عذراً، هذا المطعم غير متوفر"),
                                                  theme.GetColor("error"),
                                                  theme.GetColor("white"),
                                                );
                                                await notifier.deleteRecentSearch(item["id"], context);
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/icon/search_history.svg",
                                                  height: sizes.GetHeight() * 2.2,
                                                ),
                                                SizedBox(width: sizes.GetWidth() * 1),
                                                // تم إضافة Expanded و ellipsis لحماية النص الداخلي
                                                Expanded(
                                                  child: Text(
                                                    item["query"] ?? "",
                                                    style: TextStyle(color: theme.GetColor("textSecondary")),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: sizes.GetWidth() * 2), // مسافة أمان تفصل النص عن زر الحذف
                                        InkWell(
                                          onTap: () {
                                            ref.read(Search_riverpod.notifier).deleteRecentSearch(item["id"], context);
                                          },
                                          child: SvgPicture.asset(
                                            "assets/icon/delete.svg",
                                            height: sizes.GetHeight() * 2.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            if (notifier.searchResults.isNotEmpty)
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: notifier.searchResults.length,
                                itemBuilder: (_, index) {
                                  final item = notifier.searchResults[index];
                                  return InkWell(
                                    onTap: () async {
                                      final branchId = item["business_id"];
                                      print(branchId);
                                      final title = (item["business_name"] ?? item["name"]).toString();
                                      await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => RestaurantDetalis(
                                            title: title,
                                            branchId: branchId,
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration: Duration.zero,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // حماية نتائج البحث الحالية من الخروج عن الحدود
                                          Expanded(
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/icon/search_history.svg",
                                                  height: sizes.GetHeight() * 2.2,
                                                ),
                                                SizedBox(width: sizes.GetWidth() * 1),
                                                Expanded(
                                                  child: Text(
                                                    item["name"] ?? "",
                                                    style: TextStyle(color: theme.GetColor("textSecondary")),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ]
                      )
                  )
              );
            }
        )
    );
  }
}