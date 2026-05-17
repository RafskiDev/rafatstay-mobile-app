import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../BookingDetails/BookingDetails.dart';
import '../BookingDetailsSummary/BookingDetailsSummary.dart';
import '../BookingDetailsTakeaway/BookingDetailsTakeaway.dart';
import '../MakeItYourWay/MakeItYourWay_riverpod.dart';
import '../TableDetails/TableDetails.dart';
import 'AvailableTables_riverpod.dart';
class AvailableTables extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;
  const AvailableTables({super.key, required this.bookingData});

  @override
  ConsumerState<AvailableTables> createState() => _AvailableTablesState();
}

class _AvailableTablesState extends ConsumerState<AvailableTables> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(AvailableTables_riverpod.notifier).resetToDefault();
      if (!mounted) return;
      ref.read(AvailableTables_riverpod.notifier).fetchTables(
        context: context,
        branchId: widget.bookingData['branch_id'] as int?,
        date: widget.bookingData['booking_date']?.toString(),
        startTime: widget.bookingData['start_time']?.toString(),
        endTime: widget.bookingData['end_time']?.toString(),
        partySize: widget.bookingData['party_size'] as int?,
      );
      ref.read(AvailableTables_riverpod.notifier).fetchPolicies(
        context: context,
        branchId: widget.bookingData['branch_id'],
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(AvailableTables_riverpod);
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();
    final notifier = ref.read(AvailableTables_riverpod.notifier);
    final bool canContinue = notifier.selectedTableId != null && notifier.isChecked;
    final general = notifier.policiesData["general"] as List? ?? [];
    //هذا يجب ان ينتقل الى الوجها الي تعرض تفاصيل التيبل لنقل تاريخ وا غيرها bookingData
    //print(widget.bookingData);
  //  final booking = notifier.policiesData['booking'] as Map? ?? {};
    return Scaffold(
      appBar: buildCustomAppBar(context, "Available Tables"),
      backgroundColor: theme.GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable:LoadingService.isLoading,
          builder: (context, isLoading, child) {
             return isLoading?showLoading(): Container(
               padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
               child: SingleChildScrollView(
                 child: ValueListenableBuilder<bool>(
                     valueListenable: LoadingService.isLoading,
                     builder: (context, isLoading, child) {
                       return Column(
                         children: [
                           Text(textLanguage.GetWord("اختر الطاولة التي تناسبك")),
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
                               final isSelected = notifier.selectedTableIndex == index;
                               return TableCard(
                                 title: "Table #${table['id']?.toString() ?? (index + 1).toString()}",
                                 image: (table['media_paths'] is List &&
                                     (table['media_paths'] as List).isNotEmpty)
                                     ? "https://www.rafatstay.com${(table['media_paths'] as List)[0]}"
                                     : "assets/images/2509e72c5c9928d0f7ab2e1d37bd28c83c2c2603.png",
                                 subtitle: table['location_type']?.toString()??"",
                                 price: table['reservation_fee']?.toString()  ?? "0",
                                 isChecked: isSelected,
                                 isNetwork: (table['media_paths'] is List &&
                                     (table['media_paths'] as List).isNotEmpty),
                                 onTap: () {
                                   ref.read(AvailableTables_riverpod.notifier).selectTable(index,table['is_available']);
                                 },
                                 isAvailable:table['is_available'],
                                 idTable:table["id"]??1,
                               );
                             },
                           ),
                           SizedBox(height: sizes.GetHeight() * 2),
                           for (final item in general)...[
                             Row(
                               children: [
                                 Text(textLanguage.GetWord("السياسات"), style: const TextStyle(fontWeight: FontWeight.bold)),
                                 SizedBox(width: sizes.GetWidth() * 2),
                                 const Text("( Terms and Conditions )"),
                               ],
                             ),
                             IconWithTexts(
                               iconPath: _getPolicyIcon(item["key"]),
                               texts: [item["title"]?.toString() ?? ""],
                             ),
                           ],
                          //SizedBox(height: sizes.GetHeight() * 2),
                           Row(
                             children: [
                               InkWell(
                                 onTap: () => ref.read(AvailableTables_riverpod.notifier).setChecked(),
                                 child: SvgPicture.asset(
                                   notifier.isChecked
                                       ? "assets/icon/BOXCHECK_ON.svg"
                                       : "assets/icon/BOXCHECK_OFF.svg",
                                 ),
                               ),
                               SizedBox(width: sizes.GetWidth() * 2),
                               Text(textLanguage.GetWord("لقد قرأت ووافقت على جميع الشروط والأحكام")),
                             ],
                           ),
                           SizedBox(height: sizes.GetHeight() * 2),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               SquareButton(
                                 width: sizes.GetWidth() * 45,
                                 height: sizes.GetHeight() * 5,
                                 backgroundColor: canContinue
                                     ? theme.GetColor("primary")
                                     : theme.GetColor("primaryS"),
                                 borderRadius: sizes.GetHeight() * 5,
                                 elevation: 6,
                                 onTap: () async {
                                   if (!canContinue) return;
                                 //  final results= ref.read(MakeItYourWay_riverpod.notifier);
                                   final enrichedData = {
                                     ...widget.bookingData,
                                    // ...ref.read(MakeItYourWay_riverpod.notifier).getItemsForBooking(),
                                     'table_id': notifier.selectedTableId,
                                     'table_name': "Table #${notifier.selectedTableData['id']}",
                                     'location_type': notifier.selectedTableData['location_type'] ?? "",
                                     'table_price': notifier.selectedTableData['reservation_fee']?.toString() ?? "0",
                                   };
                                   //print(ref.read(MakeItYourWay_riverpod.notifier).getItemsForBooking());
                                   Navigator.push(
                                     context,
                                     PageRouteBuilder(
                                       pageBuilder: (context, animation1, animation2) =>
                                           BookingDetails(bookingData:enrichedData),
                                       transitionDuration: Duration.zero,
                                       reverseTransitionDuration: Duration.zero,
                                     ),
                                   );
                                   /*
                            final response = await ref
                                .read(AvailableTables_riverpod.notifier)
                                .createBooking(
                              context: context,
                              bookingData: widget.bookingData,
                            );
                            if (response?['success'] == true) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) =>
                                      BookingDetails(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            }

                             */
                                 },
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Text(textLanguage.GetWord('يكمل')),
                                     SizedBox(width: sizes.GetWidth() * 1),
                                     SvgPicture.asset("assets/icon/arrow.svg", height: sizes.GetHeight() * 2.5),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           SizedBox(height: sizes.GetHeight() * 7),
                         ],
                       );
                     }
                 ),
               ),
             );
          }

      ),
    );
  }
}
String _getPolicyIcon(String? key) {
  switch (key) {
    case "cancellation":        return "assets/icon/Reservations.svg";
    case "booking":             return "assets/icon/Reservations.svg";
    case "children_policy":     return "assets/icon/children.svg";
    case "behavior":            return "assets/icon/Behavior.svg";
    case "photography_smoking": return "assets/icon/PhotographySmoking.svg";
    case "dress_code":          return "assets/icon/Bowknot.svg";
    default:                    return "assets/icon/Reservations.svg";
  }
}
class IconWithTexts extends StatelessWidget {
  final String iconPath;
  final List<String> texts;

