import 'package:flutter/material.dart';

class CarouselIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final double indicatorHeight;
  final double indicatorSpacing;
  final Color activeColor;
  final Color inactiveColor;

  const CarouselIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.indicatorHeight = 8,
    this.indicatorSpacing = 4,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFD3E9F8),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
            (i) {
          final bool isCurrent = currentIndex == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isCurrent
                ? indicatorHeight * 2.5
                : indicatorHeight,
            height: indicatorHeight,
            margin: EdgeInsets.symmetric(
              horizontal: indicatorSpacing,
            ),
            decoration: BoxDecoration(
              color: isCurrent ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
