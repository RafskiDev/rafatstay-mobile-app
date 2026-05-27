import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:image_picker/image_picker.dart';

import '../../Service/ApiService.dart';
class PageNotifier extends Notifier<int> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ✅ إضافة
  List<Map<String, dynamic>> messages = [];

  final initialMessages = [];

  static double calculateProgress(int duration) {
    // على سبيل المثال: نحول المدة إلى نسبة من 60 ثانية
    return (duration / 60).clamp(0.0, 1.0);
  }

  Future<void> sendMessage(BuildContext context, String text, int conversationId) async {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final String formattedTime =
        "${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} "
        "${now.period == DayPeriod.am ? 'AM' : 'PM'}";

    // ✅ أضف للـ UI فوراً
    messages.insert(0, {
      'text': text,
      'time': formattedTime,
      'isSentByMe': true,
      'type': 'text',
    });

    messageController.clear();
    ref.notifyListeners();

    // ✅ أرسل للـ API
    await sendText(context, conversationId, text);

    // ✅ نزول للأسفل
    scrollToBottom();
  }
  Future<void> pickAndSendImage(BuildContext context, int conversationId) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final now = TimeOfDay.now();
    final String formattedTime =
        "${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} "
        "${now.period == DayPeriod.am ? 'AM' : 'PM'}";

    // إنشاء معرف مؤقت للرسالة
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // عرض الصورة محلياً أولاً
    messages.insert(0, {
      'id': tempId,
      'text': '📷 صورة',
      'time': formattedTime,
      'isSentByMe': true,
      'type': 'image',
      'mediaUrl': image.path,
      'status': 'sending',
      'attachment_url': null,
    });
    ref.notifyListeners();

    try {


      // الخطوة 2: إرسال رابط الصورة إلى الـ API
      final res = await ApiService().post(
        "v1/guest/chat/conversations/$conversationId/messages",
        {
          "body": "📷 صورة",
          "type": "image",
          "attachment_url": image.path,
          "attachment_name": "image.jpg",
        },
        context,
      );

      // إزالة الرسالة المؤقتة
      messages.removeWhere((msg) => msg['id'] == tempId);

      // التحقق من نجاح الإرسال
      if (res != null && res['success'] == true && res['data'] != null) {
        final messageData = res['data'];
        final attachmentUrl = messageData['attachment_url'];

        // إضافة الرسالة النهائية
        messages.insert(0, {
          'id': messageData['id']?.toString() ?? tempId,
          'text': messageData['body'] ?? "📷 صورة",
          'time': messageData['created_at'] ?? formattedTime,
          'isSentByMe': true,
          'type': 'image',
          'attachment_url': attachmentUrl ?? image.path,
          'status': 'sent',
        });
      } else {
        // فشل الإرسال
        messages.insert(0, {
          'id': tempId,
          'text': '📷 صورة',
          'time': formattedTime,
          'isSentByMe': true,
          'type': 'image',
          'mediaUrl': image.path,
          'status': 'failed',
          'error': res?['message'] ?? 'فشل في إرسال الصورة',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res?['message'] ?? 'فشل في إرسال الصورة')),
        );
      }

      ref.notifyListeners();

    } catch (e) {
      print("Error: $e");

      final index = messages.indexWhere((msg) => msg['id'] == tempId);
      if (index != -1) {
        messages[index]['status'] = 'failed';
        messages[index]['error'] = e.toString();
      }
      ref.notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال الصورة: ${e.toString()}')),
      );
    }
    scrollToBottom();
  }
  @override
  int build() {
    return 0;
  }
  Future<int?> startConversation(BuildContext context, int branchId) async {
    final response = await ApiService().post(
      "v1/$roles/chat/conversations",
      {
        "branch_id": branchId,
      },
      context,
    );

    final conversationId = response?['data']?['id'];
    return conversationId;
  }
  Future<void> sendText(BuildContext context, int conversationId, String message) async {
     await ApiService().post(
      "v1/$roles/chat/conversations/$conversationId/messages",
      {
        "body": message,
        "type": "text",
      },
      context,
    );
  }
  void clearMessages() {
    messages.clear();
    ref.notifyListeners();
  }
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        // مع reverse: true، الأسفل هو position 0
        scrollController.animateTo(
          0,  // ✅ لأن reverse: true يجعل الأسفل هو البداية
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  Future<void> sendVoice(BuildContext context, int conversationId, File audioFile, int duration) async {
    final now = TimeOfDay.now();
    final String formattedTime =
        "${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} "
        "${now.period == DayPeriod.am ? 'AM' : 'PM'}";

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    messages.insert(0, {
      'id': tempId,
      'text': '🎤 رسالة صوتية',
      'time': formattedTime,
      'isSentByMe': true,
      'type': 'voice',
      'mediaUrl': audioFile.path,
      'duration': duration,
      'progress': 0.0,
      'status': 'sending',
    });
    ref.notifyListeners();
    scrollToBottom();

    try {
      final res = await ApiService().uploadFile(
        "v1/guest/chat/conversations/$conversationId/messages",
        audioFile,
        context,
        fieldName: "attachment",
        mimeType: "audio/aac",
        fields: {
          "body": "voice",
          "type": "audio",
        },
      );

      messages.removeWhere((msg) => msg['id'] == tempId);

      if (res != null && res['success'] == true && res['data'] != null) {
        final messageData = res['data'];
        final attachmentUrl = messageData['attachment_url'];

        messages.insert(0, {
          'id': messageData['id']?.toString() ?? tempId,
          'text': messageData['body'] ?? "🎤 رسالة صوتية",
          'time': messageData['created_at'] ?? formattedTime,
          'isSentByMe': true,
          'type': 'voice',
          'attachment_url': attachmentUrl,
          'mediaUrl': audioFile.path,
          "body": "voice",
          'progress': 0.0,
          'status': 'sent',
        });
      } else {
        messages.insert(0, {
          'id': tempId,
          'text': '🎤 رسالة صوتية',
          'time': formattedTime,
          'isSentByMe': true,
          'type': 'voice',
          'mediaUrl': audioFile.path,
          'duration': 0,
          'progress': 0.0,
          'status': 'failed',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res?['message'] ?? 'فشل في إرسال الصوت')),
        );
      }

      ref.notifyListeners();
      scrollToBottom();

    } catch (e) {
      print("Error sending voice: $e");

      final index = messages.indexWhere((msg) => msg['id'] == tempId);
      if (index != -1) {
        messages[index]['status'] = 'failed';
        messages[index]['mediaUrl'] = audioFile.path; // ← احتفظ بالمسار حتى عند الفشل
      }
      ref.notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال الصوت: ${e.toString()}')),
      );
    }
  }

