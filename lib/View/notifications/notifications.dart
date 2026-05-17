import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/CheckBox.dart';
import '../../Widget/GradientBorderContainer.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../PayNow/PayNow.dart';
import 'notifications_riverpod.dart';

class notifications extends ConsumerWidget {
  notifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesMap = ref.watch(notifications_riverpod);
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final notifications = ref.watch(notifications_riverpod.notifier).notifications;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notifications_riverpod.notifier).notification(context);
    });
    return Scaffold(
      appBar: buildCustomAppBar(context, textLanguage.GetWord("الإشعارات")),
      backgroundColor: theme.GetColor("background"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        child:ValueListenableBuilder<bool>(
          valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            return  isLoading?showLoading(): SingleChildScrollView(
            child: Column(
              children: messagesMap.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: sizes.GetHeight() * 3,
                            color: theme.GetColor("textSecondary"),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:notifications.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = entry.value[index];
                        final isLast = index == entry.value.length - 1;
                        return Container(
                          margin: EdgeInsets.only(bottom: isLast ? 0 : sizes.GetHeight() * 2),
                          child: FeedbackMessageBubble(
                            message: notifications[index]["message"],
                            time: notifications[index]["created_at"],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          );
            }
        )
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
        child: Image.asset(
          "assets/images/logoApp.png",
          height: Sizes(context).GetHeight() * 10,
        ),
      ),
    );
  }
  }
