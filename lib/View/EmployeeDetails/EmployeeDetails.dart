import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Widget/ReviewCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import 'EmployeeDetails_riverpod.dart';

class EmployeeDetails extends ConsumerStatefulWidget {
  final int branchId;
  final List<Map<String, dynamic>> employeeDetails;

  const EmployeeDetails({
    super.key,
    required this.branchId,
    required this.employeeDetails,
  });

  @override
  ConsumerState<EmployeeDetails> createState() => _EmployeeDetails();
}

class _EmployeeDetails extends ConsumerState<EmployeeDetails> {
  late Themes theme;
  late Sizes sizes;
  late TextLanguage textLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(EmployeeDetails_riverpod.notifier).fetchReviews(
        context,
        widget.branchId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Themes();
    sizes = Sizes(context);
    textLanguage = TextLanguage();
    ref.watch(EmployeeDetails_riverpod);
    final reviewNotifier = ref.read(EmployeeDetails_riverpod.notifier);
    final reviews = ref.watch(EmployeeDetails_riverpod.notifier).reviews;
    final highlights = List<String>.from(
      widget.employeeDetails[0]["highlights"] ?? [],
    );

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar: buildCustomAppBar(
        context,
        widget.employeeDetails[0]["name"] ?? "",
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        child: SingleChildScrollView(
          child: ValueListenableBuilder<bool>(
            valueListenable: LoadingService.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return  showLoading();
              }
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  // --- Buttons Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoButton(
                        iconPath: "assets/icon/ExecutiveChef.svg",
                        label: widget.employeeDetails[0]["title"] ?? "",
                      ),
                      _buildInfoButton(
                        iconPath: "assets/icon/Since.svg",
                        label:
                        "${textLanguage.GetWord("منذ")} ${widget.employeeDetails[0]["joined_year"] ?? ""}",
                      ),
                      _buildInfoButton(
                        iconPath: "assets/icon/stars.svg",
                        label:
                        "${widget.employeeDetails[0]["rating"] ?? ""}( ${widget.employeeDetails[0]["reviews_count"] ?? ""} ${textLanguage.GetWord("مستخدم")})",
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  // --- About ---
                  _buildSection(
                    iconPath: "assets/icon/ApplesinChina.svg",
                    title: textLanguage.GetWord("حول"),
                    content:widget.employeeDetails[0]["bio"].toString(),
                  ),
                  // --- Availability ---
                  _buildSection(
                    iconPath: "assets/icon/Availability.svg",
                    title: textLanguage.GetWord("التوافر"),
                    textColor: theme.GetColor("primaryA"),
                    content2:textLanguage.GetWord("متوفر خلال الساعات التالية"),
                    content:
                    "\n${widget.employeeDetails[0]["availability_days"].toString()} | ${widget.employeeDetails[0]["availability_start"].toString()} – ${widget.employeeDetails[0]["availability_end"].toString()}",
                  ),
                  // --- Highlights ---
                  _buildSection(
                    iconPath: "assets/icon/Highlights.svg",
                    title: textLanguage.GetWord("أبرز النقاط"),
                    contentWidgets: [
                      Column(
                        children: List.generate(
                          (highlights.length / 2).ceil(),
                              (rowIndex) {
                            final firstIndex = rowIndex * 2;
                            final secondIndex = firstIndex + 1;
                            return Padding(
                              padding: EdgeInsets.only(bottom: sizes.GetHeight() * 1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (firstIndex < highlights.length)
                                    _buildHighlight(
                                      iconPath: getHighlightIcon(highlights[firstIndex]),
                                      text: highlights[firstIndex],
                                    ),
                                  if (secondIndex < highlights.length)
                                    _buildHighlight(
                                      iconPath: getHighlightIcon(highlights[secondIndex]),
                                      text: highlights[secondIndex],
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 2),
                  // --- Reviews List ---
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icon/Reviews.svg",
                        height: sizes.GetHeight() * 1.8,
                        color: theme.GetColor("textPrimary"),
                      ),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(
                        textLanguage.GetWord("التقييمات"),
                        style: TextStyle(
                            color: theme.GetColor("textPrimary"),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 1),
                  SizedBox(
                   // height: sizes.GetHeight() * 60,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        String time = DateTimeHelper.extractTime(review["created_at"] ?? "");
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: sizes.GetHeight() * 0.5),
                          child: ReviewCard(
                            name: review["user"]?["full_name"] ?? "Anonymous",
                            date: time,
                            rating: review["overall_rating"] ?? 0,
                            comment: review["comment"] ?? "",
                            image:
                            "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                            sizes: sizes,
                            theme: theme,
                            onAvatarTap: () {
                              print(
                                  "Tapped on avatar of ${review["user"]?["full_name"]}");
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Rate Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rate the Chef's Service",
                        style: TextStyle(
                          color: theme.GetColor("primary"),
                          fontWeight: FontWeight.bold,
                          fontSize: sizes.GetHeight() * 2,
                        ),
                      ),
                      SizedBox(height: sizes.GetHeight() * 1.5),
                      SizedBox(
                        height: sizes.GetHeight() * 14,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildRatingCard(
                              label: "Attitude",
                              iconPath: "assets/icon/Attitude.svg",
                              rating: reviewNotifier.attitudeRating,
                              onRate: (val) => setState(() => reviewNotifier.attitudeRating = val),
                            ),
                            SizedBox(width: sizes.GetWidth() * 3),
                            _buildRatingCard(
                              label: "Attention to Detail",
                              iconPath: "assets/icon/AttentionToDetail.svg",
                              rating: reviewNotifier.attentionRating,
                              onRate: (val) => setState(() => reviewNotifier.attentionRating = val),
                            ),
                            SizedBox(width: sizes.GetWidth() * 3),
                            _buildRatingCard(
                              label: "Professionalism",
                              iconPath: "assets/icon/Professionalism.svg",
                              rating: reviewNotifier.professionalism,
                              onRate: (val) => setState(() => reviewNotifier.professionalism = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 1),
                  ReviewTextField(
                    onTop: () async {
                      await reviewNotifier.addReviewSimple(
                        context: context,
                        branchId: widget.branchId,
                        comment: reviewNotifier.reviewController.text,
                        professionalism: reviewNotifier.professionalism,
                        attitudeRating: reviewNotifier.attitudeRating,
                        attentionRating: reviewNotifier.attentionRating,
                      );
                      reviewNotifier.professionalism=0;
                      reviewNotifier.attitudeRating=0;
                      reviewNotifier.attentionRating=0;
                    },
                    hintText: textLanguage.GetWord("اكتب تقييمك"),
                    controller: reviewNotifier.reviewController,
                  ),
                  SizedBox(height: sizes.GetHeight() * 6),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
  String getHighlightIcon(String text) {
    switch (text) {
      case "خدمة ممتازة":
        return "assets/icon/ExcellentService.svg";
      case "يتحدث 3 لغات":
        return "assets/icon/ProfessionalAttitude.svg";
      case "سرعة الاستجابة":
        return "assets/icon/FastResponse.svg";
      default:
        return "assets/icon/Innovation.svg";
    }
  }
  // --- Helpers ---
  Widget _buildInfoButton({required String iconPath, required String label}) {
    return SquareButton(
      width: sizes.GetWidth() * 30,
      height: sizes.GetHeight() * 5,
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            height: sizes.GetHeight() * 1.8,
            color: theme.GetColor("textPrimary"),
          ),
          SizedBox(width: sizes.GetWidth() * 1),
          Text(
            label,
            style: TextStyle(color: theme.GetColor("textPrimary"), fontSize: 13),
          ),
        ],
      ),
      backgroundColor: theme.GetColor("iconActive"),
      borderRadius: sizes.GetWidth() * 5,
      elevation: 4,
    );
  }

  Widget _buildSection(
      {required String iconPath,
        required String title,
        String? content,
        String? content2,
        Color? textColor,
        List<Widget>? contentWidgets}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: sizes.GetHeight() * 1.8,
              color: theme.GetColor("textPrimary"),
            ),
            SizedBox(width: sizes.GetWidth() * 1),
            Text(
              title,
              style: TextStyle(
                  color: theme.GetColor("textPrimary"),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (content2 != null || content != null)
          RichText(
            text: TextSpan(
              children: [
                if (content2 != null)
                  TextSpan(
                    text: content2,
                    style: TextStyle(color: theme.GetColor("textSecondary"), fontFamily: 'Cairo',),
                  ),
                if (content != null)
                  TextSpan(
                    text: content,
                    style: TextStyle(color: textColor??theme.GetColor("textSecondary"),fontFamily: 'Cairo',),
                  ),
              ],
            ),
          ),
        if (contentWidgets != null) ...contentWidgets,
        SizedBox(height: sizes.GetHeight() * 2),
      ],
    );
  }

  Widget _buildHighlight({required String iconPath, required String text}) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          height: sizes.GetHeight() * 1.8,
          color: theme.GetColor("secondaryPrimary"),
        ),
        SizedBox(width: sizes.GetWidth() * 1),
        Text(text,style:TextStyle(color:Themes().GetColor("secondaryPrimary")),),
      ],
    );
  }
  Widget _buildRatingCard({
    required String label,
    required String iconPath,
    required int rating,
    required Function(int) onRate,
  }) {
    return Container(
      width: sizes.GetWidth() * 40,
      padding: EdgeInsets.all(sizes.GetWidth() * 3),
      decoration: BoxDecoration(
        color: theme.GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                height: sizes.GetHeight() * 2,
                color: theme.GetColor("textPrimary"),
              ),
              SizedBox(width: sizes.GetWidth() * 1.5),
              Text(
                label,
                style: TextStyle(
                  color: theme.GetColor("textPrimary"),
                  fontSize: sizes.GetHeight() * 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.GetHeight() * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                  onTap: () => onRate(index + 1 == rating ? 0 : index + 1),
                child: SvgPicture.asset(
                  index < rating ?"assets/icon/Star.svg": "assets/icon/Star_off.svg",
                  height: sizes.GetHeight() * 3,
                )
              );
            }),
          ),
        ],
      ),
    );
  }
}