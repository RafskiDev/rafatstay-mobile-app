import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/Them.dart';

import '../../../Utils/Sizes.dart';
class MealItem extends StatelessWidget {
  final String name;
  final int price;
  final int mealsCount;

  const MealItem({
    super.key,
    required this.name,
    required this.price,
    required this.mealsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE4),

      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icon/dollar.svg",
                ),
                SizedBox(width: Sizes(context).GetWidth() * 1),
                SvgPicture.asset(
                  "assets/icon/SAR.svg",
                  height: Sizes(context).GetHeight() * 1.2,
                ),
                SizedBox(width: Sizes(context).GetWidth() * 1),
                Text(
                  "$price",
                ),
              ],
            ),
          ),

          // Meals count
          Row(
            children: [
              SvgPicture.asset(
                "assets/icon/MealDetails.svg",
                height: Sizes(context).GetHeight() * 2,
              ),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              Text(
                "$mealsCount meals",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class MealsList extends StatelessWidget {
  final List<Map<String, dynamic>> meals;

  const MealsList({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(meals.length, (index) {
          final meal = meals[index];
          return MealItem(
            name: meal['name'],
            price: meal['price'],
            mealsCount: meal['mealsCount'],
          );
        }),
      ),
    );
  }
}

