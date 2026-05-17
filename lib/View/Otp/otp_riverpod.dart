import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Service/ApiService.dart';
class PageNotifier extends Notifier<int> {
  static const int countdownSeconds = 600;

  @override
  int build() => countdownSeconds;

  void tick() {
    if (state > 0) state--;
  }

  void reset() {
    state = countdownSeconds;
  }
  Future<dynamic> verifyOtp(BuildContext context, String email, String otp) async {
    ApiService api = ApiService();
    final data = {
      "email": email,
      "otp": otp,
    };
    final response = await api.post(
      "v1/auth/verify-otp",
      data,
      context,
    );
    if (response["success"] == true) {

    } else {
      print(response['message']);
    }
    return response;
  }
}
final otp_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
