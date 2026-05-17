import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../FilteredResults/FilteredResults.dart';
import 'Filters_riverpod.dart';
class Filters extends ConsumerStatefulWidget {
  const Filters({super.key});

  @override
  ConsumerState<Filters> createState() => _FiltersState();
}

class _FiltersState extends ConsumerState<Filters> {
  @override
  void initState() {
    super.initState();
    // استدعاء الفلاتر مرة واحدة فقط بعد تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(Filters_riverpod.notifier).getSearchFilters(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Filters_riverpod);
    final notifier = ref.watch(Filters_riverpod.notifier);
    final sizes = Sizes(context);
    final theme = Themes();
    return Scaffold(
      appBar: buildCustomAppBar(context,TextLanguage().GetWord('الفلاتر'), showNotification: false),
      backgroundColor: theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          return isLoading?showLoading(): SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(TextLanguage().GetWord('مطبخ'),
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: sizes.GetHeight() * 2),
                  SizedBox(
                    height: sizes.GetHeight() * 5,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: notifier.cuisines.length,
                      itemBuilder: (context, index) {
                        final item = notifier.cuisines[index];
                        final isSelected = notifier.isCuisineSelected(
                            item["key"]);
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: sizes.GetWidth() * 1),
                          child: SquareButton(
                            width: sizes.GetWidth() * 25,
                            height: sizes.GetHeight() * 5,
                            backgroundColor: isSelected
                                ? theme.GetColor("primaryA")
                                : theme.GetColor("background"),
                            borderColor: theme.GetColor("textSecondary"),
                            borderRadius: sizes.GetHeight() * 10,
                            onTap: () {
                              notifier.toggleCuisine(item["key"]);
                            },
                            child: Text(item["label"] ?? item["title"],
                                style: TextStyle(
                                    color: theme.GetColor("textPrimary"))),
                          ),
                        );
                      },
                    ),
                  ),

                  // Ratings
                  SizedBox(height: sizes.GetHeight() * 3),
                  Text(TextLanguage().GetWord('تصنيف'),
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: sizes.GetHeight() * 2),
                  SizedBox(
                    height: sizes.GetHeight() * 5,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: notifier.ratings.length,
                      itemBuilder: (context, index) {
                        final item = notifier.ratings[index];
                        final isSelected = notifier.isRatingSelected(
                            item["key"]);
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: sizes.GetWidth() * 1),
                          child: SquareButton(
                            width: sizes.GetWidth() * 25,
                            height: sizes.GetHeight() * 5,
                            backgroundColor: isSelected
                                ? theme.GetColor("primaryA")
                                : theme.GetColor("background"),
                            borderColor: theme.GetColor("textSecondary"),
                            borderRadius: sizes.GetHeight() * 10,
                            onTap: () {
                              notifier.selectRating(item["key"]);
                            },
                            child: Text(item["label"] ?? item["title"],
                                style: TextStyle(
                                    color: theme.GetColor("textPrimary"))),
                          ),
                        );
                      },
                    ),
                  ),

                  // Area
                  SizedBox(height: sizes.GetHeight() * 3),
                  WidgetTextField(
                    Controller: notifier.searchController,
                    HintText: TextLanguage().GetWord('ادخل المنطقة'),
                    iconData: "assets/icon/area.svg",
                    Horizontal: sizes.GetWidth() * 2,
                    focusNode: notifier.searchNode,
                  ),

                  // Apply button
                  SizedBox(height: sizes.GetHeight() * 5),
                  Center(
                    child: SquareButton(
                      width: sizes.GetWidth() * 50,
                      height: sizes.GetHeight() * 6,
                      backgroundColor: theme.GetColor("primaryA"),
                      borderRadius: sizes.GetHeight() * 10,
                      onTap: () async {
                        final results = await notifier.searchWithFilters(
                            context);
                        print("Search Results: $results");
                       // Navigator.pop(context);
                        if(results!=null){

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => FilteredResults(data:results),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }

                      },
                      child: Text(
                        TextLanguage().GetWord('تطبيق الفلاتر'),
                        style: TextStyle(color: theme.GetColor("textPrimary")),
                      ),
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 3),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
