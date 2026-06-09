import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../../Widget/WidgetTextField.dart';
import '../SetYourBookingDetails/SetYourBookingDetails.dart';
import 'MakeItYourWay_riverpod.dart';

class MakeItYourWay extends ConsumerStatefulWidget {
  final String title;
  final String businessName;
  final int branchId;
  final List<dynamic> selectedMeals;
  final String? bookingType;
  const MakeItYourWay({super.key, required this.title,required this.businessName,required this.branchId,required this.selectedMeals,this.bookingType});

  @override
  ConsumerState<MakeItYourWay> createState() => _MakeItYourWayState();
}

class _MakeItYourWayState extends ConsumerState<MakeItYourWay> {
  late List<Map<String, dynamic>> menuItemsLocal;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(MakeItYourWay_riverpod.notifier);
      notifier.branchId = widget.branchId;
      notifier.menuItems = List<Map<String, dynamic>>.from(widget.selectedMeals);
      notifier.refresh();

    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(MakeItYourWay_riverpod);
    final sizes = Sizes(context);
    final theme = Themes();
    final cookingTypes = ref.read(MakeItYourWay_riverpod.notifier).cookingTypes;
    final cookingTypes_ = ref.read(MakeItYourWay_riverpod.notifier).cookingTypes_;
    final selectedIds = ref.read(MakeItYourWay_riverpod.notifier).selectedIds;
    final menuItems = ref.read(MakeItYourWay_riverpod.notifier).menuItems;
    final textLanguage = TextLanguage();

    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(context,textLanguage.GetWord("اجعلها على طريقتك")),
      body:ValueListenableBuilder<bool>(
          valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) return showLoading();
            return  Container(
              padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*2),
              child:SingleChildScrollView(
                child: Column(
                  children: [
                    Text(textLanguage.GetWord("أكمل وجبتك المختارة الآن، بالطريقة التي تحبها تماماً."),style:TextStyle(color:theme.GetColor("textSecondary"),fontSize:sizes.GetHeight()*2.2)),
                    SizedBox(height: sizes.GetHeight() * 2),
                    GridView.builder(
                      padding: EdgeInsets.zero, // 🔥 مهم
                      physics: NeverScrollableScrollPhysics(), // لتجنب التمرير الداخلي إذا داخل ScrollView
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: sizes.GetWidth() * 1,
                        childAspectRatio:widget.bookingType=="eventBooking"? 0.63:0.55,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        if (index >= menuItems.length) return SizedBox();
                        final meal = menuItems[index];
                        return MealCard(
                            item: meal,
                            sizes: sizes,
                            theme: theme,
                            showCheckbox: true,
                            isSelected: selectedIds.contains(meal["id"].toString()),
                            onToggleSelect: () => ref.read(MakeItYourWay_riverpod.notifier).toggleSelection(meal["id"].toString()),
                            onTap: () {
                              ref.read(MakeItYourWay_riverpod.notifier).increaseCount(index,context,widget.branchId);
                            },
                            onTapDelete: () {
                              ref.read(MakeItYourWay_riverpod.notifier).deleteMeal(index);
                            }
                        );
                      },
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/CookingMethod.svg"),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(textLanguage.GetWord("طريقة الطهي"),style:TextStyle(fontWeight:FontWeight.bold,color:theme.GetColor("textPrimary"))),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    Row(
                      children: [
                        Text(textLanguage.GetWord("اختر طريقة الطهي المفضلة لديك"),style:TextStyle(color:theme.GetColor("textSecondary"),fontSize:sizes.GetHeight()*2.2)),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    SizedBox(
                      height:sizes.GetHeight()*5,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cookingTypes.length,
                        itemBuilder: (context, index) {
                          final isSelected = ref.read(MakeItYourWay_riverpod.notifier).isSelected(index);
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*0.5),
                            child: SquareButton(
                              borderColor:isSelected?theme.GetColor("textPrimary"):theme.GetColor("textSecondary"),
                              borderRadius: sizes.GetHeight() * 10,
                              backgroundColor:theme.GetColor("background"),
                              width: sizes.GetWidth() * 30,
                              height: sizes.GetHeight() * 5,
                              onTap: () {
                                ref.read(MakeItYourWay_riverpod.notifier).setSelectedCookingType(index);
                              },
                              child:Text(
                                cookingTypes[index],
                                style: TextStyle(
                                    color: isSelected
                                        ? theme.GetColor("textPrimary")
                                        : theme.GetColor("textSecondary")),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/DonenessLevel.svg"),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(textLanguage.GetWord("مستوى الإنجاز"),style:TextStyle(fontWeight:FontWeight.bold,color:theme.GetColor("textPrimary"),fontSize:sizes.GetHeight()*2.2)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(textLanguage.GetWord("اختر طريقة الطهي التي تفضلها"),style:TextStyle(color:theme.GetColor("textSecondary"),fontSize:sizes.GetHeight()*2.2)),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 1),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: sizes.GetWidth() * 1,
                        runSpacing: sizes.GetHeight() * 1,
                        children: List.generate(cookingTypes_.length, (index) {
                          final notifier = ref.read(MakeItYourWay_riverpod.notifier);
                          final isSelected = notifier.isSelected_(index);
                          return SquareButton(
                            borderColor: isSelected
                                ? theme.GetColor("textPrimary")
                                : theme.GetColor("textSecondary"),
                            borderRadius: sizes.GetHeight() * 10,
                            backgroundColor:theme.GetColor("background"),
                            width: sizes.GetWidth() * 30,
                            height: sizes.GetHeight() * 5,
                            onTap: () {
                              notifier.setSelectedCookingType_(index);
                            },
                            child: Text(
                              cookingTypes_[index],
                              style: TextStyle(
                                  color: isSelected
                                      ? theme.GetColor("textPrimary")
                                      : theme.GetColor("textSecondary")),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: sizes.GetHeight() * 1),
                    ReviewTextField(
                      hintText: textLanguage.GetWord("قم بإزالة المكونات التي لا تعجبك، وأضف أي تفاصيل تفضلها."),
                      controller: ref.read(MakeItYourWay_riverpod.notifier).controller,
                    ),
                    SizedBox(height: sizes.GetHeight() * 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareButton(
                          width: sizes.GetWidth()*45,
                          height: sizes.GetHeight()*5,
                          backgroundColor: theme.GetColor("primary"),
                          borderRadius: sizes.GetHeight()*5,
                          elevation: 6,
                          onTap: () async{
                            final notifier = ref.read(MakeItYourWay_riverpod.notifier);
                            final selectedIds = notifier.selectedIds;
                            bool hasCustomization = notifier.selectedCookingTypeIndex != -1 ||
                                notifier.selectedCookingTypeIndex_ != -1 ||
                                notifier.controller.text.trim().isNotEmpty;

                            if (hasCustomization && selectedIds.isEmpty) {
                              ToastMessages(context,textLanguage.GetWord("يرجى اختيار وجبة أولاً"),Themes().GetColor("error"),Themes().GetColor("white"));
                              return;
                            }
                            ref.read(MakeItYourWay_riverpod.notifier).saveCustomizationsToSelectedMeals();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    SetYourBookingDetails(branchId: widget.branchId, businessName:widget.businessName, bookingType:widget.bookingType),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text(
                                textLanguage.GetWord('يكمل'),
                              ),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Transform.flip(
                                flipX: ref.read(MakeItYourWay_riverpod.notifier).storage.read("Language") == 1,
                                child: SvgPicture.asset(
                                  "assets/icon/arrow.svg",
                                  height:sizes.GetHeight()*2.5,
                                  //  color:theme.GetColor("textSecondary"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 6),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}

void showCustomDialog(BuildContext context) {
  final textLanguage = TextLanguage();
  final theme = Themes();
  final sizes = Sizes(context);
  WidgetCustomDialog(
    backgroundColor: theme.GetColor("background"),
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/icon/OutofStock.svg",
          height: sizes.GetHeight()*20,
        ),
        SizedBox(height: sizes.GetHeight() * 2),
        Text(
          textLanguage.GetWord("عذراً، هذه الوجبة غير متوفرة حالياً. يمكنك استكشاف خيارات أخرى شهية من قائمتنا."),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}