// ─── جلب الرسائل ───
  Future<void> getMessages(BuildContext context, int conversationId) async {
    messages.clear();
    final response = await ApiService().get(
      "v1/guest/chat/conversations/$conversationId/messages",
      {},
      context,
    );

    if (response != null && response['data'] != null) {
      final data = response['data'];

      if (data['items'] != null) {
        messages = List<Map<String, dynamic>>.from(data['items']).map((msg) {
          // تحويل البيانات إلى الشكل المطلوب للـ UI
          return {
            'id': msg['id']?.toString(),
            'text': msg['body'] ?? '',
            'time': msg['created_at'] ?? '',
            'isSentByMe': msg['sender_type'] == 'guest',
            'type': msg['type'] ?? 'text',
            'attachment_url': msg['attachment_url'],
            'is_read': msg['is_read'] ?? false,
            'duration':0,
            'status': 'sent',
          };
        }).toList();
         /*
        // طباعة للتحقق من الصور
        for (var msg in messages) {
          if (msg['type'] == 'image') {
            print("Image message: id=${msg['id']}, url=${msg['attachment_url']}");
          }
        }

          */
      }
    }
    ref.notifyListeners();
  }

// ─── إرسال typing ───
  Future<void> sendTyping(BuildContext context, int conversationId, bool isTyping) async {
    await ApiService().post(
      "v1/guest/chat/conversations/$conversationId/typing",
      {"is_typing": isTyping},
      context,
    );
  }

// ─── قراءة الرسائل ───
  Future<void> markAsRead(BuildContext context, int conversationId) async {
   await ApiService().post(
      "v1/guest/chat/conversations/$conversationId/read",
      {},
      context,
    );
  }
}

final Chat_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
