import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/View/Payment/Payment.dart';
import '../../Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CarouselIndicator.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../MakeItYourWay/MakeItYourWay.dart';
import 'MealDetails_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
class MealDetails extends ConsumerStatefulWidget {
  final String title;
  final String image;
  final int menuItemId; // ← أضف هذا
  const MealDetails({super.key, required this.title, required this.image, required this.menuItemId});

  @override
  ConsumerState<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends ConsumerState<MealDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(MealDetails_riverpod.notifier).fetchMealDetails(context, widget.menuItemId);
      await ref.read(MealDetails_riverpod.notifier).branch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
     ref.watch(MealDetails_riverpod);
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final items=ref.watch(MealDetails_riverpod.notifier).meals;
    if (items.isEmpty) return Container();
    final currentIndex = ref.watch(MealDetails_riverpod.notifier).currentIndex;
    final slecteds=ref.read(MealDetails_riverpod.notifier).slected;
     final mealData = ref.watch(MealDetails_riverpod.notifier).mealData;
     final protein = (mealData?["protein"] as num?)?.toDouble() ?? 0;
     final carbs = (mealData?["carbs"] as num?)?.toDouble() ?? 0;
     final fats = (mealData?["fats"] as num?)?.toDouble() ?? 0;
     final total = protein + carbs + fats;
     final allergens = mealData?["allergens"] as List? ?? [];
     final branches = ref.watch(MealDetails_riverpod.notifier).branches;
     final photos = branches.isNotEmpty
         ? List.from(branches[0]['photos'] ?? [])
         : [];
     return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
          valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            return isLoading
                ? showLoading(): SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(sizes.GetHeight() * 3),
                          bottomRight:Radius.circular(sizes.GetHeight() * 3),
                        ),
                        child: CarouselSlider(
                          items: photos.map((photo) {
                            final imageUrl = photo['url'];
                            return Image.network(
                              "$showImage$imageUrl", // ← عدل الدومين هنا
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: Center(child: Icon(Icons.broken_image)),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: sizes.GetHeight() * 35,
                            viewportFraction: 1.0,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              ref
                                  .read(MealDetails_riverpod.notifier)
                                  .changePage(index);
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: sizes.GetHeight() * 4,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: sizes.GetWidth() * 4,
                          ),
                          child: GlassAppBar(
                            onBack: () => Navigator.pop(context),
                            onNotification: () {

                            },
                            titel:widget.title,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  CarouselIndicator(
                    itemCount:photos.length,
                    currentIndex: currentIndex,
                    activeColor:theme.GetColor("secondary500"),
                    inactiveColor:theme.GetColor("primaryS"),
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SquareButton(
                                  width: sizes.GetWidth()*25,
                                  height: Sizes(context).GetHeight()*5.5,
                                  backgroundColor:Themes().GetColor("secondary"),
                                  borderRadius:sizes.GetWidth()*10,
                                  onTap: () {
                                    print('تم الضغط على الزر');
                                  },
                                  child:Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icon/Kcal.svg"),
                                      SizedBox(width: Sizes(context).GetWidth()*1),
                                      Text(
                                        '${mealData?["calories"]} ${textLanguage.GetWord("سعرات حرارية")}',
                                        style: TextStyle(
                                          color:Themes().GetColor("textPrimary"),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              SquareButton(
                                  width: sizes.GetWidth()*30,
                                  height: Sizes(context).GetHeight()*5.5,
                                  backgroundColor:Themes().GetColor("secondary"),
                                  borderRadius: Sizes(context).GetWidth()*10,
                                  onTap: () {
                                    print('تم الضغط على الزر');
                                  },
                                  child:Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icon/MealTime.svg"),
                                      SizedBox(width: Sizes(context).GetWidth()*1),
                                      Text(
                                        mealTimeText(mealData, textLanguage),
                                        style: TextStyle(
                                          color:Themes().GetColor("textPrimary"),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              SquareButton(
                                  width: sizes.GetWidth()*30,
                                  height: Sizes(context).GetHeight()*5.5,
                                  backgroundColor:Themes().GetColor("secondary"),
                                  borderRadius: Sizes(context).GetWidth()*10,
                                  onTap: () {
                                    print('تم الضغط على الزر');
                                  },
                                  child:Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icon/serves.svg"),
                                      SizedBox(width: Sizes(context).GetWidth()*1),
                                      Text(
                                        mealData?["serves"]?.toString() ??textLanguage.GetWord("الخدمات"),
                                        style: TextStyle(
                                          color:Themes().GetColor("textPrimary"),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NutrientCard(
                                label:textLanguage.GetWord('البروتينات'),
                                percentage: total > 0 ? (protein / total).clamp(0.0, 1.0) : 0,
                                weight: '${protein.toInt()} g',
                                primaryColor: Themes().GetColor('secondaryPrimary'),
                              ),
                              SizedBox(width: sizes.GetWidth() * 2),
                              NutrientCard(
                                label:textLanguage.GetWord('الكربوهيدرات'),
                                percentage: total > 0 ? (carbs / total).clamp(0.0, 1.0) : 0,
                                weight: '${carbs.toInt()} g',
                                primaryColor: Themes().GetColor('secondaryPrimary'),
                              ),
                              SizedBox(width: sizes.GetWidth() * 2),
                              NutrientCard(
                                label:textLanguage.GetWord('الدهون'),
                                percentage: total > 0 ? (fats / total).clamp(0.0, 1.0) : 0,
                                weight: '${fats.toInt()} g',
                                primaryColor: Themes().GetColor('secondaryPrimary'),
                              ),
                              SizedBox(width: sizes.GetWidth() * 2),
                              NutrientCard(
                                label:textLanguage.GetWord("مسببات الحساسية"),
                                percentage: allergenPercentage(allergens),
                                weight: allergenText(allergens, textLanguage),
                                primaryColor: Themes().GetColor('secondaryPrimary'),
                              ),
                            ],
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          Container(
                            width:double.infinity,
                            height:sizes.GetHeight()*6,
                            decoration:BoxDecoration(
                              color:Themes().GetColor("secondary"),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ref.read(MealDetails_riverpod.notifier).changeSelected(0);
                                  },
                                  child: Text(
                                    textLanguage.GetWord("وصف"),
                                    style: TextStyle(
                                      color: slecteds == 0
                                          ? Themes().GetColor("textPrimary")
                                          : Themes().GetColor("secondaryPrimary"),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    ref.read(MealDetails_riverpod.notifier).changeSelected(1);
                                  },
                                  child: Text(
                                    textLanguage.GetWord("مكونات"),
                                    style: TextStyle(
                                      color: slecteds == 1
                                          ? Themes().GetColor("textPrimary")
                                          : Themes().GetColor("secondaryPrimary"),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    ref.read(MealDetails_riverpod.notifier).changeSelected(2);
                                  },
                                  child: Text(
                                    textLanguage.GetWord('تعليمات'),
                                    style: TextStyle(
                                      color: slecteds == 2
                                          ? Themes().GetColor("textPrimary")
                                          : Themes().GetColor("secondaryPrimary"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sizes.GetHeight() * 2),
                          ref.watch(MealDetails_riverpod.notifier).slected == 0?Description(ref:ref,):Container(),
                          ref.watch(MealDetails_riverpod.notifier).slected == 1?Ingredients(ref:ref,):Container(),
                          ref.watch(MealDetails_riverpod.notifier).slected == 2?Instructions():Container(),
                          SizedBox(height: sizes.GetHeight() * 2),
                          SquareButton(
                              width: sizes.GetWidth()*50,
                              height: Sizes(context).GetHeight()*5.5,
                              backgroundColor:Themes().GetColor("primaryA"),
                              borderRadius:sizes.GetWidth()*10,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1, animation2) =>
                                        Payment(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                                print('تم الضغط على الزر');
                              },
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    textLanguage.GetWord("اطلب الآن"),
                                    style: TextStyle(
                                      color:Themes().GetColor("textPrimary"),
                                    ),
                                  ),
                                  SizedBox(width: Sizes(context).GetWidth()*1),
                                  SvgPicture.asset("assets/icon/arrow.svg"),
                                ],
                              )
                          ),
                        ],
                      )
                  ),
                ],
              ),
            );
          }

      )
    );
  }
  double allergenPercentage(List allergens) {
    const maxAllergens = 8;
    if (allergens.isEmpty) return 0;

    return (allergens.length / maxAllergens).clamp(0.0, 1.0);
  }
  String allergenText(List allergens, TextLanguage lang) {
    if (allergens.isEmpty) {
      return "0 g";
    }
    return "${allergens.length}";
  }
  String mealTimeText(Map<String, dynamic>? mealData, TextLanguage lang) {
    final prep = mealData?["prep_time_minutes"];
    final ready = mealData?["ready_time_minutes"];

    if (prep == null && ready == null) {
      return "00-00";
    }

    if (prep != null && ready != null) {
      return "$prep–$ready ${lang.GetWord('دقائق')}";
    }

    final minutes = prep ?? ready;
    return "$minutes ${lang.GetWord('دقائق')}";
  }
}
class Description extends StatelessWidget {
  final WidgetRef ref;
  const Description({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    final mealData = ref.watch(MealDetails_riverpod.notifier).mealData;
    final description = mealData?["description"] ?? "";
    return  Row(
      children: [
        Expanded(child: Text(style:TextStyle(color:Themes().GetColor("textSecondary")),description)),
      ],
    );
  }
}
class Ingredients extends StatelessWidget {
  final WidgetRef ref;

  const Ingredients({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    final mealData = ref.watch(MealDetails_riverpod.notifier).mealData;

    final ingredients = List<String>.from(mealData?["ingredients"] ?? []);

    final sizes = Sizes(context);

    if (ingredients.isEmpty) {
      return SizedBox.shrink();
    }

    return Row(
      children: ingredients.map((ing) {
        return Padding(
          padding: EdgeInsets.only(right: sizes.GetWidth()*2),
          child: FoodItemCard(
            label: ing,
            weight: '',
            imageTitle: "assets/icon/SpaghettiPasta.svg",
            imageSubTitle: "assets/icon/kitchenScale.svg",
          ),
        );
      }).toList(),
    );
  }
}
class Instructions extends ConsumerWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructions = ref.watch(MealDetails_riverpod.notifier).mealData?["instructions"] ?? "";

    if (instructions.isEmpty) {
      return SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            instructions,
            style: TextStyle(color: Themes().GetColor("textSecondary")),
          ),
        ),
      ],
    );
  }
}
class NutrientCard extends StatelessWidget {
  final String label;
  final double percentage; // قيمة بين 0.0 و 1.0
  final String weight;
  final Color primaryColor;

