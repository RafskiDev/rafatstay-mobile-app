import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

// استخدام Notifier بدل StateNotifier
class PageNotifier extends Notifier<int> {
  late TextLanguage textLanguage;
  @override
  int build() => 0;

  List<Map<String, String>> get texts => [
    {
      "title": TextLanguage().GetWord("ابدأ رحلتك إلى عالم الفخامة") ?? "",
      "content": TextLanguage().GetWord(
          "استكشف مجموعة مختارة بعناية من الإقامات المميزة المصممة لرحلة استثنائية. رأفت ستاي تُحسّن تجربتك باستكشاف سلس، وخيارات مُصممة خصيصًا، ولمسة من الأناقة في كل تفصيل.") ?? "",
    },
    {
      "title": TextLanguage().GetWord("حجز مُحسّن مُصمم خصيصًا لذوقك") ?? "",
      "content": TextLanguage().GetWord(
          "مع RafatStay، يصبح الحجز تجربة ممتعة. تصفح، اختر، وأكد في بضع خطوات فقط - مع أسعار شفافة، وصور واقعية، ومعلومات مفصلة تبعث على الثقة في كل خيار.") ?? "",
    },
    {
      "title": TextLanguage().GetWord("امتيازات حصرية ترتقي بكل إقامة") ?? "",
      "content": TextLanguage().GetWord(
          "استمتع ببرنامج ولاء مصمم لمكافأتك في كل خطوة. اكسب نقاطًا، واستفد من عروض حصرية، واحصل على دعم فني متميز، واستمتع بمتابعة سلسة قبل إقامتك وبعدها.") ?? "",
    },
  ];
  List image=['assets/icon/AppOverview_1.svg','assets/icon/AppOverview_2.svg','assets/icon/AppOverview_3.svg'];
  void setPage(int index) {
    state = index; // تحديث الصفحة
  }
}

// Provider
final pageProvider = NotifierProvider<PageNotifier, int>(PageNotifier.new);
