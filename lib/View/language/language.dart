import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import 'language_riverpod.dart';

class language extends ConsumerWidget {
  const language({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(language_riverpod); // العنصر المحدد
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();
    final items = ref.read(language_riverpod.notifier).languages;

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(context,textLanguage.GetWord("اختر اللغة")),
      body: Container(
        width:double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.GetWidth() * 2,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;

              return InkWell(
                onTap: () {
                  ref.read(language_riverpod.notifier).selectIndex(index);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  textDirection: items[index]["code"] == "ar"
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    Container(
                      width:sizes.GetWidth()*35,
                      margin: EdgeInsets.symmetric(vertical: sizes.GetHeight() * 0.2),
                      padding: EdgeInsets.symmetric(
                        horizontal: sizes.GetWidth() * 1.2,
                        vertical: sizes.GetHeight() * 0.6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.GetColor("textPrimary")
                              : theme.GetColor("textSecondary"),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: items[index]["code"] == "ar"
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          CustomRadioWidget<int>(
                            value: index,
                            groupValue: selectedIndex,
                            onChanged: (value)async {
                              ref.read(language_riverpod.notifier).selectIndex(value);
                              if(ref.read(language_riverpod.notifier).storage.read("token")!=null){
                               await ref.read(language_riverpod.notifier).updatePreferences(context,items[index]["code"].toString());
                              }
                            },
                            width: sizes.GetHeight() * 2.4,
                            height: sizes.GetHeight() * 2.4,
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(
                            items[index]["label"].toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

            },
          ),
        ),
      ),
    );
  }
}
// Source - https://stackoverflow.com/a
// Posted by Midhun MP
// Retrieved 2025-12-20, License - CC BY-SA 4.0

class CustomRadioWidget<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final double width;
  final double height;

  CustomRadioWidget({required this.value, required this.groupValue, required this.onChanged, this.width = 32, this.height = 32});

  @override
  Widget build(BuildContext context) {
    final theme = Themes();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          onChanged(this.value);
        },
        child: Container(
          height: this.height,
          width: this.width,
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            gradient: LinearGradient(
              colors: [
                theme.GetColor("textPrimary"),
                theme.GetColor("textPrimary"),
              ],
            ),
          ),

          child: Center(
            child: Container(
              height: this.height - 8,
              width: this.width - 8,
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                gradient: LinearGradient(
                  colors: value == groupValue ? [
                    theme.GetColor("primary"),
                    theme.GetColor("primary"),
                  ] : [
                    theme.GetColor("background"),
                    theme.GetColor("background"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

