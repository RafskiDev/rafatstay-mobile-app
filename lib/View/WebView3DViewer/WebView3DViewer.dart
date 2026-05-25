import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🛑 ضروري جداً للتحكم في اتجاه الشاشة
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Utils/Sizes.dart';
import '../../Widget/WidgetAppBar.dart';

class WebView3DViewer extends StatefulWidget {
  final String url;

  const WebView3DViewer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<WebView3DViewer> createState() => _WebView3DViewerState();
}

class _WebView3DViewerState extends State<WebView3DViewer> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 🛑 1. تحويل الشاشة إلى الوضع الأفقي وإخفاء شريط الإشعارات العلوي لتجربة سينمائية
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // ملء الشاشة بالكامل

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // ضروري لتشغيل الـ 3D والـ Gyroscope
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    // 🛑 2. إعادة الشاشة إلى الوضع العمودي الطبيعي وإرجاع شريط النظام عند الخروج من الصفحة
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // إرجاع شريط الإشعارات والأزرار

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدمنا الـ PopScope (أو WillPopScope في النسخ الأقدم) لضمان إرجاع الشاشة لوضعها الطبيعي حتى لو خرج المستخدم بزر الظهر للجهاز
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // تأكيد إرجاع الاتجاهات عند الخروج بالـ Swipe أو أزرار النظام
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // الـ WebView الذي يعرض صفحة الـ Three.js
            WebViewWidget(controller: _webViewController),

            // الـ AppBar الزجاجي - قمنا بتعديل تباعد الـ Top ليناسب الوضع الأفقي
            Positioned(
              top: Sizes(context).GetHeight() * 4,
              left: Sizes(context).GetWidth() * 2,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  // حجم الدائرة ثابت هنا
                  width: Sizes(context).GetHeight() * 15,
                  height: Sizes(context).GetHeight() * 15,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  // استخدام Center لضمان بقاء السهم في المنتصف مهما كبر
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      // هنا تكبر السهم كما تشاء
                      size: Sizes(context).GetHeight() * 6,
                    ),
                  ),
                ),
              ),
            ),

            // شاشة الانتظار
            if (_isLoading)
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      Text(
                        TextLanguage().GetWord("جاري تحضير التجربة الافتراضية ثلاثية الأبعاد..."),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}