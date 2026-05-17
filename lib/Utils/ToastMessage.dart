import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

  void ToastMessages(BuildContext context, String message, Color color,Color colorText) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height*0.12,
        left:MediaQuery.of(context).size.width*0.1,
        right:MediaQuery.of(context).size.width*0.1,
        child: FadeTransition(
          opacity: ToastAnimation(context),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: color, // لون الخلفية
                border: Border.all(
                  color: Colors.transparent, // لون الإطار
                  width: 0.3, // سماكة الإطار
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color:colorText, fontFamily: "Cairo"),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // إظهار الرسالة لفترة محددة
    Future.delayed(const Duration(milliseconds: 2600), () {
      overlayEntry.remove();
    });
  }

  Animation<double> ToastAnimation(BuildContext context) {
    final controller = AnimationController(
      vsync:  TestVSync(), // تحتاج إلى توفير VSync
      duration:  Duration(milliseconds: 300),
    );

    // إعداد الرسوم المتحركة
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // بدء الرسوم المتحركة
    controller.forward();

    return animation;
  }


class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}