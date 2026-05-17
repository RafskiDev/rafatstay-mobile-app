import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../Service/ApiService.dart';
import '../Otp/Otp.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController emailController = TextEditingController();
  FocusNode emailNode = FocusNode();
  @override
  int build() {
    return 0;
  }

  Future<dynamic> forgotPassword(BuildContext context) async {
    ApiService api = ApiService();
    final data = {
      "email":emailController.text,
    };
    final response = await api.post(
      "v1/auth/forgot-password",
      data,
      context,
    );
    print(response);
    if(response["success"]==true){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
           Otp(email:emailController.text,),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }else{
      print(response['success']);
    }


    return response;
  }
}
final ForgotPassword_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
