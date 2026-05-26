import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/TimeDate.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../AvailableTables/AvailableTables.dart';
import '../BookingDetails/BookingDetails.dart';
import '../BookingDetailsTakeaway/BookingDetailsTakeaway.dart';
import '../EventBooking/EventBooking_riverpod.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
import 'TimeValidationResult/TimeValidationResult.dart';
import 'SetYourBookingDetails_riverpod.dart';
class SetYourBookingDetails extends ConsumerStatefulWidget {
  final String businessName;
  final int branchId;
  final String? bookingType;
  final List<Map<String, dynamic>> includedItems;

  SetYourBookingDetails({
    required this.businessName,
    required this.branchId,
    this.includedItems = const [],
    this.bookingType,
    super.key,
  });

  @override
  ConsumerState<SetYourBookingDetails> createState() => _SetYourBookingDetailsState();
}

class _SetYourBookingDetailsState extends ConsumerState<SetYourBookingDetails> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(SetYourBookingDetails_riverpod.notifier).resetToDefault();
    });
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final sizes = Sizes(context);
    final pageState = ref.watch(SetYourBookingDetails_riverpod);
    final notifier = ref.read(SetYourBookingDetails_riverpod.notifier);
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar: buildCustomAppBar(context,textLanguage.GetWord("حدد تفاصيل حجزك")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text(textLanguage.GetWord("اختر التاريخ الذي يناسبك")),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              DynamicCalendar(), // ← تستدعي setDate مباشرة
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                children: [
                  Text(textLanguage.GetWord("اختر الوقت الذي يناسبك")),
                ],
              ),
              TimePickerRow(
                arrowHeight: sizes.GetHeight() * 3.3,
                arrowColor: theme.GetColor("textPrimary"),
                onTimeChanged: (String newTime) {
                  ref.read(SetYourBookingDetails_riverpod.notifier).setStartTime(newTime);
                },
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              GuestSelector(
                title: textLanguage.GetWord("كم عدد الضيوف؟"),
                icon: "assets/icon/user_plus.svg",
                count: notifier.guests,
                onIncrement: () {
                  ref.read(SetYourBookingDetails_riverpod.notifier).setGuests("+");
                },
                onDecrement: () {
                  ref.read(SetYourBookingDetails_riverpod.notifier).setGuests("-");
                },
                horizontalPadding: sizes.GetWidth() * 4,
                verticalPadding: sizes.GetHeight() * 1.2,
                iconSize: sizes.GetHeight() * 2.6,
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              GuestSelector(
                title: textLanguage.GetWord('كم عدد الأطفال؟'),
                icon: "assets/icon/children.svg",
                count: ref.read(SetYourBookingDetails_riverpod.notifier).children,
                onIncrement: () {
                  ref.read(SetYourBookingDetails_riverpod.notifier).setChildren("+");
                },
                onDecrement: () {
                  ref.read(SetYourBookingDetails_riverpod.notifier).setChildren("-");
                },
                horizontalPadding: sizes.GetWidth() * 4,
                verticalPadding: sizes.GetHeight() * 1.2,
                iconSize: sizes.GetHeight() * 2.6,
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                children: [
                  Text(textLanguage.GetWord("اختر الطريقة التي تفضلها لاستلام طلبك")),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Consumer(
                builder: (context, ref, _) {
                  final notifier = ref.watch(SetYourBookingDetails_riverpod.notifier);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ref.read(RestaurantDetalis_riverpod.notifier).supportsTakeaway==true?WidgetButton(
                        context: context,
                        buttonText: "Takeaway",
                        onPressed: () => notifier.selectButton(0),
                        width: sizes.GetWidth() * 25,
                        backgroundColor: Colors.transparent,
                        textColor: notifier.selectedButton == 0
                            ? theme.GetColor("textPrimary")
                            : theme.GetColor("textSecondary"),
                        buttonSize: sizes.GetHeight() * 2,
                        isCircular: true,
                        borderColor: notifier.selectedButton == 0
                            ? theme.GetColor("textPrimary")
                            : theme.GetColor("textSecondary"),
                        borderWidth: 1,
                      ):SizedBox.shrink(),
                      WidgetButton(
                        context: context,
                        buttonText: "Dine In",
                        onPressed: () => notifier.selectButton(1),
                        width: sizes.GetWidth() * 25,
                        backgroundColor: Colors.transparent,
                        textColor: notifier.selectedButton == 1
                            ? theme.GetColor("textPrimary")
                            : theme.GetColor("textSecondary"),
                        buttonSize: sizes.GetHeight() * 2,
                        isCircular: true,
                        borderColor: notifier.selectedButton == 1
                            ? theme.GetColor("textPrimary")
                            : theme.GetColor("textSecondary"),
                        borderWidth: 1,
                      ),
                      WidgetButton(
                        context: context,
                        buttonText: "Dine In To-Go",
                        onPressed: () => notifier.selectButton(2),
                        width: sizes.GetWidth() * 25,
                        backgroundColor: Colors.transparent,
                        textColor: notifier.selectedButton == 2
                            ? theme.GetColor("textPrimary")
                            : theme.GetColor("textSecondary"),
                        buttonSize: sizes.GetHeight() * 2,
                        isCircular: true,
                        borderColor: notifier.selectedButton == 2
                            ? theme.GetColor("textPrimary")
                            : theme.GetColor("textSecondary"),
                        borderWidth: 1,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareButton(
                    width: sizes.GetWidth() * 45,
                    height: sizes.GetHeight() * 5,
                    backgroundColor: theme.GetColor("primary"),
                    borderRadius: sizes.GetHeight() * 5,
                    elevation: 6,
                    onTap: () async {
                      /*
                      final selectedMeals = results.menuItems
                          .where((m) => results.selectedIds.contains(m["id"].toString()))
                          .toList();
                    //  print(selectedMeals);
                       */
                      final results= ref.read(MakeItYourWay_riverpod.notifier);
                      final data = notifier.collectBookingData(widget.branchId, widget.businessName);

                      if (data["booking_date"] == "" || data["booking_date"] == null) {
                        ToastMessages(
                          context,
                          "خطأ: لم يتم اختيار التاريخ",
                          Colors.red,
                          Colors.white,
                        );
                        return;
                      }
                      if (data["service_mode"] == null) {
                        ToastMessages(
                          context,
                          "خطأ: لم يتم اختيار طريقة استلام الطلب (Takeaway / Dine In)",
                          Colors.red,
                          Colors.white,
                        );
                        return;
                      }
                      final selectedDate = DateTime.tryParse(data["booking_date"]?.toString() ?? "");
                      final today = DateTime.now();
                      final todayDateOnly = DateTime(today.year, today.month, today.day);
                      if (selectedDate == null || selectedDate.isBefore(todayDateOnly)) {
                        ToastMessages(
                          context,
                          "يجب اختيار تاريخ اليوم أو بعده",
                          Colors.red,
                          Colors.white,
                        );
                        return; // لا تمر البيانات
                      }
                      final result = validateTime(data["start_time"], data["end_time"],notifier.startDate);
                      if (!result.isValid) {
                        ToastMessages(
                          context,
                          result.errorMessage.toString(),
                          Colors.red,
                          Colors.white,
                        );
                        print("خطأ في التحقق من الوقت: ${result.errorMessage}");
                        return;
                      }
                      final selectedMeals = results.getItemsForBooking(); // يفترض ترجّع List<Map<String,dynamic>>
                      Map<String, dynamic> enrichedData = {};
                      if(widget.includedItems.isNotEmpty){
                         enrichedData = {
                          ...data,
                          ...selectedMeals,
                          "items": widget.includedItems,
                        };
                      }else{
                         enrichedData = {
                          ...data,
                          ...ref.read(MakeItYourWay_riverpod.notifier).getItemsForBooking(),
                        };
                      }
                      if(widget.bookingType=="eventBooking"){
                        final selectedTable = ref.read(EventBooking_riverpod.notifier).selectedTable;
                        final enrichedDataWithTable = {
                          ...enrichedData,
                          if (selectedTable != null) ...selectedTable,
                        };
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                BookingDetails(bookingData: enrichedDataWithTable),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                        return;
                      }
                      if (data["service_mode"] == "takeaway") {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                BookingDetailsTakeaway(bookingData: enrichedData),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                        return;
                      } else if (data["service_mode"] == "dine_in_to_go") {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                AvailableTables(bookingData: enrichedData),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                        return;
                      } else if(data["service_mode"]=="dine_in") {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                AvailableTables(bookingData: enrichedData),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                        return;
                      }
                     // if()
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(textLanguage.GetWord('يكمل')),
                        SizedBox(width: sizes.GetWidth() * 1),
                        SvgPicture.asset(
                          "assets/icon/arrow.svg",
                          height: sizes.GetHeight() * 2.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 7),
            ],
          ),
        ),
      ),
    );
  }
}
class GuestSelector extends StatelessWidget {
  final String title;
  final String icon;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final Color borderColor;
  final Color circleColor;
  final Color iconColor;

  const GuestSelector({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    this.horizontalPadding = 16,
    this.verticalPadding = 8,
    this.iconSize = 24,
    this.borderColor = Colors.black,
    this.circleColor = Colors.black,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30), // الزوايا الدائرية
        border: Border.all(
          color: borderColor, // لون الحدود
          width: 1, // سمك الحدود
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              InkWell(
                onTap: onDecrement,
                child: SvgPicture.asset(
                  "assets/icon/DeleteBasket.svg",
                ),
              ),
              SizedBox(width: 8),
              Text(count.toString()),
              SizedBox(width: 8),
              InkWell(
                onTap: onIncrement,
                child: Container(
                  padding: EdgeInsets.all(iconSize * 0.3),
                  decoration: BoxDecoration(
                    color: circleColor, // لون الخلفية
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    icon,
                    color: iconColor,
                    height: iconSize,
                    width: iconSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}