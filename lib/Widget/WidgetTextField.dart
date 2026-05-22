import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
class CustomOtpWidget extends StatefulWidget {
  final int fieldCount;
  final Future<bool> Function(String) onVerify;

  const CustomOtpWidget({
    super.key,
    required this.fieldCount,
    required this.onVerify,
  });

  @override
  State<CustomOtpWidget> createState() => _CustomOtpWidgetState();
}

class _CustomOtpWidgetState extends State<CustomOtpWidget> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers =
        List.generate(widget.fieldCount, (_) => TextEditingController());
    focusNodes = List.generate(widget.fieldCount, (_) => FocusNode());
  }

  String getOtp() => controllers.map((c) => c.text).join();

  void handleChange(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.fieldCount - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        widget.onVerify(getOtp());
      }
    } else {
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Themes();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.fieldCount, (index) {
        bool filled = controllers[index].text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 66,
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.GetColor("background"),
            border: Border.all(
              color: theme.GetColor("primary"),
              width: 1,
            ),
          ),
          child: Center(
            child: TextField(
              maxLength: 1,
              cursorColor: theme.GetColor("primary"),
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
             // style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],

              // 🔥 هنا منع الكتابة قبل ملء الخانة السابقة
              onChanged: (v) {
                if (index > 0 && controllers[index - 1].text.isEmpty) {
                  controllers[index].clear();
                  focusNodes[index - 1].requestFocus();
                  return;
                }
                handleChange(index, v);
              },
            ),
          ),
        );
      }),
    );
  }
}

class WidgetTextField extends StatefulWidget {
  final TextEditingController Controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool isPassword;
  final String HintText;
  final TextInputType keyboardType;
  final double Horizontal;
  final TextDirection hintTextDirection;
  final TextDirection textDirection;
  final bool isReadOnly;
  final int? maxLength;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormattersList;
  final String iconData;
  final Color? borderColor; // لون الاختياري للحدود
  final Color? backgroundColor; // لون الخلفية الاختياري
  final VoidCallback? onTap;
  final bool showEditIcon;
  final VoidCallback? onEditTap;    // عند الضغط على التعديل
  final void Function(String)? onChanged; // ✅ أضفنا هذه الخاصية الجديدة
  final Color? hintTextColor;
  final Color? iconColor;
  const WidgetTextField({
    super.key,
    required this.Controller,
    required this.focusNode,
    this.nextFocusNode,
    this.isPassword = false,
    this.HintText = '',
    this.keyboardType = TextInputType.text,
    this.Horizontal = 0,
    this.hintTextDirection = TextDirection.ltr,
    this.textDirection = TextDirection.rtl,
    this.isReadOnly = false,
    this.maxLength,
    this.onFieldSubmitted,
    this.inputFormattersList,
    required this.iconData,
    this.borderColor,        // اختياري
    this.backgroundColor,    // اختياري
    this.onTap,
    this.showEditIcon = false,
    this.onEditTap,
    this.onChanged,
    this.hintTextColor,
    this.iconColor,
  });

  @override
  State<WidgetTextField> createState() => _WidgetTextFieldSafeState();
}

