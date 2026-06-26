import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Service/ApiService.dart';
import '../../Widget/WidgetAppBar.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController controller;
  bool _handled = false; // يمنع التكرار

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains("payment/callback") && !_handled) {
              _handled = true;
              final uri = Uri.parse(request.url);
              final reference = uri.queryParameters["reference"];

              if (reference != null) {
                _verifyPayment(reference);
              } else {
                Navigator.pop(context, "failed");
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _verifyPayment(String reference) async {
    final response = await ApiService().post(
      "v1/payments/verify",
      {"tap_id": reference},
      context,
    );

    if (!mounted) return;

    final isSuccess = response?["data"]?["is_success"] == true;
    final nextStep = response?["data"]?["next_step"];

    Navigator.pop(context, {
      "status": isSuccess ? "success" : "failed",
      "next_step": nextStep,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(context, TextLanguage().GetWord("الدفع")),
      body: WebViewWidget(controller: controller),
    );
  }
}