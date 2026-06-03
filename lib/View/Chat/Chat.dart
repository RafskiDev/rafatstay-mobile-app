import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../Call/Call.dart';
import 'Chat_riverpod.dart';
import 'Widget/VoiceMessage.dart';
import 'Widget/VoiceRecordButton.dart';
class Chat extends ConsumerStatefulWidget {
  final int branch_id;
  const Chat({super.key,required this.branch_id});

  @override
  ConsumerState<Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  int? conversationId; // ✅ احفظه هنا
  bool isLoading = true; // ✅ إضافة
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      ref.read(Chat_riverpod.notifier).clearMessages();
      // ✅ أنشئ المحادثة أولاً
      final id = await ref
          .read(Chat_riverpod.notifier)
          .startConversation(context, widget.branch_id);

      if (!mounted || id == null) return;

      setState(() => conversationId = id); // ✅ احفظ الـ id

      // ✅ جلب الرسائل
      await ref
          .read(Chat_riverpod.notifier)
          .getMessages(context, id);
      await ref
          .read(Chat_riverpod.notifier)
          .markAsRead(context, id);
      if (mounted) setState(() => isLoading = false);
    });
  }


  @override
  Widget build(BuildContext context) {

    final sizes = Sizes(context);
    Themes theme = Themes();
    ref.watch(Chat_riverpod);
    final messages = ref.read(Chat_riverpod.notifier).messages;
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar: buildCustomAppBar(context,TextLanguage().GetWord("محادثة")),
      body:ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return showLoading();
          }
          return  SafeArea(
            child: Column(
              children: [
                // ─── قائمة الرسائل ───
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: ref.read(Chat_riverpod.notifier).scrollController,
                    padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg["isSentByMe"] as bool? ??
                          (msg["sender_type"] == "guest");
                      final alignment = isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start;

                      Widget messageWidget = const SizedBox.shrink();
                      final type = msg["type"]?.toString() ?? "text";
                      final time = msg["time"]?.toString() ??
                          msg["created_at"]?.toString() ?? "";

                      switch (type) {
                        case "text":
                          messageWidget = Message(
                            time: time,
                            text: msg["text"]?.toString() ??
                                msg["body"]?.toString() ?? "",
                            sentByMe: isMe,
                            isRead: msg["is_read"] == true,
                          );
                          break;
                        case "image":
                          String? status = msg["status"]?.toString();
                          messageWidget = Images(
                            time: time,
                            imageUrl: msg["attachment_url"]?.toString(),
                            sentByMe: isMe,
                            status: status,
                            isRead: msg["is_read"] == true,
                          );
                          break;
                        case "voice":
                        case "audio":
                        final attachmentUrl = msg["attachment_url"]?.toString() ?? "";
                        final mediaUrl = msg["mediaUrl"]?.toString() ?? "";
                        final voiceUrl = attachmentUrl.isNotEmpty ? attachmentUrl : mediaUrl;

                        // سيأخذ الآن المدة المستخرجة الحقيقية من السيرفر
                        int duration = (msg["duration"] as num?)?.toInt() ?? 5;
                        double progress = (msg["progress"] as num?)?.toDouble() ?? 0.0;
                          messageWidget = VoiceMessage(
                            voiceUrl: voiceUrl,
                            time: time,
                            sentByMe: isMe,
                            duration: duration,
                            progress:progress,
                          );
                          break;
                        default:
                          messageWidget = const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: sizes.GetHeight() * 1),
                        child: Row(
                          mainAxisAlignment: alignment,
                          children: [messageWidget],
                        ),
                      );
                    },
                  ),
                ),

                // ─── منطقة الإدخال ───
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.GetWidth() * 2,
                    vertical: sizes.GetHeight() * 2,
                  ),
                  child: Column(
                    children: [
                      Input(conversationId: conversationId ?? 0),
                      SizedBox(height: sizes.GetHeight() * 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ─── زر الصورة ───
                          CircularButton(
                            size: sizes.GetHeight() * 7,
                            backgroundColor: theme.GetColor("backgroundLight"),
                            borderColor: Colors.transparent,
                            borderWidth: 0,
                            onTap: ()async {
                              await ref.read(Chat_riverpod.notifier).pickAndSendImage(context,conversationId!);
                            },
                            child: SvgPicture.asset(
                              "assets/icon/photo.svg",
                              height: sizes.GetHeight() * 3.3,
                            ),
                          ),
                          /*
                          // ─── زر الاتصال ───
                          CircularButton(
                            size: sizes.GetHeight() * 7,
                            backgroundColor: theme.GetColor("primary"),
                            borderColor: Colors.transparent,
                            borderWidth: 0,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, a1, a2) => Call(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: SvgPicture.asset(
                              "assets/icon/phone.svg",
                              color: theme.GetColor("white"),
                              height: sizes.GetHeight() * 3.3,
                            ),
                          ),

                           */
                          Row(
                            children: [
                              /*
                              VoiceRecordButton(
                                onSend: (audioFile, duration) async {
                                  await ref.read(Chat_riverpod.notifier).sendVoice(
                                    context,
                                    conversationId!,
                                    audioFile,
                                    duration,
                                  );
                                },
                              ),
                               */
                              /*
                              // ─── زر الصوت ───
                              CircularButton(
                                size: sizes.GetHeight() * 7,
                                backgroundColor: theme.GetColor("backgroundLight"),
                                borderColor: Colors.transparent,
                                borderWidth: 0,
                                onTap: () {
                                  print("voice");
                                },
                                child: SvgPicture.asset(
                                  "assets/icon/microphone.svg",
                                  height: sizes.GetHeight() * 3.3,
                                ),
                              ),

                               */

                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

      ),
    );
  }
}

class Input extends ConsumerWidget {
  final int conversationId;
  const Input({super.key,required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(Chat_riverpod.notifier);
    return TextField(
      controller: notifier.messageController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Themes().GetColor("backgroundOffWhite"),
        hintText:TextLanguage().GetWord("اكتب الرسالة........"),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CircularButton(
            size: Sizes(context).GetHeight()*2,
            backgroundColor: Themes().GetColor("textPrimary"),
            borderColor: Colors.transparent,
            borderWidth: 0,
            onTap: () {
              notifier.sendMessage(context, notifier.messageController.text,conversationId); // ✅ مرر context و conversationId
            },
            child:SvgPicture.asset("assets/icon/send.svg",height:Sizes(context).GetHeight()*3),
          ),
        ),
      ),
    );
  }
}

