import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class CapsuleTabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const CapsuleTabButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF1E78B3);
    const Color inactiveColor = Color(0xFF63A0DF);
    const Color activeTextColor = Colors.white;
    const Color inactiveTextColor = inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: activeColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: isSelected ? activeTextColor : inactiveTextColor,
            ),
          ),
        ),
      ),
    );
  }
}