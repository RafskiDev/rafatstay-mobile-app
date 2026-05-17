import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
class PageNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }
  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      // طلب الإذن
      PermissionStatus result = await Permission.location.request();
      if (result.isGranted) {
        print("تم تفعيل الموقع");
      } else {
        print("تم رفض طلب الموقع");
      }
    } else if (status.isGranted) {
      print("الموقع مفعل بالفعل");
    } else if (status.isPermanentlyDenied) {
      // فتح إعدادات التطبيق لإعطاء الصلاحية يدويًا
      openAppSettings();
    }
  }
}
final LocationPrompt_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