class _WidgetTextFieldSafeState extends State<WidgetTextField> {
  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = Sizes(context);
    Themes theme = Themes();
   final storge= GetStorage();
    final selectedIndex = storge.read("Language") ?? 0;
    return Container(
      height: size.GetHeight() * 6,
      padding: EdgeInsets.symmetric(
          horizontal: widget.Horizontal, vertical: size.GetHeight() * 0.4),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.GetColor("background"), // الخلفية
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.focusNode.hasFocus && widget.isReadOnly==false
              ? theme.GetColor("primary")
              : (widget.borderColor ?? theme.GetColor("textSecondary")),
          width: 1.0,
        ),
      ),
      child: TextField(
        onTap: widget.onTap,
        controller: widget.Controller,
        readOnly: widget.isReadOnly,
        textDirection: widget.textDirection,
        keyboardType: widget.keyboardType,
        // obscureText: widget.isPassword,
        obscureText: _obscureText,
        focusNode: widget.focusNode,
        inputFormatters: widget.inputFormattersList,
        maxLength: widget.maxLength,
        cursorColor: theme.GetColor("primary"),
        style: const TextStyle(fontFamily: 'Cairo'),
        textAlign: selectedIndex==1?TextAlign.right:TextAlign.left,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.HintText,
          hintTextDirection: widget.hintTextDirection,
          hintStyle: TextStyle(
            fontFamily: "Cairo",
            fontSize: 13,
            color: widget.hintTextColor ?? theme.GetColor("textSecondary"),
          ),
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: (39 - 24) / 3,
            horizontal: size.GetHeight() * 1,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            icon: SvgPicture.asset(
              _obscureText
                  ? "assets/icon/eye_closed.svg"
                  : "assets/icon/eye_open.svg",
            ),
          )
              : widget.showEditIcon
              ? IconButton(
            onPressed: widget.onEditTap,
            icon: SvgPicture.asset(
              "assets/icon/edit.svg", // أيقونة التعديل
              color: theme.GetColor("primary"),
            ),
          )
              : null,
          prefixIcon: Padding(
            padding: EdgeInsets.all(size.GetHeight() *1),
            child:SvgPicture.asset(
              widget.iconData,
              color: widget.iconColor ?? (widget.focusNode.hasFocus && widget.isReadOnly == false
                  ? theme.GetColor("primary")
                  : theme.GetColor("textSecondary")),
              height: size.GetHeight() * 2,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: size.GetHeight() * 5,
            minHeight: size.GetHeight() * 3,
          ),
        ),
        onSubmitted: (value) {
          if (widget.nextFocusNode != null) {
            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          } else {
            widget.focusNode.unfocus();
          }
          if (widget.onFieldSubmitted != null) {
            widget.onFieldSubmitted!(value);
          }
        },
      ),
    );
  }
}

class ReviewTextField extends StatefulWidget {
  final String hintText;
  final VoidCallback? onTop; // أعيدت هنا
  final TextEditingController controller;

  const ReviewTextField({
    Key? key,
    required this.hintText,
    this.onTop, // ممررة في المشيد
    required this.controller,
  }) : super(key: key);

  @override
  State<ReviewTextField> createState() => _ReviewTextFieldState();
}

class _ReviewTextFieldState extends State<ReviewTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);

    // مراقبة الكيبورد: إذا نزل الكيبورد، نسحب التركيز فوراً
    bool isKeyboardClosed = View.of(context).viewInsets.bottom == 0;
    if (isKeyboardClosed && _focusNode.hasFocus) {
      Future.microtask(() => _focusNode.unfocus());
    }
    bool isEmpty = widget.controller.text.trim().isEmpty;
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // الرسم الخلفي
          CustomPaint(
            size: Size(double.infinity, sizes.GetHeight() * 20),
            painter: BottomRightCirclePainter(radius: sizes.GetHeight() * 2),
          ),

          // الحقل النصي
          Positioned(
            left: sizes.GetWidth() * 1,
            right: sizes.GetWidth() * 1,
            top: sizes.GetHeight() * 1,
            bottom: sizes.GetHeight() * 2,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
            //  onTap: widget.onTop,
              maxLines: null,
              cursorColor: _focusNode.hasFocus ? const Color(0xFFC0A060) : Colors.transparent,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sizes.GetWidth() * 2,
                  vertical: sizes.GetHeight() * 1,
                ),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          // الزر الدائري
          if (widget.onTop != null && !isEmpty)
          Positioned(
            right: sizes.GetWidth() * 2,
            bottom: sizes.GetHeight() * 0.7,
            child: GestureDetector(
              onTap:widget.onTop,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: sizes.GetWidth() * 12,
                height: sizes.GetWidth() * 12,
                decoration: BoxDecoration(
                  color:  Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomRightCirclePainter extends CustomPainter {
  final double radius; // نصف قطر الزوايا

  BottomRightCirclePainter({this.radius = 25.0});

  @override
  void paint(Canvas canvas, Size size) {
    // إعدادات اللون والتعبئة
    Paint paint = Paint()
      ..color = const Color(0xFFF2E1B9)
      ..style = PaintingStyle.fill;

    // إعدادات الإطار (Border)
    Paint borderPaint = Paint()
      ..color = const Color(0xFFC0A060)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // تعريف المستطيل المنحني الزوايا (Rounded Rectangle)
    RRect rRect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );

    // رسم الخلفية
    canvas.drawRRect(rRect, paint);

    // رسم الإطار
    canvas.drawRRect(rRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
