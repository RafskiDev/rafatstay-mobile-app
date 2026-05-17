import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import '../Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
class CheckBox<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final double width;
  final double height;

  // المتغيرات الجديدة للـ border
  final Color? borderColor;
  final double borderWidth;

  CheckBox({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.width = 32,
    this.height = 32,
    this.borderColor,
    this.borderWidth = 2, // قيمة افتراضية للسمك
  });

  @override
  Widget build(BuildContext context) {
    final theme = Themes();
    return GestureDetector(
      onTap: () {
        onChanged(this.value);
      },
      child: Container(
        height: this.height,
        width: this.width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.GetColor("textPrimary"), // اللون الافتراضي
            width: borderWidth, // سمك الـ border
          ),
          /*
            gradient: LinearGradient(
              colors: [
                theme.GetColor("textPrimary"),
                theme.GetColor("textPrimary"),
              ],
            ),
             */
        ),
        child: Center(
          child: Container(
            height: this.height - 8,
            width: this.width - 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: value == groupValue
                    ? [
                  theme.GetColor("primary"),
                  theme.GetColor("secondaryPrimary"),
                ]
                    : [
                  theme.GetColor("background"),
                  theme.GetColor("background"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CheckBoxSvg extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const CheckBoxSvg({
    super.key,
    this.initialValue = false,
    required this.onChanged,
  });

  @override
  State<CheckBoxSvg> createState() => _CheckBoxSvgState();
}

class _CheckBoxSvgState extends State<CheckBoxSvg> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });

        // رجّع القيمة للخارج
        widget.onChanged(isChecked);
      },
      child: SvgPicture.asset(
        isChecked
            ? "assets/icon/BOXCHECK_ON.svg"
            : "assets/icon/BOXCHECK_OFF.svg",
      ),
    );
  }
}
