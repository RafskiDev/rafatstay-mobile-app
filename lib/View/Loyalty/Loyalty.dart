import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/GradientBorderContainer.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import 'Loyalty_riverpod.dart';

class Loyalty extends ConsumerStatefulWidget {
  const Loyalty({super.key});

  @override
  ConsumerState<Loyalty> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Loyalty> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(Loyalty_riverpod.notifier).fetchLoyaltyHistory(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final messagesMap = ref.watch(Loyalty_riverpod);
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return Scaffold(
      appBar: buildCustomAppBar(context,textLanguage.GetWord("ولاء")),
      backgroundColor: theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          return isLoading?showLoading(): Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
            child: SingleChildScrollView(
              child: Column(
                children: messagesMap.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: sizes.GetHeight() * 3,
                              color: theme.GetColor("textSecondary"),
                            ),
                          ),
                          entry.key =="Today"?SquareButton(
                            width: Sizes(context).GetWidth()*40,
                            height: Sizes(context).GetHeight()*5,
                            onTap: () {
                              print("تم الضغط على الزر!");
                            },
                            backgroundColor:Themes().GetColor("primaryA"),
                            borderRadius: Sizes(context).GetWidth()*5,
                            elevation: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/icon/LoyaltyRewards.svg"),
                                SizedBox(width: sizes.GetWidth()*2),
                                Text(
                                  "${textLanguage.GetWord("الإجمالي")} ${ref.read(Loyalty_riverpod.notifier).loyaltyProfile?["available_points"] ?? 0} ${textLanguage.GetWord('نقطة')}",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ):SizedBox(),

                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          final message = entry.value[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: sizes.GetHeight() * 2),
                            child: FeedbackMessageBubble(
                              message: message["description"]?.toString() ?? "",
                              time: message["created_at"]?.toString() ?? "",
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }

      ),
    );
  }
}

class FeedbackMessageBubble extends StatelessWidget {
  final String message;
  final String time;

  const FeedbackMessageBubble({
    Key? key,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد ألوان الإطار المتداخلة
    final borderGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Themes().GetColor("secondary500"),
        Themes().GetColor("primary"),
      ],
    );
    return GradientBorderContainer(
      gradient: borderGradient,
      borderWidth: 1,
      borderRadius: BorderRadius.circular(18),
      backgroundColor: Themes().GetColor("backgroundOffWhite"),
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(context),
          SizedBox(width: Sizes(context).GetWidth() * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Themes().GetColor("textPrimary"),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Sizes(context).GetWidth() * 2), // Changed width to height for vertical spacing
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Themes().GetColor("primary"),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: Sizes(context).GetHeight() * 5,
      height: Sizes(context).GetHeight() * 5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          "assets/icon/LoyaltyProgram.svg",
          width: Sizes(context).GetHeight() * 3.5,
          height: Sizes(context).GetHeight() * 3.5,
        ),
      ),
    );
  }
}
