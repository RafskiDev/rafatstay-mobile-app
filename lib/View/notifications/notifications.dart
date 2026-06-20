import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
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

class notifications extends ConsumerStatefulWidget {
  const notifications({super.key});

  @override
  ConsumerState<notifications> createState() => _notificationsState();
}

class _notificationsState extends ConsumerState<notifications> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // جلب البيانات الأولى عند فتح الصفحة
    Future.microtask(() {
      ref.read(notifications_riverpod.notifier).notification(context);
    });
  }

  // دالة الاستماع للتمرير لأسفل (Pagination)
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(notifications_riverpod.notifier);
      if (!notifier.isFetching && notifier.hasMore) {
        notifier.notification(context, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesMap = ref.watch(notifications_riverpod);
    final notifier = ref.read(notifications_riverpod.notifier);
    final sizes = Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();

    return Scaffold(
      appBar: buildCustomAppBar(context, textLanguage.GetWord("الإشعارات"),showNotification:false),
      backgroundColor: theme.GetColor("background"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        child: ValueListenableBuilder<bool>(
          valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            // نعرض اللودينج فقط في أول مرة ولا توجد بيانات بعد
            if (isLoading && messagesMap.isEmpty) {
              return showLoading();
            }
            return SingleChildScrollView(
              controller: _scrollController, // ربط الـ Controller
              child: Column(
                children: [
                  // رسم الإشعارات
                  ...messagesMap.entries.map((entry) {
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entry.value.length,
                          itemBuilder: (BuildContext context, int index) {
                            final message = entry.value[index];
                            final isLast = index == entry.value.length - 1;

                            final Map<String, dynamic> extraData =
                            message["data"] is Map ? Map<String, dynamic>.from(message["data"]) : {};

                            final String branchName = extraData["branch_name"]?.toString() ?? "";
                            final String reason = extraData["reason"]?.toString() ?? "";
                            final String displayMessage = reason.isNotEmpty
                                ? reason
                                : (message["body_ar"] ?? message["body"] ?? "");
                            final String formattedTime =
                            DateTimeHelper().formatDateTime(message["created_at"]?.toString());
                            return Container(
                              margin: EdgeInsets.only(bottom: isLast ? 0 : sizes.GetHeight() * 2),
                              child: FeedbackMessageBubble(
                                message: displayMessage,
                                time:formattedTime,
                                branchName: branchName,
                                reason: reason,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),

                  // مؤشر جلب المزيد (Loading Indicator) في الأسفل
                  if (notifier.isFetching && messagesMap.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: showLoading()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FeedbackMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final String branchName;
  final String reason;

  const FeedbackMessageBubble({
    Key? key,
    required this.message,
    required this.time,
    this.branchName = "",
    this.reason = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                // اسم الفرع بمكان مخصص فوگ
                if (branchName.isNotEmpty)
                  Text(
                    branchName,
                    style: TextStyle(
                      color: Themes().GetColor("primary"),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                if (branchName.isNotEmpty)
                  SizedBox(height: Sizes(context).GetWidth() * 1),

                Text(
                  message,
                  style: TextStyle(
                    color: Themes().GetColor("textPrimary"),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: Sizes(context).GetWidth() * 2),
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
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Image.asset(
          "assets/images/logoApp.png",
          height: Sizes(context).GetHeight() * 10,
        ),
      ),
    );
  }
}