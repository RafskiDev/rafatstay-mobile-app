import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Utils/Sizes.dart';
import '../Utils/TextLanguage.dart';
import '../Utils/Them.dart';
import '../View/TableDetails/TableDetails.dart';
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
  final Map<String, dynamic> bookingData;
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
    required this.bookingData, // تم الإضافة هنا
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();
    return Container(
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
              child: (image.isNotEmpty)
                  ? Image.network(
                image,
                fit: BoxFit.cover,
                height: sizes.GetHeight() * 8.5,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: sizes.GetHeight() * 8.5,
                  color: const Color(0xFFEEEEEE),
                  child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                ),
              )
                  : Container(
                width: double.infinity,
                height: sizes.GetHeight() * 8.5,
                color: const Color(0xFFEEEEEE),
                child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: sizes.GetHeight() * 1),
          Padding(
            padding: EdgeInsets.all(sizes.GetHeight() * 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize:12,color: theme.GetColor("primary"), fontWeight: FontWeight.w600),
                  ),
                ),
                //
                isAvailable?InkWell(
                  onTap: onTap,
                  child: SvgPicture.asset(
                    height: sizes.GetHeight() * 1.9,
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
              mainAxisAlignment: price != null ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/icon/LocationTable.svg",height: sizes.GetHeight() * 1.2),
                      SizedBox(width: sizes.GetWidth() * 0.5),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (price != null) ...[
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icon/dollar.svg",
                        height: sizes.GetHeight() * 1.2,
                      ),
                      SizedBox(width: sizes.GetWidth() * 0.5),
                      Text(price!, style: const TextStyle(fontSize: 10)),
                      SizedBox(width: sizes.GetWidth() * 0.5),
                      SvgPicture.asset(
                        "assets/icon/SAR.svg",
                        color: theme.GetColor("textPrimary"),
                        height: sizes.GetHeight() * 1.2,
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
                //  print(bookingData);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a1, a2) => TableDetails(
                      branchId: bookingData['branch_id'] as int? ?? 0,
                      tableId: idTable,
                      startTime: bookingData['starts_at']?.toString() ?? '',
                      endTime: bookingData['ends_at']?.toString() ?? '',
                      partySize: bookingData['party_size'] as int? ?? 1,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                TextLanguage().GetWord("تفاصيل الطاولة"),
                style: TextStyle(
                  fontSize: sizes.GetHeight() * 1.5,
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