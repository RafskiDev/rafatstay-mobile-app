import 'package:flutter/material.dart';
class GradientText extends StatelessWidget {
  final Widget widget;
  GradientText({required this.widget});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF122329),
          Color(0xFFC19343),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child:widget,
    );
  }
}