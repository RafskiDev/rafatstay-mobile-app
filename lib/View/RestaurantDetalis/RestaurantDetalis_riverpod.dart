import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:video_player/video_player.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import 'RestaurantDetalis.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  int selectedIndex = 0;
  int selectedCarouselIndex = 0;
   VideoPlayerController controller = VideoPlayerController.network("https://samplelib.com/lib/preview/mp4/sample-5s.mp4")..initialize();
  TextLanguage textLanguage = TextLanguage();


  Future<void> fetchAllBranchData(BuildContext context, int branchId) async {
    isFetchingBranch = true;
    ref.notifyListeners();

    try {
      // استخدم Future.wait لتنفيذ كل الطلبات بشكل متوازٍ وانتظارها معاً
      await Future.wait([
        offers(context, branchId),
        employees(context, branchId),
        reviews(context, branchId),
        branche(context, branchId),
        menus(context, branchId),
        branchPolicies(context, branchId),
        garages(context, branchId),
        superGuests_(context, branchId),
      ]);
    } catch (e) {
      print("Error fetching branch data: $e");
    } finally {
      isFetchingBranch = false;
      ref.notifyListeners();
    }
  }

  final List<dynamic> carouselItems = [
    // Item 1: Gradient بلونين
    {
      "image": "assets/images/66fed65c893473ef90356d043c26c12940be6cf5.png",
    //  'leftColor': Color(0xFFA56C0B),
    //  'rightColor': Color(0xFFA56C0B),
    },
    {
      "image": "assets/images/66fed65c893473ef90356d043c26c12940be6cf5.png",
    //  'leftColor': Color(0xFFA56C0B),
     // 'rightColor': Color(0xFFA56C0B),
    },
  ];

  String  videoUrl= "https://samplelib.com/lib/preview/mp4/sample-5s.mp4";
  final List<dynamic> carouselItems_ = [
    // Item 1: Gradient بلونين
    {
      'leftColor': Color(0xFFA56C0B), // ذهبي غامق (يسار)
      'rightColor': Color(0xFFFFF8DC), // ذهبي فاتح (يمين)
      'text': 'عرض خاص!',
      'subtitle': 'احصل على خصم 50%',
      "image": "assets/images/Berkers.png",
    },

    // Item 3: Gradient بألوان أخرى
    {
      'leftColor': Color(0xFFA56C0B), // ذهبي داكن
      'rightColor': Color(0xFFF4EBD7), // ليموني فاتح
      'text': 'عروض اليوم',
      "subtitle": "وجبة الدجاج الكاملة",
      "image": "assets/images/ChickenDish.png",
    },
    {
      'leftColor': Color(0xFFA56C0B), // ذهبي داكن
      'rightColor': Color(0xFFF4EBD7), // ليموني فاتح
      'text': 'عروض اليوم',
      "subtitle": "وجبة الدجاج الكاملة",
      "image": "assets/images/ChickenDish.png",
    },
    {
      'leftColor': Color(0xFFA56C0B), // ذهبي داكن
      'rightColor': Color(0xFFF4EBD7), // ليموني فاتح
      'text': 'عروض اليوم',
      "subtitle": "وجبة الدجاج الكاملة",
      "image": "assets/images/ChickenDish.png",
    },
  ];

  final List<String> tags = [];
  int selectedMenuIndex=0;
  final menuItems = ["Location", "Policy", "Garage", "Employees", "Super Guest"];
  void changeSelectedMenu(int index) {
    selectedMenuIndex = index;
    ref.notifyListeners();
  }

  @override
  int build() => 0;

  List<dynamic> offer = [];

  Future<void> offers(BuildContext context, int branchId) async {
    ApiService api = ApiService();

    final res = await api.get(
      "v1/$roles/branches/$branchId/offers",
      {},
      context,
    );
    if (res?["success"] == true) {
      offer = List<Map<String, dynamic>>.from(res["data"] ?? []);
      ref.notifyListeners();
    }
  }

  List<dynamic> employee = [];

  Future<void> employees(BuildContext context,int branchId) async {
    ApiService api = ApiService();

    final res = await api.get(
      "v1/$roles/branches/$branchId/staff",
      {},
      context,
    );
    if (res?["success"] == true) {
      employee = List<Map<String, dynamic>>.from(res["data"] ?? []);
      ref.notifyListeners();
    }
  }

  List<dynamic> menu = [];
  List<dynamic> meals = [];    // القسم الأساسي
  List<dynamic> meals_ = [];   // الأقسام الإضافية (side orders)
  List<String> tagss = [];      // أسماء الأقسام (لـ UI Tabs)
  bool supportsTakeaway=false;

  Map<String, dynamic> _sanitizeItem(Map<String, dynamic> item,{String? sectionName}) {
    return {
      "id": item["id"]?.toString() ?? "",
      "title": item["name"]?.toString() ?? "",
      "description": item["description"]?.toString() ?? "",
      "price": item["sale_price"]?.toString() ??
          item["base_price"]?.toString() ??
          "0",
      "image": (item["media_paths"] is List &&
          (item["media_paths"] as List).isNotEmpty)
          ? item["media_paths"][0].toString()
          : null,
      "status": item["status"]?.toString() ?? "available",
      "calories": item["calories"]?.toString() ?? "",
      "count": 0,
      "is_spicy": item["is_spicy"], // ← تأكد موجود
      "sold_count":item["sold_count"],
      "potsEmpty": false,
      "section": sectionName ?? "", // ← للفلترة
      "time": item["prep_time_minutes"] != null
          ? "${item["prep_time_minutes"]}"
          : null,
    };
  }
  List<String> mealCategoriesBackend = ["Breakfast", "Lunch", "Dinner"];
  List<dynamic> allMeals = [];
  Future<void> menus(BuildContext context, int branchId) async {
    ApiService api = ApiService();


    final res = await api.get(
      "v1/guest/branches/$branchId/menus",
      {
     //   "meal_period":"Lunch"
      },
      context,
    );
    if (res?["success"] == true) {
      menu = List<Map<String, dynamic>>.from(res["data"] ?? []);
      supportsTakeaway =
          menu.any((section) => section["supports_takeaway"] == true);

      List<dynamic> allItems = [];
      tagss.clear();

      for (var menuSection in menu) {
        final directItems = menuSection["items"] as List? ?? [];
        final sections = menuSection["sections"] as List? ?? [];

        if (sections.isEmpty) {
          // ما فيه sections — أضف مباشرة بدون section name
          allItems.addAll(directItems
              .map((e) => _sanitizeItem(Map<String, dynamic>.from(e))));
        } else {
          for (var i = 0; i < sections.length; i++) {
            final sectionName = sections[i]["name"]?.toString() ?? "Other";

            // أضف القسم للـ tabs فقط إذا ما موجود
            if (!tagss.contains(sectionName)) {
              tagss.add(sectionName);
            }

            final sectionItems = sections[i]["items"] as List? ?? [];
            allItems.addAll(sectionItems.map((e) =>
                _sanitizeItem(Map<String, dynamic>.from(e),
                    sectionName: sectionName)));
          }
        }
      }

      allMeals = allItems; // احفظ كل الوجبات
      meals = allItems;    // عرض الكل افتراضياً
      isSelectedMenu = -1; // reset للـ default


      ref.notifyListeners();
    } else {
      ToastMessages(
        context,
        res?["message"] ?? "خطأ في جلب المنيو",
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }

  /// إعادة عرض كل الوجبات
  void resetMenu() {
    isSelectedMenu = -1;
    meals = allMeals;
    ref.notifyListeners();
  }

  int? currentOrderId;

  List<dynamic> review = [];
  Future<void> reviews(BuildContext context, int branchId) async {
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId/reviews",
      {

      },
      context,
    );
    if (response != null && response['data'] != null) {
      final items = response['data']['data'];
      review = List<Map<String, dynamic>>.from(items ?? []);
    }
    ref.notifyListeners();
  }

  List<dynamic> branches = [];
  bool isFetchingBranch = true;
  Future<void> branche(BuildContext context, int? branchId) async {
    branches.clear();
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId",
      {},
      context,
    );
    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {

      branches = [response['data']];
      if (branchId != null) {
        favoriteStatus[branchId] = response['data']['is_favorited'] == true;
      }
    } else {
      branches = [];
    }
    isFetchingBranch = false;
    ref.notifyListeners();
  }

  List<dynamic> policies = [];

  Future<void> branchPolicies(BuildContext context, int branchId) async {
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId/policies",
      {},
      context,
    );

    if (response?["success"] == true) {
      final data = response?["data"];
      if (data is List) {
        policies = List<dynamic>.from(data);
      } else if (data is Map) {
        policies = [data];
      } else {
        policies = [];
      }
      ref.notifyListeners();
    }
  }

  List<dynamic> garage = [];
  Future<void> garages(BuildContext context, int? branchId) async {
    garage.clear();
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId/parking",
      {},
      context,
    );
    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {

      garage = [response['data']];
    } else {
      garage = [];
    }
   // print(garage);
    ref.notifyListeners();
  }
  List<dynamic> superGuests = [];
  Future<void> superGuests_(BuildContext context, int? branchId) async {
    superGuests.clear();
    final response = await ApiService().get(
      "v1/$roles/branches/$branchId/super-guest",
      {},
      context,
    );
    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {

      superGuests = [response['data']];
    } else {
      superGuests = [];
    }
    ref.notifyListeners();
  }

  void changePage(int index){
    state = index;
    ref.notifyListeners();
  }
  int isSelectedMenu = -1;
  /// فلترة الوجبات حسب القسم المختار
  void changeMenu(int index) {
    isSelectedMenu = index;
    final sectionName = tagss[index];
    meals = allMeals
        .where((meal) => meal["section"] == sectionName)
        .toList();
    ref.notifyListeners();
  }
  void changePage_(int index){
    selectedCarouselIndex = index;
    ref.notifyListeners();
  }

  void increaseCount(Map<String, dynamic> item, BuildContext context, int branchId) {
    if (item['potsEmpty'] == false) {
      item['count'] = (item['count'] ?? 0) + 1;
      ref.notifyListeners();
    } else {
      showCustomDialog(context);
    }
  }

  void deleteMeal(int index, BuildContext context) {
    final meal = meals[index];
    final count = meal['count'] ?? 0;
    final cartItemId = meal['cart_item_id'];

    if (count > 1) {
      meal['count'] = count - 1;
      ref.notifyListeners();
      if (cartItemId != null) {
      }
    } else if (count == 1) {
      meal['count'] = 0;
      ref.notifyListeners();
      if (cartItemId != null) {
      }
    }
  }
  List<String> mealCategoriesUi = [
    TextLanguage().GetWord("إفطار"),
    TextLanguage().GetWord("غداء"),
    TextLanguage().GetWord("عشاء")
  ];
