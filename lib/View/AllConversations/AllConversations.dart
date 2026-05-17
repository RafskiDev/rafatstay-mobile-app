import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetTextField.dart';
import '../Chat/Chat.dart';
import 'AllConversations_riverpod.dart';
class AllConversations extends ConsumerStatefulWidget  {
  const AllConversations({super.key});

  @override
  ConsumerState<AllConversations> createState() => _SearchState();
}

class _SearchState extends ConsumerState<AllConversations> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(AllConversations_riverpod.notifier).fetchConversations(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(AllConversations_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(showBackButton:false,context,textLanguage.GetWord("جميع المحادثات")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
        child:ValueListenableBuilder<bool>(
          valueListenable:LoadingService.isLoading,
          builder: (context, isLoading, child) {
            return isLoading
                ? showLoading()
                : SingleChildScrollView(
                child: Column(
                    children: [
                      WidgetTextField(
                        Controller: ref
                            .read(AllConversations_riverpod.notifier)
                            .searchController,
                        HintText: textLanguage.GetWord("بحث"),
                        iconData: "assets/icon/Search.svg",
                        Horizontal: sizes.GetWidth() * 2,
                        focusNode: ref
                            .read(AllConversations_riverpod.notifier)
                            .searchNode,
                      ),
                      SizedBox(height: sizes.GetHeight() * 2,),
                      ListView.builder(
                          shrinkWrap: true,
                          controller: ScrollController()
                            ..addListener(() {
                              final scroll = ScrollController();
                              if (scroll.position.pixels >= scroll.position.maxScrollExtent - 200) {
                                ref.read(AllConversations_riverpod.notifier).fetchConversations(context, loadMore: true);
                              }
                            }),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: ref.read(AllConversations_riverpod.notifier).conversations.length + 1, // +1 للتحميل
                          itemBuilder: (context, index) {
                            final notifier = ref.read(AllConversations_riverpod.notifier);
                            if (index >= notifier.conversations.length) {
                              // إذا كنا في نهاية القائمة
                              return notifier.isFetchingMore ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ) : const SizedBox();
                            }

                            final item = notifier.conversations[index];
                            final lastMessage = item["last_message"];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: Sizes(context).GetHeight() * 1),
                              child: AlBaikChatCard(
                                isYou: lastMessage != null ? lastMessage["sender_type"] != "guest" : false,
                                restaurantName: item["branch"]["name"],
                                branchName: item["branch"]["business_name"],
                                message: item["last_message"]==null?"":item["last_message"]["body"],
                                date: item["last_message_at"].toString().split('T')[0],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => Chat(branch_id:item["branch"]["id"]),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                      )
                    ]
                )
            );
          }
        )
      )
    );
  }
}

class AlBaikChatCard extends StatelessWidget {

  final String restaurantName;
  final String branchName;
  final String date;
  final String message;
  final bool isYou;
  final VoidCallback? onTap;

  const AlBaikChatCard({
    super.key,
    required this.restaurantName,
    required this.branchName,
    required this.date,
    required this.message,
    this.isYou = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap!,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Themes().GetColor("backgroundOffWhite"),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Themes().GetColor("textPrimary").withOpacity(0.2),
              offset: Offset(0, 0),   // من كل الجهات
              blurRadius: 1,         // مدى الانتشار
              spreadRadius: 0.5,       // توسعة خفيفة
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: Sizes(context).GetHeight() * 0.5),
              child: CircularButton(
                size: Sizes(context).GetHeight()*6,
                backgroundColor:Themes().GetColor("secondary500"),
                borderWidth: 0,
                borderColor: Themes().GetColor("secondary500"),
                onTap:onTap!,
                child: Image.asset("assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png")
              ),
            ),
            SizedBox(width: Sizes(context).GetWidth()*2,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            /*
                            Text(
                              restaurantName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Themes().GetColor("textPrimary"),
                              ),
                            ),
                             */
                            SizedBox(width: Sizes(context).GetWidth() * 2),

                            // اسم الفرع (نص طويل) مع قص ذكي
                            Expanded(
                              child: Text(
                                branchName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // 🔥 يمنع الـ overflow
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Themes().GetColor("textSecondary"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // التاريخ في اليمين
                      SizedBox(width: Sizes(context).GetWidth() * 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: Themes().GetColor("primary"),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width:Sizes(context).GetWidth()*2,),
                    ],
                  ),

                  Text.rich(
                    TextSpan(
                      children: [
                        if(isYou)
                        TextSpan(
                          text: 'You: ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color:Themes().GetColor("secondary500"),),
                        ),
                        TextSpan(
                          text: message,
                          style: TextStyle(fontSize: 18, color:Themes().GetColor("secondaryPrimary")), // اللون الذهبي/البني
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}