import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/Sizes.dart';

import '../../../Utils/Them.dart';

class TableInfoBar extends StatelessWidget {
  final int tableNumber;
  final int price;
  final String location;

  const TableInfoBar({
    super.key,
    required this.tableNumber,
    required this.price,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color:Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _InfoChip(
            svgIcon: 'assets/icon/TableDetails.svg',
            text: 'Table #$tableNumber',
          ),
          const Spacer(),
          SvgPicture.asset(
            "assets/icon/dollar.svg",
            height: Sizes(context).GetHeight() * 2,
          ),
          SizedBox(width:Sizes(context).GetWidth()*1),
          SvgPicture.asset(
            "assets/icon/SAR.svg",
            height: Sizes(context).GetHeight() * 1.2,
            color: Themes().GetColor("textPrimary"),
          ),
          _InfoChip(
            svgIcon: 'assets/icon/price.svg',
            text: '$price',
          ),
          SizedBox(width: Sizes(context).GetWidth()*2),
          _InfoChip(
            svgIcon: 'assets/icon/LocationTable.svg',
            text: location,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String svgIcon;
  final String text;

  const _InfoChip({required this.svgIcon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgIcon,
        ),
        SizedBox(width: Sizes(context).GetWidth()*1),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}