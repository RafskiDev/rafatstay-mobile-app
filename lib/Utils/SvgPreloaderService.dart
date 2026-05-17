import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgPreloaderService {
  /// هذه الدالة تبحث عن جميع ملفات الـ SVG وتحملها في الذاكرة
  static Future<void> loadAll(List<String> assetPaths) async {
    try {
      // 1. قراءة الـ Manifest لمعرفة جميع الملفات الموجودة في الـ Assets
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestJson);

      // 2. تصفية الملفات التي تنتهي بـ .svg وتوجد في المسارات المطلوبة
      final svgPaths = manifestMap.keys.where((String key) {
        return assetPaths.any((path) => key.startsWith(path)) && key.endsWith('.svg');
      }).toList();

      print('⏳ جاري تحميل ${svgPaths.length} صورة SVG...');

      // 3. التحميل الفعلي لكل صورة في الكاش
      for (String path in svgPaths) {
        final loader = SvgAssetLoader(path);
        // نضع محتوى الصورة في الكاش ليكون جاهزاً فوراً عند الطلب
        await svg.cache.putIfAbsent(
            loader.cacheKey(null),
                () => loader.loadBytes(null)
        );
      }

      print('✅ تم تحميل جميع الصور بنجاح');
    } catch (e) {
      print('❌ خطأ في التحميل المسبق: $e');
    }
  }
}