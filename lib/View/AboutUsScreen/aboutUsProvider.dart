import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../Service/ApiService.dart';

// نموذج البيانات لفقرات شاشة "عن الشركة / About Us"
class AboutUsSection {
  final String title;
  final String? description;
  final List<String>? points;

  AboutUsSection({
    required this.title,
    this.description,
    this.points,
  });
}

class AboutUsNotifier extends Notifier<int> {
  final storage = GetStorage();


  @override
  int build()=>0;

  // مصفوفة البيانات الذكية التي ترجع البيانات المترجمة فوراً بناءً على حالة الـ state الحالية
  List<AboutUsSection> get aboutUsData {
    if (storage.read("Language") == 1) {
      // المصفوفة العربية (حينما يكون الـ state يساوي 1)
      return [
        AboutUsSection(
          title: "رؤيتنا",
          description: "تمكين المطاعم من خلال إدارة ذكية، رؤية قوية، وتجربة مستخدم سلسة دون انقطاع.",
        ),
        AboutUsSection(
          title: "ماذا نقدم",
          points: [
            "إدارة عمليات المطاعم بكفاءة",
            "تقديم الدعم التسويقي المتكامل",
            "تحسين التواصل مع العملاء",
            "إدارة الحجوزات بشكل احترافي",
          ],
        ),
        AboutUsSection(
          title: "ما الذي يميزنا",
          description: "كل ما تحتاجه، في مكان واحد. مدعوم بميزات لن تجدها في أي مكان آخر.",
        ),
        AboutUsSection(
          title: "لماذا تختارنا",
          points: [
            "دعم فني مباشر وفوري",
            "فريق عمل متخصص ومكرس لخدمتك",
            "سرعة فائقة في معالجة الاستجابات",
            "ظهور قوي وعالٍ داخل التطبيق",
            "مراقبة مستمرة للأداء وتطويره",
          ],
        ),
        AboutUsSection(
          title: "تأثيرنا وأرقامنا",
          points: [
            "+100 مطعم شريك",
            "آلاف الحجوزات التي تم التعامل معها بنجاح",
            "نسبة رضا عالية جداً من العملاء",
          ],
        ),
        AboutUsSection(
          title: "نحن لا ندعمك فحسب",
          description: "بل نصبح شريك النجاح والنمو الخاص بك.",
        ),
        AboutUsSection(
          title: "قريباً:",
          description: "نحن نتوسع إلى ما بعد المطاعم لنقدم تجربة ضيافة متكاملة. حلول سلسة لحجز وإدارة الفنادق قادمة قريباً — مبنية بنفس مستوى الجودة، الأداء، والاهتمام بالتفاصيل.",
        ),
      ];
    } else {
      // المصفوفة الإنجليزية (حينما يكون الـ state يساوي 0)
      return [
        AboutUsSection(
          title: "Our Mission",
          description: "To empower restaurants with smart management, strong visibility, and seamless customer experience.",
        ),
        AboutUsSection(
          title: "What We Do",
          points: [
            "Manage restaurant operations",
            "Provide marketing support",
            "Improve customer communication",
            "Handle reservations professionally",
          ],
        ),
        AboutUsSection(
          title: "What Makes Us Different",
          description: "Everything you need, all in one place. Powered by features you won't find anywhere else.",
        ),
        AboutUsSection(
          title: "Why Choose Us",
          points: [
            "Real-time support",
            "Dedicated team",
            "Faster response handling",
            "Strong visibility inside the app",
            "Continuous performance monitoring",
          ],
        ),
        AboutUsSection(
          title: "Our Impact",
          points: [
            "100+ Restaurants",
            "Thousands of bookings handled",
            "High customer satisfaction",
          ],
        ),
        AboutUsSection(
          title: "We Don't Just Support You",
          description: "We become your growth partner.",
        ),
        AboutUsSection(
          title: "Coming Soon:",
          description: "We are expanding beyond restaurants to deliver a complete hospitality experience. Seamless hotel booking and management solutions are coming soon — built with the same level of quality, performance, and attention to detail.",
        ),
      ];
    }
  }


}

// التسمية الجديدة المباشرة والمتناسقة مع الواجهة
final aboutUsProvider = NotifierProvider<AboutUsNotifier, int>(AboutUsNotifier.new);