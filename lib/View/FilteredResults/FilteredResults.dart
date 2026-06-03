import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/WidgetAppBar.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import 'FilteredResults_riverpod.dart';

class FilteredResults extends ConsumerStatefulWidget {
  final List<dynamic> data;

  const FilteredResults({super.key, required this.data});

  @override
  ConsumerState<FilteredResults> createState() => _FilteredResultsState();
}

class _FilteredResultsState extends ConsumerState<FilteredResults> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final List<Map<String, dynamic>> initialData = [];

      for (var item in widget.data) {
        // ✅ تم تعديله ليكون فحصاً مرناً (is Map) ليتوافق مع بيانات السيرفر بأمان
        if (item is Map) {
          initialData.add(Map<String, dynamic>.from(item));
        }
      }

      final notifier = ref.read(filteredResultsProvider.notifier);
      notifier.setData(initialData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();

    final allData = ref.watch(filteredResultsProvider);

    return Scaffold(
      appBar: buildCustomAppBar(context, textLanguage.GetWord("نتائج مُفلترة")),
      backgroundColor: theme.GetColor("background"),
      body: allData.isEmpty
          ? Center(
        child: Text(
          textLanguage.GetWord("لا توجد بيانات"),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.GetColor("textSecondary"),
          ),
        ),
      )
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(sizes.GetWidth() * 2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: Sizes(context).GetHeight() * 37.2,
              crossAxisSpacing: Sizes(context).GetWidth() * 1,
              mainAxisSpacing: Sizes(context).GetHeight() * 1,
            ),
            itemCount: allData.length,
            itemBuilder: (context, i) {
              final item = allData[i];
              print(item);
              return Padding(
                padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                child: ContentCard(
                  borderColor: theme.GetColor("success"),
                  additionalInfo: Column(

                    children: [

                      SizedBox(height: sizes.GetHeight() * 3),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icon/site.svg",
                            height: sizes.GetHeight() * 1.7,
                          ),
                          SizedBox(width: sizes.GetWidth() * 0.4),
                          Flexible(
                            child: Text(
                              item["distance_km"] ?? "KM 0",
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: sizes.GetWidth() * 1.5),
                          SvgPicture.asset(
                            "assets/icon/time.svg",
                            height: sizes.GetHeight() * 1.7,
                            // ✅ تم إزالة color: Colors.transparent لتبدو طبيعية
                          ),
                          SizedBox(width: sizes.GetWidth() * 0.4),
                          Text(
                            item["eta_minutes"] ?? "KM 0",
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                   //   SizedBox(height: sizes.GetHeight() * 1), // مسافة في الأسفل
                    ],
                  ),

                  showIcon: true,
                  imagePath: "assets/images/image6.png",
                  title: item["business_name"] ?? "بدون عنوان",
                  description: item["description"] ?? " ",
                  circleImagePath: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                  buttonText: textLanguage.GetWord("يكتشف"),
                  onButtonTap: () {
                    final branchId = item["id"];
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            RestaurantDetalis(
                              title: item["business_name"] ?? "بدون عنوان",
                              branchId: branchId,
                            ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  width: sizes.GetWidth() * 50,
                  height: sizes.GetHeight() * 38,

                  // 👑 التعديل المطلوب: تم ربطها بـ is_favorited القادمة من الـ API مالتك مباشرة
                  liked: item["is_favorited"] ?? item["liked"] ?? false,

                  onLikeTap: () {
                    ref
                        .read(filteredResultsProvider.notifier)
                        .toggleFavorite(i, context);
                  },
                  menuItemId: item['id'],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}