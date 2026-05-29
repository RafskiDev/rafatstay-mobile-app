import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController controller = TextEditingController(); // tip_amount
  FocusNode focusNodeController = FocusNode();
  TextEditingController birthday = TextEditingController(); // birthday
  TextEditingController comment = TextEditingController();

  FocusNode focusNodeComment = FocusNode();
  FocusNode focusNodeBirthday = FocusNode();
  int? selectedGender;// 1 = male, 2 = female
  // ✅ overall_rating + atmosphere_rating
  final ratings = [
    {"title": "Overall rating", "icon": "assets/icon/restaurant.svg", "rate": 0},
    {"title": "Atmosphere", "icon": "assets/icon/Atmosphere.svg", "rate": 0},
    {"title": "Layout", "icon": "assets/icon/Layout.svg", "rate": 0},
    {"title": "Value for money", "icon": "assets/icon/ValueForMoney.svg", "rate": 0},
  ];

  // ✅ food_rating + service_rating
  final services = [
    {"title": "Food Quality", "icon": "assets/icon/FoodQuality.svg", "rate": 0},
    {"title": "Service Speed", "icon": "assets/icon/ServiceSpeed.svg", "rate": 0},
    {"title": "Staff Behavior", "icon": "assets/icon/StaffBehavior.svg", "rate": 0},
    {"title": "Cleanliness", "icon": "assets/icon/Cleanliness.svg", "rate": 0},
  ];


  List<Map<String, dynamic>> employeeList = [];

  Future<void> loadEmployees(BuildContext context, int branchId) async {
    final res = await ApiService().get(
      "v1/guest/branches/$branchId/staff",
      {},
      context,
    );
    if (res?["success"] == true) {
      employeeList = List<Map<String, dynamic>>.from(res["data"] ?? []);
      state++;
    }
  }

   final reviews = [
     {"title": "Attitude", "icon": "assets/icon/Attitude.svg", "rate": 0},
     {"title": "Attention to Detail", "icon": "assets/icon/AttentionToDetail.svg", "rate": 0},
     {"title": "Professionalism", "icon": "assets/icon/Professionalism.svg", "rate": 0},
   ];

  final Set<int> selectedPersonIndexes = {};

  @override
  int build() {
    ref.onDispose(() {
      controller.dispose();
      focusNodeController.dispose();
      birthday.dispose();
      focusNodeBirthday.dispose();
      comment.dispose();
      focusNodeComment.dispose();
    });
    return 0;
  }

  void reset() => state = 0;

  void updateRating(int index, int newRate) {
    ratings[index]["rate"] = newRate;
    state++;
  }

  void updateServiceRating(int index, int newRate) {
    services[index]["rate"] = newRate;
    state++;
  }


   void updateReviewRating(int index, int newRate) {
     reviews[index]["rate"] = newRate;
     state++;
   }

  void togglePersonSelection(int index) {
    if (selectedPersonIndexes.contains(index)) {
      selectedPersonIndexes.remove(index);
    } else {
      selectedPersonIndexes.add(index);
    }
    state++;
  }

  void setGender(int value) {
    selectedGender = value;
    state++;
  }

  List<String> getSelectedPersonNames() {
    return selectedPersonIndexes
        .map((i) => employeeList[i]["title"].toString())
        .toList();
  }

  Map<String, dynamic> buildReviewBody({required int branchId}) {
    final genderMap = {1: "male", 2: "female"};

    final overallRating    = (ratings[0]["rate"] as int?) ?? 0;
    final atmosphereRating = (ratings[1]["rate"] as int?) ?? 0;
    final layoutRating     = (ratings[2]["rate"] as int?) ?? 0;
    final valueRating      = (ratings[3]["rate"] as int?) ?? 0;

    final foodRating          = (services[0]["rate"] as int?) ?? 0;
    final serviceRating       = (services[1]["rate"] as int?) ?? 0;
    final staffBehaviorRating = (services[2]["rate"] as int?) ?? 0;
    final cleanlinessRating   = (services[3]["rate"] as int?) ?? 0;

    final attitudeRating      = (reviews[0]["rate"] as int?) ?? 0;
    final attentionRating     = (reviews[1]["rate"] as int?) ?? 0;
    final professionalismRating = (reviews[2]["rate"] as int?) ?? 0;

    final hasEmployee = selectedPersonIndexes.isNotEmpty && employeeList.isNotEmpty;

    return {
      "branch_id": branchId,
      if (overallRating > 0)       "overall_rating": overallRating,
      if (atmosphereRating > 0)    "atmosphere_rating": atmosphereRating,
      if (layoutRating > 0)        "layout_rating": layoutRating,
      if (valueRating > 0)         "value_rating": valueRating,
      if (foodRating > 0)          "food_rating": foodRating,
      if (serviceRating > 0)       "service_rating": serviceRating,
      if (staffBehaviorRating > 0) "staff_behavior_rating": staffBehaviorRating,
      if (cleanlinessRating > 0)   "cleanliness_rating": cleanlinessRating,
      if (comment.text.isNotEmpty) "comment": comment.text.trim(),
      if (controller.text.isNotEmpty) "tip_amount": double.tryParse(controller.text),
      if (birthday.text.isNotEmpty)   "birthday": _formatBirthday(birthday.text),
      if (hasEmployee) "best_employee_id": employeeList[selectedPersonIndexes.first]["id"],
      if (hasEmployee && attitudeRating > 0)       "attitude_rating": attitudeRating,
      if (hasEmployee && attentionRating > 0)      "attention_rating": attentionRating,
      if (hasEmployee && professionalismRating > 0) "professionalism_rating": professionalismRating,
      if (selectedGender != null) "gender": genderMap[selectedGender],
    };
  }

  Future<void> submitReview({required int branchId, required BuildContext context}) async {
    final body = buildReviewBody(branchId: branchId);
    final response = await ApiService().postMultipart(
      "v1/guest/reviews",
      body,
      files: selectedImage != null ? [selectedImage!] : [],
      fileField: "media[]",
      context: context,
    );
    if (!context.mounted) return;
    if (response['success'] == true) {
      resetForm();
      ToastMessages(
        context,
        TextLanguage().GetWord("تم إرسال التقييم بنجاح!"),
        Themes().GetColor("success"),
        Themes().GetColor("white"),
      );
    }else{
      ToastMessages(
        context,
        response["message"],
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }

  String _formatBirthday(String text) {
    try {
      // إذا المستخدم يكتب DD/MM/YYYY حولها
      final parts = text.split("/");
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1].padLeft(2,'0')}-${parts[0].padLeft(2,'0')}";
      }
      return text; // إذا مكتوبة صح YYYY-MM-DD
    } catch (_) {
      return text;
    }
  }
  File? selectedImage; // ← بدل List<File> selectedMedia

  Future<void> pickMedia(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage = File(picked.path);
      state++;
    }
  }

  void removeMedia(int index) {
    selectedImage = null;
    state++;
  }


  bool isVideo(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }
  void resetForm() {
    // controllers
    controller.clear();
    birthday.clear();
    comment.clear();

    // ratings
    for (var r in ratings) r["rate"] = 0;
    for (var s in services) s["rate"] = 0;
    for (var r in reviews) r["rate"] = 0;

    // selections
    selectedPersonIndexes.clear();
    selectedGender = null;
    selectedImage = null;

    state++;
  }
}

final RateYourExperience_riverpod =
NotifierProvider<PageNotifier, int>(PageNotifier.new);