import 'dart:async';
import 'package:flutter/material.dart';

class SplashImagesScreen extends StatefulWidget {
  final List<String> frames;
  final int fps; // سرعة الانتقال بين الصور
  final Widget nextScreen;

  const SplashImagesScreen({
    super.key,
    required this.frames,
    this.fps = 6, // بطيء
    required this.nextScreen,
  });

  @override
  State<SplashImagesScreen> createState() => _SplashImagesScreenState();
}

class _SplashImagesScreenState extends State<SplashImagesScreen> {
  int index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final frameDuration = Duration(milliseconds: (1000 / widget.fps).round());

    _timer = Timer.periodic(frameDuration, (t) {
      if (index < widget.frames.length - 1) {
        setState(() {
          index++;
        });
      } else {
        t.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.02, -0.28), // نفس 51.47% و 36.21%
            radius: 0.9, // قريب من 66%
            colors: const [
              Color(0xFFEAD8AE),
              Color(0xFFFFFFFF),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Center(
          child:Image.asset(
            widget.frames[index],
            fit: BoxFit.contain,
            gaplessPlayback: true,
          )
        ),
      ),
    );
  }
}