  const NutrientCard({
    super.key,
    required this.label,
    required this.percentage,
    required this.weight,
    this.primaryColor = const Color(0xFF8B6B38),
  });

  @override
  Widget build(BuildContext context) {
    final size = Sizes(context).GetWidth() * 14;
    return Container(
      width: Sizes(context).GetWidth()*22,
      padding:  EdgeInsets.symmetric(vertical: Sizes(context).GetHeight()*1),
      decoration: BoxDecoration(
        color:Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: Sizes(context).GetWidth()*22,
            height: Sizes(context).GetHeight()*8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: size,
                        height: size,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      SizedBox(
                        width: size,
                        height: size,
                        child: CircularProgressIndicator(
                          value: percentage,
                          strokeWidth: 4,
                          backgroundColor: Colors.transparent,
                          color: primaryColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${(percentage * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2A3A), // لون أزرق غامق
                        height: 1.0,
                      ),
                    ),
                    Text(
                      weight,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primaryColor, // نفس اللون الذهبي
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height:Sizes(context).GetHeight()*1),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2A3A),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height:Sizes(context).GetHeight()*1),
        ],
      ),
    );
  }
}
class FoodItemCard extends StatelessWidget {
  final String label;
  final String weight;
  final String imageTitle;
  final Color primaryColor;
  final String imageSubTitle;


  const FoodItemCard({
    super.key,
    required this.label,
    required this.weight,
    required this.imageTitle,
    this.primaryColor = const Color(0xFF8B6B38),
    required this.imageSubTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Sizes(context).GetWidth()*22.5,
      height:Sizes(context).GetHeight()*16,
      decoration: BoxDecoration(
        color:Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         SvgPicture.asset(imageTitle,height:Sizes(context).GetHeight()*6),
         SizedBox(height: Sizes(context).GetHeight()*2),
          Text(
            label,
            textAlign: TextAlign.center,
            style:  TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color:Themes().GetColor("textPrimary"),
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight()*1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(imageSubTitle,height:Sizes(context).GetHeight()*2),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Text(
                weight,
                style:  TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color:Themes().GetColor("textPrimary"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}