  const IconWithTexts({super.key, required this.iconPath, required this.texts});

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    return Row(
      children: [
        SvgPicture.asset(iconPath, color: Themes().GetColor("primary")),
        SizedBox(width: sizes.GetWidth() * 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: texts.map((text) => Text(text)).toList(),
          ),
        ),
      ],
    );
  }
}

class TableCard extends StatelessWidget {
  final int idTable;
  final String title;
  final bool isChecked;
  final String image;
  final String subtitle;
  final String? price;
  final bool isNetwork;
  final bool isAvailable;
  final VoidCallback onTap;

  const TableCard({
    super.key,
    required this.idTable,
    required this.title,
    required this.isChecked,
    required this.image,
    required this.subtitle,
    this.price,
    required this.onTap,
    required this.isAvailable,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();
    return Container(
      width: sizes.GetWidth() * 33,
      decoration: BoxDecoration(
        border: Border.all(
          color: isChecked ? theme.GetColor("primaryA") : theme.GetColor("secondary"),
          width: isChecked ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(15),
        color: isChecked ? theme.GetColor("primaryA").withOpacity(0.08) : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                bottom: BorderSide(color: theme.GetColor("textSecondary"), width: 2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetwork
                  ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/2509e72c5c9928d0f7ab2e1d37bd28c83c2c2603.png",
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: sizes.GetHeight() * 1),
          Padding(
            padding: EdgeInsets.all(sizes.GetHeight() * 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: theme.GetColor("primary"), fontWeight: FontWeight.w600),
                ),
                //
                isAvailable?InkWell(
                  onTap: onTap,
                  child: SvgPicture.asset(
                    color: isChecked ? theme.GetColor("primaryA") : theme.GetColor("textSecondary"),
                    isChecked ? "assets/icon/BOXCHECK_ON.svg" : "assets/icon/BOXCHECK_OFF.svg",
                  ),
                ):SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sizes.GetHeight() * 0.3),
            child: Row(
              mainAxisAlignment:price!=null?MainAxisAlignment.spaceAround:MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/icon/LocationTable.svg"),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if(price!=null)...[
                  Row(
                    children: [
                      SvgPicture.asset("assets/icon/dollar.svg"),
                      SizedBox(width: sizes.GetWidth() * 0.5),
                      Text(price!, style: const TextStyle(fontSize: 12)),
                      SizedBox(width: sizes.GetWidth() * 0.5),
                      SvgPicture.asset(
                        "assets/icon/SAR.svg",
                        color: theme.GetColor("textPrimary"),
                        height: sizes.GetHeight() * 1.7,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: sizes.GetHeight() * 1),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a1, a2) => TableDetails(idTable:idTable),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                "Table Details",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: theme.GetColor("primary"),
                  decorationColor: theme.GetColor("primary"),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}