import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/Sizes.dart';

import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';

class ParkingInfoCard extends StatelessWidget {
  final int price;
  final int hours;
  final String location;
  final String plateNumber;
  final String carColor;

  const ParkingInfoCard({
    super.key,
    required this.price,
    required this.hours,
    required this.location,
    required this.plateNumber,
    required this.carColor,
  });

  @override
  Widget build(BuildContext context) {
    TextLanguage textLanguage = TextLanguage();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          _InfoChip(
            svgIcon: 'assets/icon/Parking.svg',
            text:textLanguage.GetWord("موقف سيارات"),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
            iconSize: Sizes(context).GetHeight() * 2,
          ),
          SizedBox(height: Sizes(context).GetHeight() * 2),
          Wrap(
            spacing: 3,
            runSpacing: 6,
            children: [
              _InfoChip(svgIcon_: 'assets/icon/SAR.svg',iconSize:Sizes(context).GetHeight() * 2,svgIcon:'assets/icon/dollar.svg',text:'$price'),
              _InfoChip(svgIcon:'assets/icon/time.svg',text:'$hours ${textLanguage.GetWord("ساعة")}'),
              _InfoChip(svgIcon:'assets/icon/LocationTable.svg',text:location),
              _InfoChip(svgIcon:'assets/icon/ABC.svg',text:plateNumber),
              _InfoChip(svgIcon:'assets/icon/CarColor.svg',text:carColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String svgIcon;
  final String? svgIcon_;
  final String text;
  final TextStyle? textStyle;
  final double iconSize;

  const _InfoChip({
    required this.svgIcon,
     this.svgIcon_,
    required this.text,
    this.textStyle,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgIcon,
          height: iconSize,
        ),
        svgIcon_!=null?SizedBox(width: Sizes(context).GetWidth() * 1):const SizedBox(),
        svgIcon_!=null?SvgPicture.asset(
          svgIcon_!,
          height:Sizes(context).GetHeight() * 1.2,
          color:Themes().GetColor("textPrimary"),
        ):const SizedBox(),
        SizedBox(width: Sizes(context).GetWidth() * 1),
        Text(
          text,
          style: textStyle ?? const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}