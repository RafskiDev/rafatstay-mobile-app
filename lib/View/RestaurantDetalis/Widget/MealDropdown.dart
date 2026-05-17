import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../RestaurantDetalis_riverpod.dart';
class MealDropdown extends ConsumerWidget {
  const MealDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   // final state = ref.watch(RestaurantDetalis_riverpod);
    final notifier = ref.read(RestaurantDetalis_riverpod.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => notifier.toggleMenuExpansion(),
          child:Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notifier.selectedMealIndex == -1
                    ? 'Select Menu'
                    : notifier.mealCategoriesUi[notifier.selectedMealIndex],
                style: const TextStyle(color: Color(0xFFC5A358), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notifier.isMenuExpanded ? Themes().GetColor("secondary500") : Themes().GetColor("background"),
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(
                  notifier.isMenuExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: notifier.isMenuExpanded ? Colors.white : Colors.black,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        if (notifier.isMenuExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(notifier.mealCategoriesUi.length, (index) {
              return InkWell(
                onTap: () => notifier.changeMenuIndex(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text(
                    notifier.mealCategoriesUi[index],
                    style: const TextStyle(color: Color(0xFFC5A358), fontSize: 16),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}