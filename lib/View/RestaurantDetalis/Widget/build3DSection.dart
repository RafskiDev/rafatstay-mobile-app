import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/VideoImageCard.dart';
import '../../../Widget/WidgetCustomDialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../WebView3DViewer/WebView3DViewer.dart';
Widget build3DSection(Map<String, dynamic>? scene, Sizes sizes, Themes theme, TextLanguage textLanguage,BuildContext context) {
  if (scene == null || scene.isEmpty) {
    return const SizedBox.shrink();
  }

  final String status = scene['status'] ?? 'pending';
  if (status != 'pending' && status != 'completed') {
    return const SizedBox.shrink();
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: sizes.GetHeight() * 2),
      Row(
        children: [
          SvgPicture.asset(
            "assets/icon/3D.svg",
            height: sizes.GetHeight() * 2,
          ),
          SizedBox(width: sizes.GetWidth() * 1),
          Text(
            textLanguage.GetWord("مطعم بإطلالة كاملة"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: sizes.GetHeight() * 2,
            ),
          ),
        ],
      ),
      SizedBox(height: sizes.GetHeight() * 2),

      // 2. إذا كانت الحالة قيد التنفيذ (Pending)
      if (status == 'pending')
        Container(
          width: double.infinity,
          height: sizes.GetHeight() * 25,
          decoration: BoxDecoration(
            color: theme.GetColor("backgroundOffWhite"),
            borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.orange),
                const SizedBox(height: 15),
                Text(
                  textLanguage.GetWord("جاري تجهيز المشهد ثلاثي الأبعاد..."),
                  style: TextStyle(
                    color: theme.GetColor("textSecondary"),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )

      else if (status == 'completed' && scene['viewer_url'] != null)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebView3DViewer(
                  url: scene['viewer_url'],
                ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                child: CachedNetworkImage(
                  imageUrl: scene['panorama_url'] ?? "",
                  width: double.infinity,
                  height: sizes.GetHeight() * 25,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => VideoImageCard(
                    imagePath: "assets/images/66fed65c893473ef90356d043c26c12940be6cf5.png",
                    width: double.infinity,
                    height: sizes.GetHeight() * 25,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: sizes.GetHeight() * 25,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
                ),
              ),
              // أيقونة البدء التفاعلية الـ 3D
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebView3DViewer(
                            url: scene['viewer_url'],
                          ),
                        ),
                      );
                    },
                    child:ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: Sizes(context).GetHeight() * 9,
                          height: Sizes(context).GetHeight() * 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.25), // شفافية زجاج
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 0.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child:Container(
                            width: Sizes(context).GetHeight() * 6,
                            height: Sizes(context).GetHeight() * 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Themes().GetColor("backgroundOffWhite"),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/icon/play_arrows.svg",
                              height: Sizes(context).GetHeight() * 4, // أيقونة أصغر داخل الدائرة
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      else
        const SizedBox.shrink(),
    ],
  );
}
