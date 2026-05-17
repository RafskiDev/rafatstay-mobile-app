import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  const GradientBorderContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    return Container(
      width: sizes.GetWidth() * 100,
      height: sizes.GetHeight() * 12,
      child: CustomPaint(
        painter: _GradientBorderPainter(
          radius: 18,
          strokeWidth: 1,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Themes().GetColor("secondary500"),
              Themes().GetColor("primary"),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child, // أي محتوى تحطه
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
