import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PageNotifier extends Notifier<int> {
  TextEditingController firstpasswordController = TextEditingController();
  FocusNode firstpasswordNode = FocusNode();
  TextEditingController SecondasswordController = TextEditingController();
  FocusNode SecondpasswordNode = FocusNode();
  @override
  int build() {
    return 0;
  }
  void dispose() {
    firstpasswordController.dispose();
    firstpasswordNode.dispose();
    SecondasswordController.dispose();
    SecondpasswordNode.dispose();
  }
  void reset() {
    firstpasswordController.clear();
    firstpasswordNode.unfocus();
    SecondasswordController.clear();
    SecondpasswordNode.unfocus();
  }
  void save() {
    if(firstpasswordController.text == SecondasswordController.text){
      reset();
    }else{
      print("erorr");
    }
  }

}
final ResetYourPassword_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);
