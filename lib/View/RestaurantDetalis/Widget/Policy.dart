import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../RestaurantDetalis_riverpod.dart';
Widget Policy(BuildContext context, WidgetRef ref) {
  final policies = ref.read(RestaurantDetalis_riverpod.notifier).policies;
  if (policies.isEmpty) return const SizedBox.shrink();
  final policy = policies[0];
  final general = policy["general"];
  if (general is! List || general.isEmpty) return const SizedBox.shrink();
  return Column(
    children: [
      for (final item in general)
        infow(
          icon: _getIcon(item["key"]),
          text: item["title"]?.toString() ?? "",
          subtext: item["description"]?.toString() ?? "",
        ),
    ],
  );
}
String _getIcon(String? key) {
  switch (key) {
    case "dress_code":          return "assets/icon/Bowknot.svg";
    case "children_policy":     return "assets/icon/children.svg";
    case "behavior":            return "assets/icon/Behavior.svg";
    case "photography_smoking": return "assets/icon/PhotographySmoking.svg";
    default:                    return "assets/icon/Reservations.svg";
  }
}
class infow extends StatelessWidget {
  final String icon;
  final String text;
  final String subtext;
  const infow({super.key,required this.text,required this.icon,required this.subtext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon,color:Themes().GetColor("primaryA"),),
        SizedBox(width: Sizes(context).GetWidth()*2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TextLanguage().GetWord(text)),
              Text(subtext),
            ],
          ),
        ),
      ],
    );
  }
}
