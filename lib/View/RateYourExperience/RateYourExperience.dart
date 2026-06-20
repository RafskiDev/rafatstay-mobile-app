import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
import 'RateYourExperience_riverpod.dart';
import 'Widget/Celebrate.dart';
import 'Widget/FeedbackInput.dart';
import 'Widget/evaluation.dart';
import 'Widget/personCard.dart';
import 'Widget/videoFeedbackCard.dart';
class RateYourExperience extends ConsumerStatefulWidget {
final int branchId;
const RateYourExperience({super.key, required this.branchId});

  @override
  ConsumerState<RateYourExperience> createState() => _State();
}

class _State extends ConsumerState<RateYourExperience> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Future.microtask(() {
        ref.read(RateYourExperience_riverpod.notifier).resetForm();
        ref.read(RateYourExperience_riverpod.notifier)
            .loadEmployees(context, widget.branchId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(RateYourExperience_riverpod);
    final selectedGender = ref.watch(RateYourExperience_riverpod.notifier).selectedGender;
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final notifier = ref.watch(RateYourExperience_riverpod.notifier);
    return Scaffold(
      appBar: buildCustomAppBar(context, textLanguage.GetWord('قيّم تجربتك')),
      backgroundColor: theme.GetColor("background"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text(textLanguage.GetWord("احصل على 50 نقطة مقابل تقييمك.")),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                children: [
                  Text(
                    textLanguage.GetWord("احصل على مزايا وخصومات حصرية."),
                    style: TextStyle(color: theme.GetColor("textSecondary")),
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),

              // ✅ overall_rating + atmosphere_rating
              Row(
                children: [Text(textLanguage.GetWord("تقييم المطعم"))],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              SizedBox(
                height: sizes.GetWidth() * 28,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ref.read(RateYourExperience_riverpod.notifier).ratings.length,
                  itemBuilder: (context, index) {
                    final notifier = ref.read(RateYourExperience_riverpod.notifier);
                    final ratings = notifier.ratings;
                    return Padding(
                      padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                      child: evaluation(
                        context,
                        textLanguage.GetWord(ratings[index]["title"] as String),
                        ratings[index]["icon"] as String,
                        ratings[index]["rate"] as int,
                            (value) => notifier.updateRating(index, value),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              // ✅ food_rating + service_rating
              Row(
                children: [Text(TextLanguage().GetWord("تقييم الخدمة"))],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              SizedBox(
                height: sizes.GetWidth() * 28,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ref.read(RateYourExperience_riverpod.notifier).services.length,
                  itemBuilder: (context, index) {
                    final notifier = ref.read(RateYourExperience_riverpod.notifier);
                    final service = notifier.services;
                    return Padding(
                      padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                      child: evaluation(
                        context,
                        textLanguage.GetWord(service[index]["title"] as String),
                        service[index]["icon"] as String,
                        service[index]["rate"] as int,
                            (value) => notifier.updateServiceRating(index, value),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 2),

              // ✅ comment
              /*
              FeedbackInput(
                context,
                textLanguage.GetWord('اكتب ملاحظاتك هنا…'),
                controller: ref.read(RateYourExperience_riverpod.notifier).comment,
              ),

               */
              SizedBox(height: sizes.GetHeight() * 2),
              Consumer(
                builder: (context, ref, child) {
                  final notifier = ref.watch(RateYourExperience_riverpod.notifier);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notifier.selectedImage == null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => notifier.pickMedia(context),
                              child: videoFeedbackCard(context,textLanguage.GetWord("صورك مع الوجبة"), ""),
                            ),
                          ],
                        )
                      else
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                notifier.selectedImage!,
                                width: sizes.GetWidth() * 96,
                                height: sizes.GetHeight() * 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => notifier.removeMedia(0),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Themes().GetColor("error"),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close, size: 20,
                                      color: Themes().GetColor("white")),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
              // ✅ best_employee_id — موظف واحد فقط
              if (notifier.employeeList.isNotEmpty)...[
                Row(
                  children: [Text(textLanguage.GetWord("تقييم الموظفين"))],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
              ],
              Consumer(
                builder: (context, ref, child) {
                  final cards = notifier.employeeList;
                  if (cards.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      SizedBox(
                        height: sizes.GetWidth() * 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                              child: personCard(
                                context,
                                cards[index]["avatar_url"]??"",
                                cards[index]["name"]?.toString() ?? "",
                                isSelected: notifier.selectedPersonIndexes.contains(index),
                                onTap: () => notifier.togglePersonSelection(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: sizes.GetHeight() * 2),

               SizedBox(
                 height: sizes.GetWidth() * 28,
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: ref.read(RateYourExperience_riverpod.notifier).reviews.length,
                   itemBuilder: (context, index) {
                     final notifier = ref.read(RateYourExperience_riverpod.notifier);
                     final review = notifier.reviews;
                     return Padding(
                       padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                       child: evaluation(
                         context,
                         textLanguage.GetWord(review[index]["title"] as String),
                         review[index]["icon"] as String,
                         review[index]["rate"] as int,
                         (value) => notifier.updateReviewRating(index, value),
                       ),
                     );
                   },
                 ),
               ),
              SizedBox(height: sizes.GetHeight() * 2),
              // ✅ comment للموظف
              FeedbackInput(
                context,
                textLanguage.GetWord("شاركنا رأيك…"),
                controller: ref.read(RateYourExperience_riverpod.notifier).comment,
              ),
              SizedBox(height: sizes.GetHeight() * 2),

              // ✅ tip_amount
              Container(
                width: sizes.GetWidth() * 100,
                height: sizes.GetHeight() * 15,
                decoration: BoxDecoration(
                  color: theme.GetColor("backgroundOffWhite"),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.GetColor("textSecondary"), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [Text(TextLanguage().GetWord("هل ترغب في إضافة إكرامية؟"))],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      WidgetTextField(
                        backgroundColor: Themes().GetColor("backgroundOffWhite"),
                        borderColor: Themes().GetColor("secondary"),
                        Controller: ref.read(RateYourExperience_riverpod.notifier).controller,
                        focusNode: ref.read(RateYourExperience_riverpod.notifier).focusNodeController,
                        HintText:TextLanguage().GetWord('أدخل المبلغ'),
                        keyboardType: TextInputType.number,
                        iconData: 'assets/icon/LikePrice.svg',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 2),

              // ✅ birthday + gender
              celebrate(context, ref, selectedGender),
              SizedBox(height: sizes.GetHeight() * 2),

              WidgetButton(
                width: sizes.GetWidth() * 45,
                isCircular: true,
                context: context,
                buttonText: textLanguage.GetWord('إرسال التقييم'),
                textColor: Themes().GetColor("textPrimary"),
                onPressed: () {
                  ref.read(RateYourExperience_riverpod.notifier)
                      .submitReview(branchId: widget.branchId, context: context);
                },
                backgroundColor: Themes().GetColor("primaryA"),
              ),
              SizedBox(height: sizes.GetHeight() * 6),
            ],
          ),
        ),
      ),
    );
  }
}


