import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Themes extends GetxController {
  final theme = GetStorage();
  Map<String, Object> WhiteTheme = {
    "background": Color(0xFFF4EBD7),
    "backgroundLight": Color(0xFFEAD8AE), // 👈 هنا أضفنا اللون الجديد
    "backgroundOffWhite": Color(0xFFFAF5EB),
    "scaffoldBackground": Color(0xFFF5F5F5),
    "primary": Color(0xFFC19632),
    "primaryA":Color(0xFFA27E2A),
    "primaryS":Color(0xFFD5B15D),
    "secondaryPrimary":Color(0xFF795E20),
    "secondary":Color(0xFF7BBCEA),
    "secondary500": Color(0xFF082133), // هنا اللون الجديد
    "accent": Colors.blueAccent,
    "textPrimary": Colors.black,
    "textSecondary": Colors.grey,
    "icon": Colors.grey,
    "iconActive": Colors.blue,
    "borderLight":Color(0xFFD3E9F8),
    "divider": Colors.grey.shade300,
    "error": Colors.red,
    "success": Colors.green,
    "warning": Colors.orange,
    "white": Colors.white,
  };

  Map<String, Object> DarkTheme = {
    "backgroundColor": Color(0xFF121212),
  };

  GetColor(key) {
    theme.writeIfNull("Theme", 2);

    if (theme.read('Theme') == 2) {
      return WhiteTheme[key];
    } else {
      return DarkTheme[key];
    }
  }

  ChangeTheme() {
    theme.writeIfNull("Theme", 2);
    if (theme.read('Theme') == 1) {
      theme.write('Theme', 2);
    } else {
      theme.write('Theme', 1);
    }

    update();
  }
}