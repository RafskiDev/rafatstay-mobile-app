import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/View/Maps/Maps.dart';
import '../../Service/ApiService.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../../Widget/ContentCard.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/TableCard.dart';
import '../../Widget/WidgetButton.dart';
import '../AvailableTables/AvailableTables.dart';
import '../MakeItYourWay/MakeItYourWay.dart';
import 'EventBooking_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Widget/CapsuleTabButton.dart';
import 'Widget/EventDateFormatter.dart';
import 'Widget/_buildDateCard.dart';
class EventBooking extends ConsumerStatefulWidget {
  final Map<String, dynamic> eventBooking;
  const EventBooking({super.key, required this.eventBooking});

  @override
  ConsumerState<EventBooking> createState() => _EventBookingState();
}

class _EventBookingState extends ConsumerState<EventBooking> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(EventBooking_riverpod.notifier).resetBooking();
    });
    Future.microtask(() async {
      await ref.read(EventBooking_riverpod.notifier).event(
        context,
        widget.eventBooking["id"],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(EventBooking_riverpod);
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();
    final selectedIndex = ref.watch(EventBooking_riverpod);
    final tabTitles = ref.watch(EventBooking_riverpod.notifier).tabTitles;
    final menuItems = ref.watch(EventBooking_riverpod.notifier).menuItems;
    final notifier = ref.watch(EventBooking_riverpod.notifier);
    final event = notifier.eventData;
   // print("event: $event");
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) return showLoading();
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        widget.eventBooking["image"] ?? "",
                      //  fit: BoxFit.fill,
                        width: double.infinity,
                        height: sizes.GetHeight() * 28,
                        errorBuilder: (_, __, ___) => Image.asset(
                          "assets/images/1c07e950ad312fdaaef1bdd4e1882d79f25c9233.png",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -sizes.GetHeight() * 6.5,
                      left: 0,
                      right: 0,
                      child: Center(
                          child: Container(
                            width: sizes.GetWidth() * 95,
                            height: 67,
                            padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
                            decoration: BoxDecoration(
                              color: const Color(0x5CDFC486),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x47CEAB44),
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    event["title"] ?? "",
                                    style: TextStyle(
                                      fontSize: sizes.GetHeight() * 2.8,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(
                                          0xFF1E3A5F), // تأكد من إضافة لون غامق للنص ليظهر بوضوح
                                    )
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.GetColor("backgroundOffWhite"),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                            event["price"] ?? "0",
                                            style: TextStyle(
                                                color: theme.GetColor(
                                                    "secondaryPrimary"))
                                        ),
                                        SizedBox(width: sizes.GetWidth() * 1),
                                        SvgPicture.asset(
                                            "assets/icon/SAR.svg",
                                            color: theme.GetColor(
                                                "secondaryPrimary")
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 8),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sizes.GetWidth() * 2),
                    child: Column(
                      children: [
                        _buildJoinedSection(sizes,event),
                        SizedBox(height: sizes.GetHeight() * 2),
                        Row(
                          children: [
                            buildDateCard(
                              sizes: sizes,
                              svg: "assets/icon/Calendar.svg",
                              title_1: EventDateFormatter.date(
                                  event["starts_at"]),
                              title_2: EventDateFormatter.day(
                                  event["starts_at"]),
                              title_3: EventDateFormatter.time(
                                  event["starts_at"], event["ends_at"]),
                            ),
                            SizedBox(width: sizes.GetWidth() * 1),
                            buildDateCard(
                              sizes: sizes,
                              svg: "assets/icon/_location.svg",
                              title_1: widget.eventBooking["business_name"] ??
                                  "",
                              title_2: widget.eventBooking["location"] ?? "",
                              underline: true,
                              onTap:(){
                                print(widget.eventBooking);
                                /*
                                Navigator.push(context, PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => Maps(restaurantLat: restaurantLat, restaurantLng: restaurantLng),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ));

                                 */
                              }
                            ),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        Row(
                          children: [
                            GradientText(
                                widget: Text(
                                    textLanguage.GetWord("نبذة عن الفعالية"),
                                    style: TextStyle(
                                      fontSize: sizes.GetHeight() * 2.8,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 1),
                        Row(
                          children: [
                            Expanded(child: Text(
                              event["description"] ?? "",
                              style: TextStyle(
                                  color: theme.GetColor("textSecondary")),)),
                          ],
                        ),
                        if (menuItems.isNotEmpty)...[
                          SizedBox(height: sizes.GetHeight() * 2),
                          Row(
                            children: [
                              GradientText(
                                  widget: Text(
                                      textLanguage.GetWord("اختر مشروبك المفضل"),
                                      style: TextStyle(
                                        fontSize: sizes.GetHeight() * 2.8,
                                        fontWeight: FontWeight.w500,
                                      )
                                  )
                              ),
                            ],
                          ),
                          SizedBox(height: sizes.GetHeight() * 3),
                        ],
                        Row(
                          children: List.generate(
                            menuItems.length,
                                (index) =>
                                CapsuleTabButton(
                                  text: tabTitles[index],
                                  isSelected: selectedIndex == index,
                                  onTap: () {
                                    ref
                                        .read(EventBooking_riverpod.notifier)
                                        .changePage(index);
                                    print("تم اختيار: ${tabTitles[index]}");
                                  },
                                ),
                          ),
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: sizes.GetWidth() * 1,
                            mainAxisSpacing: sizes.GetWidth() * 2,
                            mainAxisExtent: sizes.GetHeight() * 25,
                          ),
                          itemCount: notifier.currentItems.length,
                          itemBuilder: (context, index) {
                            if (index >= notifier.currentItems.length) return SizedBox();
                            final meal = notifier.currentItems[index];
                            return MealCard(
                                item: meal,
                                sizes: sizes,
                                theme: theme,
                                onTap: () {
                                  final itemId = int.tryParse(meal["id"].toString()) ?? 0;
                                  ref.read(EventBooking_riverpod.notifier).incrementItem(itemId);
                                },
                             //   hideQuantityControls:true,
                                onTapDelete: () {
                                  final itemId = int.tryParse(meal["id"].toString()) ?? 0;
                                  ref.read(EventBooking_riverpod.notifier).decrementItem(itemId);
                                }
                            );
                          },
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        Row(
                          children: [
                            GradientText(
                                widget: Text(
                                    textLanguage.GetWord("اختر طاولتك"),
                                    style: TextStyle(
                                      fontSize: sizes.GetHeight() * 2.8,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: sizes.GetWidth() * 1,
                            mainAxisSpacing: sizes.GetWidth() * 1,
                            mainAxisExtent: sizes.GetHeight() * 21,
                          ),
                          itemCount: notifier.tables.length,
                          itemBuilder: (context, index) {
                            final table = notifier.tables[index];
                            final isSelected = notifier.selectedTableIndex ==
                                index;
                            final List mediaList = table['media_paths'] ?? [];
                            final String imageUrl = mediaList.isNotEmpty
                                ? mediaList[0]
                                : "";
                            return TableCard(
                              title: "Table #${table['table_number']?.toString() ??
                                  (index + 1).toString()}",
                              image:imageUrl,
                              subtitle: table['location_type']?.toString() ??
                                  "",
                              isChecked: isSelected,
                              isNetwork: (table['media_paths'] is List &&
                                  (table['media_paths'] as List).isNotEmpty),
                              onTap: () {
                                ref
                                    .read(EventBooking_riverpod.notifier)
                                    .selectTable(index, table['is_available']);
                              },
                              isAvailable: table['is_available'],
                              idTable:table["id"]??1,
                              bookingData:widget.eventBooking,
                            );
                          },
                        ),
                        SizedBox(height: sizes.GetHeight() * 2),
                        SquareButton(
                          width: sizes.GetWidth() * 55,
                          height: sizes.GetHeight() * 5.5,
                          borderRadius: sizes.GetHeight() * 5,
                          onTap: () {
                            final bookingNotifier = ref.read(EventBooking_riverpod.notifier);
                            if (bookingNotifier.selectedTableIndex == null || bookingNotifier.selectedTableIndex == -1) {
                              ToastMessages(
                                context,
                                textLanguage.GetWord("الرجاء اختيار طاولة لتتمكن من إتمام الحجز"),
                                Colors.red,
                                Colors.white,
                              );
                              return; // إيقاف العملية ومنع الانتقال
                            }
                            final selectedMeals = bookingNotifier.currentItems.where((meal) {
                              final itemId = int.tryParse(meal["id"].toString()) ?? 0;
                              final count = bookingNotifier.itemCounts[itemId] ?? 0;
                              return bookingNotifier.selectedItemIds.contains(itemId) && count >= 1;
                            }).toList();
                            if (bookingNotifier.selectedItemIds.isEmpty) {
                              ToastMessages(
                                context,
                                textLanguage.GetWord("الرجاء اختيار وجبة واحدة على الأقل"),
                                Colors.red,
                                Colors.white,
                              );
                              return;
                            }

                            if (selectedMeals.isEmpty) {
                              ToastMessages(
                                context,
                                textLanguage.GetWord("لا توجد وجبات متاحة"),
                                Colors.red,
                                Colors.white,
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    MakeItYourWay(
                                      title: bookingNotifier.eventData["title"] ?? "",
                                      businessName: widget.eventBooking["business_name"] ?? '',
                                      branchId: widget.eventBooking["branch_id"]??0,
                                      selectedMeals: selectedMeals,
                                      bookingType:'eventBooking',
                                    ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                            /*
                             final selectedMeals = [
                              {
                                "id": 1,
                                "title": "Mojito",
                                "price": "25",
                                "count": 2,
                                "sold_count":"10",
                                "time": null,
                                "is_spicy": null,
                                "potsEmpty": false,
                              },
                            ];
                             */
                          },
                          backgroundColor: theme.GetColor("primaryA"),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                textLanguage.GetWord("احجز الآن"),
                              ),
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..scale(
                                      Directionality.of(context) == TextDirection.rtl
                                          ? -1.0
                                          : 1.0,
                                      1.0),
                                  child: SvgPicture.asset("assets/icon/arrow.svg"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: sizes.GetHeight() * 6),
                      ],
                    )),
              ],
            ),
          );
        }
      ),
    );
  }
}

Widget _buildJoinedSection(Sizes sizes, Map<String, dynamic> data) {
  double overlapWidth = 25.0;
  double avatarSize = 45.0;

  List participants = data["participants"] ?? [];
  int avatarsToShow = participants.length > 3 ? 3 : participants.length;


  return Row(
    children: [
      SizedBox(
        width: (avatarSize * avatarsToShow) - (overlapWidth * (avatarsToShow - 1)),
        height: avatarSize,
        child: Stack(
          children: List.generate(avatarsToShow, (index) {
            return _buildAvatar(
              index,
              participants[index]["avatar"],
              avatarSize,
              overlapWidth,
            );
          }),
        ),
      ),
      participants.isNotEmpty? SizedBox(width: sizes.GetWidth()*3): SizedBox.shrink(),
      Builder(
        builder: (context) {
          int count = data["participants_count"] ?? 0;
          return Text(
            "${count > 99 ? "+$count" : count} ${TextLanguage().GetWord("انضم الناس إلى هذا الحدث")}",
            style: TextStyle(
              color: const Color(0xFF0F2D37),
              fontSize: sizes.GetHeight() * 1.8,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    ],
  );
}

Widget _buildAvatar(int index, String imagePath, double size, double overlap) {
  return Positioned(
    left: index * overlap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF5EEDB), width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          "${imagePath}",
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );
}