class Message extends StatelessWidget {
  String text;
  bool sentByMe;
  String time;
  final bool isRead;
   Message({super.key, required this.text,this.sentByMe=false,this.time="",this.isRead = false,});

  @override
  Widget build(BuildContext context) {
    final times = DateTimeHelper.extractTime(time);
    return  Container(
      width:Sizes(context).GetWidth()*60,
      padding: EdgeInsets.all(18),
      decoration:BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color:sentByMe?Themes().GetColor("primaryA"):Themes().GetColor("primaryS")
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (sentByMe) Icon(
                isRead ? Icons.done_all : Icons.done,
                color: isRead ? Colors.green  : Colors.white70,
                size: 16,
              ),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Text(times, style: TextStyle(color: Themes().GetColor("white"))),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight()*1),
          Text(
            text,
            style: TextStyle(color: Themes().GetColor("white")),
            softWrap: true,      // ✅ التفاف النص
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
class Images extends StatelessWidget {
  final String? imageUrl;
  final bool sentByMe;
  final String time;
  final String? status;
  final bool isRead;
  Images({
    super.key,
    required this.imageUrl,
    this.sentByMe = false,
    this.time = "",
    this.status,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    Widget displayedImage;
    if (status == 'sent_local' && imageUrl != null && !imageUrl!.startsWith("http")) {
      displayedImage = Image.file(
        File(imageUrl!),
        fit: BoxFit.cover,
        width: sizes.GetWidth() * 42,
        height: sizes.GetHeight() * 13,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: sizes.GetWidth() * 42,
            height: sizes.GetHeight() * 13,
            color: Colors.grey[300],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[600],
              size: 40,
            ),
          );
        },
      );
    }
    else if (imageUrl == null || imageUrl!.isEmpty) {
      displayedImage = Container(
        width: sizes.GetWidth() * 42,
        height: sizes.GetHeight() * 13,
        color: Colors.grey[300],
        child: Icon(
          Icons.image,
          color: Colors.grey[600],
          size: 40,
        ),
      );
    }
    else if (imageUrl!.startsWith("http")) {
      // رابط من الإنترنت
      displayedImage = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: sizes.GetWidth() * 42,
        height: sizes.GetHeight() * 13,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: sizes.GetWidth() * 42,
            height: sizes.GetHeight() * 13,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("Error loading network image: $error");
          return Container(
            width: sizes.GetWidth() * 42,
            height: sizes.GetHeight() * 13,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey[600],
                  size: 40,
                ),
                Text(
                  "فشل تحميل الصورة",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      );
    }
    else {
      // مسار محلي
      displayedImage = Image.file(
        File(imageUrl!),
        fit: BoxFit.cover,
        width: sizes.GetWidth() * 42,
        height: sizes.GetHeight() * 13,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading local image: $error");
          return Container(
            width: sizes.GetWidth() * 42,
            height: sizes.GetHeight() * 13,
            color: Colors.grey[300],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[600],
              size: 40,
            ),
          );
        },
      );
    }

    return Container(
      width: sizes.GetWidth() * 55,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: sentByMe
            ? Themes().GetColor("primaryA")
            : Themes().GetColor("primaryS"),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: displayedImage,
              ),
              if (status == 'sending')
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (status == 'failed')
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (sentByMe) ...[
                Icon(
                  isRead ? Icons.done_all : Icons.done,
                  color: isRead ? Colors.green  : Colors.white70,
                  size: 16,
                ),
                SizedBox(width: Sizes(context).GetWidth() * 1),
              ],
              Text(
                DateTimeHelper().formatDateTime(time),
                style: TextStyle(color: Themes().GetColor("white")),
              ),
              if (status == 'sending') ...[
                SizedBox(width: 5),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              ],
              if (status == 'failed') ...[
                SizedBox(width: 5),
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 14,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
/*
  // دالة لتنسيق الوقت (مثلاً: 65 ثانية = 1:05)
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

 */