// القائمة التي تُرسل للباك اند (ثابتة بالإنجليزية)

  int selectedMealIndex = 0;
  bool isMenuExpanded = false;

  void toggleMenuExpansion() {
    isMenuExpanded = !isMenuExpanded;
    ref.notifyListeners();
  }

  void changeMenuIndex(int index, BuildContext context, int branchId) {
    selectedMealIndex = index;
    isMenuExpanded = false;
    ref.notifyListeners();
    menus(context, branchId);
  }

  Map<int, bool> favoriteStatus = {};

// ✅ دالة التفاعل لعمل Interest / Uninterest وتحديث العداد ديناميكياً
  Future<void> interest(BuildContext context, int branchId) async {
    ApiService api = ApiService();

    // جلب الحالة الحالية أو الافتراضية
    final bool isCurrentlyInterested = favoriteStatus[branchId] ?? (branches.isNotEmpty && branches[0]["is_favorited"] == true);

    // عكس الحالة محلياً فوراً
    favoriteStatus[branchId] = !isCurrentlyInterested;

    // ✅ [الحل]: تحويل الـ ID الخاص بالسيرفر إلى Int لضمان المطابقة دائماً (سواء رجع String أو Int)
    if (branches.isNotEmpty) {
      final int currentBranchId = int.tryParse(branches[0]["id"]?.toString() ?? "0") ?? 0;

      if (currentBranchId == branchId) {
        int currentCount = int.tryParse(branches[0]["interest_count"]?.toString() ?? "0") ?? 0;

        if (favoriteStatus[branchId] == true) {
          branches[0]["interest_count"] = currentCount + 1;
        } else {
          branches[0]["interest_count"] = currentCount > 0 ? currentCount - 1 : 0;
        }
      }
    }

    ref.notifyListeners();

    // إرسال الطلب الفعلي للسيرفر بناءً على توثيق عقد v1/guest/favorites/toggle
    final res = await api.post(
      "v1/guest/favorites/toggle",
      {
        "item_id": branchId.toString(),
        "type": "branch", // الاهتمام بالفروع يرسل كـ branch
      },
      context,
    );

    // إذا فشل الطلب لأي سبب، نعيد الحالة الأصلية حماية للبيانات
    if (res == null || res["success"] != true) {
      favoriteStatus[branchId] = isCurrentlyInterested;
      // إعادة العداد الأصلي
      if (branches.isNotEmpty && branches[0]["id"] == branchId) {
        int currentCount = int.tryParse(branches[0]["interest_count"]?.toString() ?? "0") ?? 0;
        if (isCurrentlyInterested) {
          branches[0]["interest_count"] = currentCount + 1;
        } else {
          branches[0]["interest_count"] = currentCount > 0 ? currentCount - 1 : 0;
        }
      }
      ref.notifyListeners();
    }
  }
}

final RestaurantDetalis_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
/*
  Future<void> addItemToCart({
    required BuildContext context,
    required int branchId,
    required String menuItemId,
    required int quantity,
    String? notes,
    String? cookingMethod,
    String? doneness,
  }) async {
    final response = await ApiService().post(
      "v1/$roles/cart/items",
      {
        "branch_id": branchId,
        "menu_item_id": menuItemId,
        "quantity": quantity,
        "order_type": "dine_in",
        if (notes != null && notes.isNotEmpty) "notes": notes,
        if (cookingMethod != null) "cooking_method": cookingMethod,
        if (doneness != null) "doneness": doneness,
      },
      context,
    );
    print("addItemToCart: $response");
  }

  Future<void> removeCartItem({
    required BuildContext context,
    required int cartItemId,
  }) async {
    final response = await ApiService().delete(
      "v1/guest/cart/items/$cartItemId",
      context,
      null,
    );
    print("removeCartItem: $response");
  }

  Future<void> updateCartItem({
    required BuildContext context,
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await ApiService().patch(
      "v1/guest/cart/items/$cartItemId",
      {"quantity": quantity},
      context,
    );
    print("updateCartItem: $response");
  }
 */