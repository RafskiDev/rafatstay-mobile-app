import 'package:flutter/cupertino.dart';
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  const GradientBorderContainer({
    Key? key,
    required this.child,
    required this.gradient,     // التدرج اللوني للإطار
    this.borderWidth = 1.5,     // سماكة الإطار
    required this.borderRadius, // انحناء الحواف
    required this.backgroundColor, // لون الخلفية (البيج)
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        gradient: gradient, // هنا يظهر التدرج كلون للإطار الخلفي
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth), // المسافة التي تصنع سماكة الإطار
        child: Container(
          padding: padding, // الـ Padding الداخلي للمحتوى
          decoration: BoxDecoration(
            color: backgroundColor, // لون الخلفية يغطي التدرج في الوسط
            borderRadius: borderRadius, // نفس الانحناء
          ),
          child: child,
        ),
      ),
    );
  }
}