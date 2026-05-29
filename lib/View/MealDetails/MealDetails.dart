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
import 'package:cached_network_image/cached_network_image.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
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
    // مراقبة الحالة العامة للتأكد من إعادة البناء عند تحديث البيانات
    final state = ref.watch(MealDetails_riverpod);
    final notifier = ref.watch(MealDetails_riverpod.notifier);

    final sizes = Sizes(context);
    final Themes theme = Themes();
    final TextLanguage textLanguage = TextLanguage();

    final mealData = notifier.mealData;
    final branches = notifier.branches;
    final slecteds = notifier.slected;
    final currentIndex = notifier.currentIndex;

    // التأكد من أن البيانات تم تحميلها وليست فارغة، وإلا نعرض واجهة تحميل متحركة ومريحة للمستخدم
    if (mealData == null || branches.isEmpty) {
      return Scaffold(
        backgroundColor: theme.GetColor("background"),
        body: Center(child: showLoading()),
      );
    }

    // استخراج الصور بأمان
    final List<dynamic> photos = mealData['media_paths'] ?? [];

    // حساب النسب الغذائية
    final protein = double.tryParse(mealData["protein"]?.toString().trim() ?? "") ?? 0.0;
    final carbs   = double.tryParse(mealData["carbs"]?.toString().trim()   ?? "") ?? 0.0;
    final fats    = double.tryParse(mealData["fats"]?.toString().trim()    ?? "") ?? 0.0;

    final total = protein + carbs + fats;
    const double maxGramLimit = 100.0;
    final double proteinPercent = protein / maxGramLimit;
    final double carbsPercent   = carbs / maxGramLimit;
    final double fatsPercent    = fats / maxGramLimit;
    final allergens = mealData["allergens"] as List? ?? [];
     return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
          valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            return isLoading
                ? showLoading(): SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(sizes.GetHeight() * 3),
                            bottomRight:Radius.circular(sizes.GetHeight() * 3),
                          ),
                          child: photos.isNotEmpty ? CarouselSlider(
                            items: photos.map((photoUrl) {
                              return CachedNetworkImage(
                                imageUrl: photoUrl.toString(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>  Center(
                                  child:showLoading(),
                                ),
                                //ضفت هذا حتى لا يطبع الخطا
                                errorListener: (dynamic exception) {
                                },
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: double.infinity,
                                    height: sizes.GetHeight() * 14,
                                    color: const Color(0xFFEEEEEE),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
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
                          ):Container(
                            height: sizes.GetHeight() * 35,
                            width: double.infinity,
                            color:theme.GetColor("background"),
                            child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          top: sizes.GetHeight() * 0,
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
                                          '${mealData["calories"]??0} ${textLanguage.GetWord("سعرات حرارية")}',
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
                                  percentage:proteinPercent.clamp(0.0, 1.0),
                                  weight: '${protein.toInt()} g',
                                  primaryColor: Themes().GetColor('secondaryPrimary'),
                                ),
                                SizedBox(width: sizes.GetWidth() * 2),
                                NutrientCard(
                                  label:textLanguage.GetWord('الكربوهيدرات'),
                                  percentage: carbsPercent.clamp(0.0, 1.0), // ستظهر 0% لأن الوزن 0g
                                  weight: '${carbs.toInt()} g',
                                  primaryColor: Themes().GetColor('secondaryPrimary'),
                                ),
                                SizedBox(width: sizes.GetWidth() * 2),
                                NutrientCard(
                                  label:textLanguage.GetWord('الدهون'),
                                  percentage: fatsPercent.clamp(0.0, 1.0), // ستظهر 0% لأن الوزن 0g
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
                                  final branchId = branches[0]["id"];
                                  final branchName = branches[0]["name"]??"";
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                          RestaurantDetalis(title:branchName, branchId:branchId,),
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
              ),
            );
          }

      )
    );
  }
  double allergenPercentage(List allergens) {
    const maxAllergens = 12;
    if (allergens.isEmpty) return 0.0;

    // الحساب الفعلي للنسبة بشكل مرن
    final double calculatedProgress = allergens.length / maxAllergens;

    // نضمن بقاء القيمة محصورة بين 0% و 85% كحد أقصى مريح للعين ولا تقفل الدائرة بالكامل
    return calculatedProgress.clamp(0.0, 0.85);
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
    final description = mealData?["description"] ?? "لا يوجد وصف متاح لهذا العنصر حالياً.";
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

    if (ingredients.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: sizes.GetHeight() * 15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: sizes.GetWidth() * 1.5),
            child: FoodItemCard(
              label: ingredients[index],
              weight: '',
              imageTitle: "assets/icon/SpaghettiPasta.svg",
              imageSubTitle: "assets/icon/kitchenScale.svg",
            ),
          );
        },
      ),
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
                      "${100}%",
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
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Themes().GetColor("textPrimary")
              ),
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