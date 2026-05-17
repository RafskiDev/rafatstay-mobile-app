import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

// استخدام Notifier بدل StateNotifier
class PageNotifier extends Notifier<int> {
  late TextLanguage textLanguage;
  late final List<Map<String, String>> texts;
  @override
  int build() {
    textLanguage = TextLanguage();
     ints();
    return 0;
  }
  void ints(){
    texts = [
      {
        "title": textLanguage.GetWord("ابدأ رحلتك إلى عالم الفخامة") ?? "",
        "content": textLanguage.GetWord(
            "استكشف مجموعة مختارة بعناية من الإقامات المميزة المصممة لرحلة استثنائية. رافات ستاي تُحسّن تجربتك باستكشاف سلس، وخيارات مُصممة خصيصًا، ولمسة من الأناقة في كل تفصيل.") ??
            "",
      },
      {
        "title": textLanguage.GetWord("حجز مُحسّن مُصمم خصيصًا لذوقك") ?? "",
        "content": textLanguage.GetWord(
            "مع RafatStay، يصبح الحجز تجربة ممتعة. تصفح، اختر، وأكد في بضع خطوات فقط - مع أسعار شفافة، وصور واقعية، ومعلومات مفصلة تبعث على الثقة في كل خيار.") ??
            "",
      },
      {
        "title": textLanguage.GetWord("امتيازات حصرية ترتقي بكل إقامة") ?? "",
        "content": textLanguage.GetWord(
            "استمتع ببرنامج ولاء مصمم لمكافأتك في كل خطوة. اكسب نقاطًا، واستفد من عروض حصرية، واحصل على دعم فني متميز، واستمتع بمتابعة سلسة قبل إقامتك وبعدها.") ??
            "",
      },
    ];
  }
  List image=['assets/images/img_3.png','assets/images/img_8.png','assets/images/img_9.png'];
  void setPage(int index) {
    state = index; // تحديث الصفحة
  }
}

// Provider
final pageProvider = NotifierProvider<PageNotifier, int>(PageNotifier.new);
