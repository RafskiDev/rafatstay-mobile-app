import 'package:flutter/material.dart';

class InterestCard extends StatelessWidget {
  final String logoUrl;
  final String businessName;
  final String branchName;
  final VoidCallback onTap;
  final double width;
  final double height;

  const InterestCard({
    super.key,
    required this.logoUrl,
    required this.businessName,
    required this.branchName,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // اللون البيج الفاتح المريح المطابق تماماً للصورة المعطاة
          color: const Color(0xFFFAF6F0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // 1. الشعار الدائري للمطعم والشركة
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF70551A), // درجة اللون الزيتوني/البني المطابقة للخلفية
              backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
              child: logoUrl.isEmpty
                  ? const Icon(Icons.store, color: Colors.white, size: 24)
                  : null,
            ),
            const SizedBox(width: 14),

            // 2. النصوص (اسم الشركة + اسم الفرع بجانبه)
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                      text: "$businessName ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: branchName,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. زر السهم الدائري الجانبي (الأكشن)
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3EBE1), // خلفية دائرية أغمق قليلاً للتأثير البصري المتقن
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF4A453E), // لون خط أيقونة السهم
              ),
            ),
          ],
        ),
      ),
    );
  }
}