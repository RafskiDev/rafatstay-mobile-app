import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import 'RateYourExperience_riverpod.dart';
import 'Widget/Celebrate.dart';
import 'Widget/FeedbackInput.dart';
import 'Widget/evaluation.dart';
import 'Widget/personCard.dart';

class RateYourExperience extends ConsumerWidget {
  RateYourExperience({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(RateYourExperience_riverpod);
    final selectedGender = ref.watch(RateYourExperience_riverpod);
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();

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
                  Text(textLanguage.GetWord('احصل على 50 نقطة مقابل تقييمك.')),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                children: [
                  Text(
                    textLanguage.GetWord('احصل على مزايا وخصومات حصرية.'),
                    style: TextStyle(color: theme.GetColor("textSecondary")),
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),

              // ✅ overall_rating + atmosphere_rating
              Row(
                children: [Text(textLanguage.GetWord('تقييم المطعم'))],
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
                        ratings[index]["title"] as String,
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
                children: [Text("Service Rating")],
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
                        service[index]["title"] as String,
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
              FeedbackInput(context, textLanguage.GetWord('اكتب ملاحظاتك هنا…')),
              SizedBox(height: sizes.GetHeight() * 2),

              // ❌ غير مدعوم - لا يوجد endpoint لرفع الصور والفيديو
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Flexible(child: videoFeedbackCard(context, 'صورك مع الوجبة', "")),
              //     SizedBox(width: sizes.GetWidth() * 2),
              //     Flexible(child: videoFeedbackCard(context, 'أخبرنا برأيك في فيديو', "")),
              //   ],
              // ),

              // ✅ best_employee_id — موظف واحد فقط
              Row(
                children: [Text(textLanguage.GetWord('تقييم الموظفين'))],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              SizedBox(
                height: sizes.GetWidth() * 60,
                child: Consumer(
                  builder: (context, ref, child) {
                    final notifier = ref.watch(RateYourExperience_riverpod.notifier);
                    final cards = notifier.personCard;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
                          child: personCard(
                            context,
                            cards[index]["image"].toString(),
                            cards[index]["title"].toString(),
                            isSelected: notifier.selectedPersonIndexes.contains(index),
                            onTap: () => notifier.togglePersonSelection(index),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: sizes.GetHeight() * 2),

              // ❌ غير مدعوم - API لا يقبل sub-ratings للموظفين (attitude, attention to detail)
              // SizedBox(
              //   height: sizes.GetWidth() * 28,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: ref.read(RateYourExperience_riverpod.notifier).reviews.length,
              //     itemBuilder: (context, index) {
              //       final notifier = ref.read(RateYourExperience_riverpod.notifier);
              //       final review = notifier.reviews;
              //       return Padding(
              //         padding: EdgeInsets.only(right: sizes.GetWidth() * 2),
              //         child: evaluation(
              //           context,
              //           review[index]["title"] as String,
              //           review[index]["icon"] as String,
              //           review[index]["rate"] as int,
              //           (value) => notifier.updateReviewRating(index, value),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              // ✅ comment للموظف
              FeedbackInput(context, textLanguage.GetWord('شاركنا رأيك…')),
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
                        children: [Text("Would you like to add a tip?")],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      WidgetTextField(
                        backgroundColor: Themes().GetColor("backgroundOffWhite"),
                        borderColor: Themes().GetColor("secondary"),
                        Controller: ref.read(RateYourExperience_riverpod.notifier).controller,
                        focusNode: ref.read(RateYourExperience_riverpod.notifier).focusNodeController,
                        HintText: "Enter Amount",
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
                  // ✅ إرسال البيانات للـ API
                  ref.read(RateYourExperience_riverpod.notifier)
                      .submitReview(branchId: 1, context: context);
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