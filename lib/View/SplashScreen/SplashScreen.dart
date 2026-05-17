import 'package:flutter/material.dart';
import '../../Widget/SplashImagesScreen.dart';
import '../AppOverview/AppOverview.dart';
import '../BottomBar/BottomBar.dart';
import 'package:get_storage/get_storage.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    return SplashImagesScreen(
      frames: List.generate(6, (i) => 'assets/images/splash_logo_${i+1}.png'),
      fps: 2,
      nextScreen:Scaffold(
        body:storage.read("token")!=null? BottomBar(): AppOverview(),
      ),
    );
  }
}
