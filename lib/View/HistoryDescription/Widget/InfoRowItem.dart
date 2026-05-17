import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/WidgetButton.dart';

class InfoRowItem extends StatelessWidget {
  final String svgIcon;
  final String label;
  final String value;

  const InfoRowItem({
    super.key,
    required this.svgIcon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          SvgPicture.asset(
            svgIcon,
          ),
          SizedBox(width:Sizes(context).GetWidth()*1),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          WidgetButton(
            context: context,
            buttonText:value,
            onPressed: () {},
            isCircular:true,
            textColor: Themes().GetColor("textPrimary"),
            borderColor: Themes().GetColor("textPrimary"),
            backgroundColor:Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class InfoRowList extends StatelessWidget {
  final List<Map<String, String>> items;

  const InfoRowList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InfoRowItem(
                svgIcon: item['icon']!,
                label: item['label']!,
                value: item['value']!,
              ),
            ],
          );
        }),
      ),
    );
  }
}