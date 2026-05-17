import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Widget/ShowLoading.dart';
import '../Service/LoadingService.dart';
import '../Utils/Them.dart';
Widget WidgetButton({
  required BuildContext context,
  required String buttonText,
  required VoidCallback onPressed,
   double width=130,
  required Color backgroundColor,
  Color textColor = Colors.white,
  double buttonSize = 16.0,
  bool isCircular = false,
  Color borderColor = Colors.transparent,
  double borderWidth = 1,
  bool isLoading = false,
}) {
  return TextButton(
    onPressed: isLoading ? null : onPressed,
    style: TextButton.styleFrom(
      backgroundColor: isLoading?backgroundColor.withOpacity(0.7):backgroundColor, // لون الخلفية
      side: BorderSide(color: borderColor,width:borderWidth), // لون وحواف البوردر
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isCircular ? 30 : 8), // زوايا دائرية اختيارية
      ),
      minimumSize: Size(width, 10), // عرض وارتفاع الزر
    ),
    child:isLoading? SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: textColor,
      ),
    ):Text(
      buttonText,
      style: TextStyle(
        color: textColor,
        fontSize: buttonSize,
      ),
    ),
  );
}

Widget ImageButton({
  required BuildContext context,
  required String imagePath,
  required VoidCallback onPressed,
  double widthFactor = 7.0,
}) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero, // لإزالة الحشو الافتراضي
      backgroundColor: Colors.transparent, // يمكن تغيير الخلفية حسب الحاجة
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // زوايا دائرية
      ),
    ),
    child: Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width:widthFactor, // تعديل الحجم حسب النسبة
    ),
  );
}

Widget SquareButton({
  required double width,
  required double height,
  required VoidCallback onTap,
  required Widget child,
  Color backgroundColor = Colors.blue,
  Color borderColor = Colors.transparent,
  double borderWidth = 1.0,
  double borderRadius = 8.0,
  double elevation = 0,
  bool isLoading = false,
  Color loadingColor = Colors.white,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isLoading ? backgroundColor.withOpacity(0.7) : backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
          width: height * 0.4,
          height: height * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Themes().GetColor("textPrimary"),
          ),
        )
            : child,
      ),
    ),
  );
}

CircularButton({
  required double size,
  required VoidCallback onTap,
  Widget? child,

  Color? backgroundColor, // اختياري
  Color? borderColor,     // اختياري
  double borderWidth = 0.8,
}) {
  Themes theme = Themes();

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? theme.GetColor("backgroundColor"),
        border: Border.all(
          color: borderColor ?? theme.GetColor("primary") ?? Colors.grey,
          width: borderWidth,
        ),
      ),
      child: Center(child: child),
    ),
  );
}